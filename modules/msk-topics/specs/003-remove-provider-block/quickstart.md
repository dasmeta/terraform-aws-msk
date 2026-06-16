# Quickstart: msk-topics with Caller-Owned Provider

## Minimal Terraform usage

```hcl
terraform {
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.6"
    }
  }
}

provider "kafka" {
  bootstrap_servers = split(",", var.bootstrap_brokers)
  tls_enabled       = true
  sasl_username     = var.sasl_username
  sasl_password     = var.sasl_password
  sasl_mechanism    = "scram-sha-512"
}

module "msk_topics" {
  source  = "dasmeta/msk-topics/kafka"
  version = "1.0.0"

  topics = {
    "example.events.v1" = {
      partitions         = 3
      replication_factor = 3
      config = {
        "cleanup.policy" = "delete"
        "retention.ms"   = "604800000"
      }
    }
  }
}
```

## Local example validation

```bash
terraform -chdir=examples/basic init -backend=false
terraform -chdir=examples/basic validate
```

## Adding a topic

Add an entry to the `topics` map and run `terraform apply`:

```
Plan: 1 to add, 0 to change, 0 to destroy.
```

## SASL endpoint note

Use port `9096` (SASL/SCRAM), not `9094` (TLS-only), for MSK clusters with SCRAM authentication.

## Secrets

Pass `sasl_password` via `TF_VAR_sasl_password` or a secrets manager — never commit credentials to version control.
