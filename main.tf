data "digitalocean_kubernetes_versions" "k8s_version" {}

resource "digitalocean_kubernetes_cluster" "infrastructure_example" {
  name         = "infrastructure-example"
  region       = "lon1"
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.k8s_version.latest_version

  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  node_pool {
    name       = "infrastructure-example-autoscale-worker-pool"
    size       = "s-2vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }
}

provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.infrastructure_example.endpoint
  token = digitalocean_kubernetes_cluster.infrastructure_example.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.infrastructure_example.kube_config[0].cluster_ca_certificate
  )
}

resource "kubernetes_namespace" "argo_cd_namespace" {
  metadata {
    name = "argocd"
  }
}

provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.infrastructure_example.endpoint
    token = digitalocean_kubernetes_cluster.infrastructure_example.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.infrastructure_example.kube_config[0].cluster_ca_certificate
    )
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  version    = "3.27.1"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace = "argocd"
}

resource "helm_release" "applications_seed" {
  name  = "applications-seed"
  chart = "./helm/applications-seed"
  namespace = "argocd"
  version = "0.1.1"

  depends_on = [
    helm_release.argo_cd
  ]
}