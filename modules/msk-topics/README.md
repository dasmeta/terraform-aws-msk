# msk-topics

Terraform module that provisions Kafka topics on an AWS MSK cluster. Topics are declared as a map, created via `for_each`, and fully idempotent — repeated applies with unchanged inputs produce zero changes.

Configure the `Mongey/kafka` provider in your root module; this module accepts only `topics`.

## Usage

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
  source = "../../"

  topics = {
    "example-orders" = {
      partitions         = 6
      replication_factor = 3
      config = {
        "retention.ms"   = "604800000"
        "cleanup.policy" = "delete"
      }
    }

    "example-audit-log" = {
      partitions         = 3
      replication_factor = 3
      config = {
        "cleanup.policy" = "compact"
      }
    }

    "example-notifications" = {
      partitions         = 3
      replication_factor = 3
    }
  }
}
```

This example matches `examples/basic` and can be used as a minimal starting point for local testing.

## Requirements

| Name | Version |
|------|---------|
| Terraform | `~> 1.3` |
| Mongey/kafka | `~> 0.6` |

The `kafka` provider must be configured by the caller before invoking this module. Broker endpoints and SASL credentials are not module inputs.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
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
- **Secrets**: Pass `sasl_password` via `TF_VAR_sasl_password` or a secrets manager — never commit credentials.
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
| <a name="input_topics"></a> [topics](#input\_topics) | Map of Kafka topic definitions. Map key is the topic name. | <pre>map(object({<br/>    partitions         = number<br/>    replication_factor = number<br/>    config             = optional(map(string), {})<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids) | Map of topic name to Terraform resource ID. |
| <a name="output_topic_names"></a> [topic\_names](#output\_topic\_names) | List of all Kafka topic names managed by this module. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
