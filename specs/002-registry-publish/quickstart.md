# Quickstart: Using msk-topics from the Terraform Registry

## Option 1 — Wrapper YAML (DasMeta DSL, recommended)

Place this file in your infrastructure repository. The DSL resolves broker endpoints and SASL credentials from linked workspaces at apply time.

```yaml
source: dasmeta/msk-topics/kafka
version: 1.0.0
variables:
  bootstrap_brokers: ${0-accounts/prod/msk.bootstrap_brokers_sasl_scram}
  sasl_username: ${0-accounts/root/master-secret.secrets.MSK_USERNAME_PROD}
  sasl_password: ${0-accounts/root/master-secret.secrets.MSK_PASSWORD_PROD}
  sasl_mechanism: "scram-sha-512"
  topics:
    "your.topic.name.v1":
      partitions: 10
      replication_factor: 3
      config:
        cleanup.policy: "delete"
        retention.ms: "-1"
        min.insync.replicas: "2"
        unclean.leader.election.enable: "false"
providers:
  - <<: *provider_aws_prod
linked_workspaces:
  - 0-accounts/prod/msk
  - 0-accounts/root/master-secret
```

See `wrappers/dev.yaml` and `wrappers/prod.yaml` in this repository for full working examples.

## Option 2 — Direct Terraform

```hcl
module "msk_topics" {
  source  = "dasmeta/msk-topics/kafka"
  version = "1.0.0"

  bootstrap_brokers = "b-1.example.kafka.us-east-1.amazonaws.com:9096,b-2.example.kafka.us-east-1.amazonaws.com:9096"
  sasl_username     = var.sasl_username
  sasl_password     = var.sasl_password   # pass via TF_VAR_sasl_password
  sasl_mechanism    = "scram-sha-512"

  topics = {
    "your.topic.name.v1" = {
      partitions         = 10
      replication_factor = 3
      config = {
        "cleanup.policy"                 = "delete"
        "retention.ms"                   = "-1"
        "min.insync.replicas"            = "2"
        "unclean.leader.election.enable" = "false"
      }
    }
  }
}
```

## Adding a New Topic

Add an entry to the `topics` map and run `terraform apply`. The `for_each` design guarantees:

```
Plan: 1 to add, 0 to change, 0 to destroy.
```

Existing topics are never modified or destroyed by adding a new map key.

## Publishing a New Module Version

1. Merge changes to `main` branch in the `terraform-kafka-msk-topics` GitHub repository.
2. Create and push a semantic version tag:
   ```sh
   git tag v1.1.0
   git push origin v1.1.0
   ```
3. The Terraform registry automatically detects the new tag and publishes the version.
