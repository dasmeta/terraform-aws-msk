terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.42"
      configuration_aliases = []
    }
  }
  required_version = ">= 1.3.0"
}
