terraform {
  required_version = "~> 1.3"

  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.6"
    }
  }
}
