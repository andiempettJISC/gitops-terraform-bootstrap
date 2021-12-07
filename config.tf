terraform {
  backend "remote" {
    workspaces {
      prefix = "gitops-bootstrap-"
    }

  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "digitalocean" {
}

provider "time" {
}