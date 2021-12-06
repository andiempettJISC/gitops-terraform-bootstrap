terraform {
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

variable "do_token" {
  description = "The Digital Ocean Personal Access Token for the user"
  sensitive   = true
  type        = string
}

provider "digitalocean" {
  token = var.do_token
}