terraform {
  required_version = "~> 1.3"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Kubeconfig from: meta exec payconomy eks-prod
locals {
  kubeconfig_path    = ""
  kubeconfig_context = ""
}

provider "kubernetes" {
  config_path    = local.kubeconfig_path
  config_context = local.kubeconfig_context
}

provider "helm" {
  kubernetes {
    config_path    = local.kubeconfig_path
    config_context = local.kubeconfig_context
  }
}
