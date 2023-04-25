data "digitalocean_kubernetes_versions" "k8s_version" {
  count = terraform.workspace != "dev" ? 1 : 0
}

resource "digitalocean_kubernetes_cluster" "infrastructure_example" {
  count = terraform.workspace != "dev" ? 1 : 0

  name         = "infrastructure-example"
  region       = "lon1"
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.k8s_version[0].latest_version

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
  host  = terraform.workspace != "dev" ? digitalocean_kubernetes_cluster.infrastructure_example[0].endpoint : null
  token = terraform.workspace != "dev" ? digitalocean_kubernetes_cluster.infrastructure_example[0].kube_config[0].token : null
  cluster_ca_certificate = terraform.workspace != "dev" ? base64decode(
    digitalocean_kubernetes_cluster.infrastructure_example[0].kube_config[0].cluster_ca_certificate
  ) : null
  config_path    = terraform.workspace == "dev" ? "~/.kube/config" : null
  config_context = terraform.workspace == "dev" ? "minikube" : null
}

resource "kubernetes_namespace" "argo_cd_namespace" {
  metadata {
    name = "argocd"
  }
}

provider "helm" {
  kubernetes {
    host  = terraform.workspace != "dev" ? digitalocean_kubernetes_cluster.infrastructure_example[0].endpoint : null
    token = terraform.workspace != "dev" ? digitalocean_kubernetes_cluster.infrastructure_example[0].kube_config[0].token : null
    cluster_ca_certificate = terraform.workspace != "dev" ? base64decode(
      digitalocean_kubernetes_cluster.infrastructure_example[0].kube_config[0].cluster_ca_certificate
    ) : null
    config_path    = terraform.workspace == "dev" ? "~/.kube/config" : null
    config_context = terraform.workspace == "dev" ? "minikube" : null
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  version    = "5.29.1"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  wait = false

  

  depends_on = [
    kubernetes_namespace.argo_cd_namespace
  ]

}

# This is a hack to ensure the application seed is deleted BEFORE argo-cd
# If deleted after argo-cd the application seed and child applications + objects will remain orphaned and the namespace cannot be deleted
# Manually edit the yaml in the cluster and delete the 'finalizer' to force removal if that happens
resource "time_sleep" "wait_10_seconds" {
  depends_on = [helm_release.argo_cd]

  destroy_duration = "10s"
}

resource "helm_release" "applications_seed" {
  name      = "applications-seed"
  chart     = "./helm/applications-seed"
  namespace = "argocd"
  version   = "0.1.1"
  wait = true

  depends_on = [
    helm_release.argo_cd,
    kubernetes_namespace.argo_cd_namespace,
    time_sleep.wait_10_seconds
  ]
}