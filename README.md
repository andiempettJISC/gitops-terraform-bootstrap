# GitOps Bootstrap K8s with Terraform 🚀

## Quickstart

    export TF_WORKSPACE=dev
    export TF_CLI_ARGS_init="-backend-config='token=<TF CLOUD TOKEN>' -backend-config='organization=<TF CLOUD ORG NAME>'"
    export TF_FORCE_LOCAL_BACKEND=1
    export DIGITALOCEAN_ACCESS_TOKEN=<DO API TOKEN>

    terraform workspace new $TF_WORKSPACE

    minikube start

    terraform init

    terraform plan

    terraform apply