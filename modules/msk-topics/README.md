# msk-topics

Terraform module that provisions Kafka topics on an AWS MSK cluster. Topics are declared as a map, created via `for_each`, and fully idempotent — repeated applies with unchanged inputs produce zero changes.

The module configures the `Mongey/kafka` provider internally, accepting broker connectivity and SASL credentials as input variables. This makes it self-contained and compatible with the DasMeta YAML DSL wrapper pattern.

## Registry Source

```hcl
source  = "dasmeta/msk-topics/kafka"
version = "1.0.0"
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | `~> 1.3` |
| Mongey/kafka | `~> 0.6` |

## Usage — YAML wrapper (recommended)

Place this file in your infrastructure repository. The DSL resolves broker endpoints and SASL credentials from linked workspaces at apply time:

```yaml
source: dasmeta/msk/aws//modules/msk-topics
version: 1.0.0
variables:
  bootstrap_brokers: ${0-accounts/prod/msk.bootstrap_brokers_sasl_scram}
  sasl_username: ${0-accounts/root/master-secret.secrets.MSK_USERNAME_PROD}
  sasl_password: ${0-accounts/root/master-secret.secrets.MSK_PASSWORD_PROD}
  sasl_mechanism: "scram-sha-512"
  topics:
    "example.events.v1":
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

See `wrappers/dev.yaml` and `wrappers/prod.yaml` for full environment examples.

## Usage — direct Terraform

```hcl
module "msk_topics" {
  source  = "dasmeta/msk-topics/kafka"
  version = "1.0.0"

  bootstrap_brokers = "b-1.example.kafka.us-east-1.amazonaws.com:9096,b-2.example.kafka.us-east-1.amazonaws.com:9096"
  sasl_username     = var.sasl_username
  sasl_password     = var.sasl_password  # pass via TF_VAR_sasl_password
  sasl_mechanism    = "scram-sha-512"

  topics = {
    "example.orders.v1" = {
      partitions         = 10
      replication_factor = 3
      config = {
        "retention.ms"                   = "-1"
        "cleanup.policy"                 = "delete"
        "min.insync.replicas"            = "2"
        "unclean.leader.election.enable" = "false"
      }
    }
    "example.audit-log.v1" = {
      partitions         = 6
      replication_factor = 3
      config = {
        "cleanup.policy"                 = "compact"
        "min.insync.replicas"            = "2"
        "unclean.leader.election.enable" = "false"
      }
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `bootstrap_brokers` | `string` | required | Comma-separated MSK SASL/SCRAM broker string (port 9096). Use the SASL endpoint, not the TLS-only endpoint. |
| `sasl_username` | `string` | `""` | SASL/SCRAM username |
| `sasl_password` | `string` | `""` | SASL/SCRAM password — pass via secret manager, never hardcode |
| `sasl_mechanism` | `string` | `"scram-sha-512"` | SASL mechanism: `scram-sha-256` or `scram-sha-512` |
| `topics` | `map(object)` | required | Map of topic definitions. Key = topic name. |

### Topic object shape

```hcl
object({
  partitions         = number                    # required, >= 1
  replication_factor = number                    # required, must not exceed broker count
  config             = optional(map(string), {}) # optional, defaults to {}
})
```

**Common `config` keys:**

| Key | Example | Description |
|-----|---------|-------------|
| `retention.ms` | `"-1"` | Retention in ms. `-1` = infinite. |
| `cleanup.policy` | `"delete"` | `delete`, `compact`, or `delete,compact` |
| `min.insync.replicas` | `"2"` | Minimum ISR before a write is acknowledged |
| `unclean.leader.election.enable` | `"false"` | Allow out-of-sync replica to become leader |
| `max.message.bytes` | `"1048576"` | Maximum message size in bytes |
| `compression.type` | `"lz4"` | Message compression codec |

All config values must be **quoted strings** — Kafka protocol requirement.

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `topic_names` | `list(string)` | Names of all managed topics |
| `topic_ids` | `map(string)` | Map of topic name → Terraform resource ID |

## Notes

- **SASL endpoint**: Use port `9096` (SASL/SCRAM), not `9094` (TLS-only), for MSK clusters with SCRAM authentication.
- **Stable addresses**: Topic names are `for_each` map keys. Adding a topic never modifies or destroys existing ones — `Plan: 1 to add, 0 to change, 0 to destroy`.
- **Deletion**: Topics removed from the map are planned for destruction. Terraform requires explicit `yes` approval.
- **Replication factor**: Must not exceed broker count. A mismatch fails at apply time with a Kafka broker error.
- **Config values**: All Kafka config values are strings. Numeric values like `retention.ms` must be quoted.
- **Lock file**: `.terraform.lock.hcl` is committed and pins the `Mongey/kafka` provider version for reproducible `terraform init` runs.

## Publishing a New Version

```sh
git tag v1.1.0
git push origin v1.1.0
```

The Terraform registry automatically detects the new tag and publishes the version within minutes.
