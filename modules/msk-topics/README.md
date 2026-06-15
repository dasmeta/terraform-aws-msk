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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_kafka"></a> [kafka](#requirement\_kafka) | ~> 0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kafka"></a> [kafka](#provider\_kafka) | 0.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kafka_topic.topics](https://registry.terraform.io/providers/Mongey/kafka/latest/docs/resources/topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_brokers"></a> [bootstrap\_brokers](#input\_bootstrap\_brokers) | Comma-separated MSK SASL/SCRAM bootstrap broker string (port 9096). Use the SASL endpoint, not the TLS-only endpoint. | `string` | n/a | yes |
| <a name="input_sasl_mechanism"></a> [sasl\_mechanism](#input\_sasl\_mechanism) | SASL mechanism. Accepted values: 'scram-sha256', 'scram-sha512'. Defaults to scram-sha512. | `string` | `"scram-sha512"` | no |
| <a name="input_sasl_password"></a> [sasl\_password](#input\_sasl\_password) | SASL/SCRAM password. Pass via workspace secret or DSL secret interpolation — never hardcode. | `string` | `""` | no |
| <a name="input_sasl_username"></a> [sasl\_username](#input\_sasl\_username) | SASL/SCRAM username. Leave empty for TLS-only auth (not applicable to SCRAM-enabled MSK clusters). | `string` | `""` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Map of Kafka topic definitions. Map key is the topic name. | <pre>map(object({<br/>    partitions         = number<br/>    replication_factor = number<br/>    config             = optional(map(string), {})<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids) | Map of topic name to Terraform resource ID. |
| <a name="output_topic_names"></a> [topic\_names](#output\_topic\_names) | List of all Kafka topic names managed by this module. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
