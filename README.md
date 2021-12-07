# GitOps Bootstrap K8s with Terraform 🚀

Using a simple managed Kubernetes cluster on Digitalocean you can bootstrap it with Argo CD and an inital [app-of-apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) seed [application](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/). then all your applications from a git repo are automagically pulled onto your cluster. After this initial cluster bootstrapping argocd handle the deployment of all your kubernetes resources

## Dependencies

[Docker](https://www.docker.com/get-started)

The following may be installed with [brew](https://brew.sh/). Run `brew bundle`

Required:

[Minikube](https://minikube.sigs.k8s.io/docs/start/)
[Terraform](https://www.terraform.io/downloads.html)
[Kubernetes](https://kubernetes.io/docs/tasks/tools/)
[Helm](https://helm.sh/docs/intro/install/)

Optional:

[doctl](https://docs.digitalocean.com/reference/doctl/)
[k9s](https://k9scli.io/)



## Dev Quickstart

Start minikube

    minikube start

Set up Terraform environment variables
Using the workspace named `dev` here makes sure the terraform runs against a local minikube cluster

    export TF_WORKSPACE=dev

Force Terraform to not use remote execution. We only care about terraform cloud state management

    export TF_FORCE_LOCAL_BACKEND=1

The backend here is `remote` using terraform cloud. sign up for a free account, create an organization, skip creating a workspace and create a user API token.

    export TF_CLI_ARGS_init="-backend-config='token=<TF CLOUD TOKEN>' -backend-config='organization=<TF CLOUD ORG NAME>'"

Create a digitalocean access token or make one up if just local testing
    
    export DIGITALOCEAN_ACCESS_TOKEN=<DO API TOKEN>

Now create a new terraform workspace

    terraform workspace new $TF_WORKSPACE

Run the standard terraform commands

    terraform init

    terraform plan

    terraform apply

Check your local minikube cluster with kubectl or a tool like k9s and see the various pods created. you can even [portforward argo-cd admin UI](https://argo-cd.readthedocs.io/en/stable/getting_started/#port-forwarding) and sync to get all the example apps installed. You can get the argocd admin UI password [here](https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)