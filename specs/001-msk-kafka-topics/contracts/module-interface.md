# Module Interface Contract: msk-topics

**Module path**: `modules/msk-topics`
**Provider**: `registry.terraform.io/Mongey/kafka` (≥ 0.6.0)
**Terraform**: ≥ 1.3.0 (required for `optional()` in object type constraints)

---

## Input Variables

### `topics` *(required)*

```hcl
variable "topics" {
  description = "Map of Kafka topic definitions. Map key is the topic name."
  type = map(object({
    partitions         = number
    replication_factor = number
    config             = optional(map(string), {})
  }))
}
```

**Example value (terraform.tfvars)**:
```hcl
topics = {
  "orders" = {
    partitions         = 6
    replication_factor = 3
    config = {
      "retention.ms"  = "604800000"
      "cleanup.policy" = "delete"
    }
  }
  "payments" = {
    partitions         = 12
    replication_factor = 3
    config = {
      "retention.ms"         = "2592000000"
      "min.insync.replicas"  = "2"
    }
  }
  "audit-log" = {
    partitions         = 3
    replication_factor = 3
  }
}
```

---

## Output Values

### `topic_names`

```hcl
output "topic_names" {
  description = "List of all Kafka topic names managed by this module."
  value       = [for name, _ in var.topics : name]
}
```

### `topic_ids`

```hcl
output "topic_ids" {
  description = "Map of topic name to Terraform resource ID (same as topic name for the Kafka provider)."
  value       = { for name, t in kafka_topic.topics : name => t.id }
}
```

---

## Provider Requirements (versions.tf)

```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = ">= 0.6.0"
    }
  }
}
```

---

## Provider Configuration (caller's responsibility)

The environment root module must configure the `kafka` provider before calling this module:

```hcl
provider "kafka" {
  bootstrap_servers = [var.bootstrap_brokers]
  tls_enabled       = true

  # Optional SASL/SCRAM — omit if using TLS-only auth
  sasl_username  = var.sasl_username
  sasl_password  = var.sasl_password
  sasl_mechanism = var.sasl_mechanism  # "scram-sha-256" or "scram-sha-512"
}
```

**Security note**: `sasl_password` must never appear in tfvars files committed to version control. Supply it via the `TF_VAR_sasl_password` environment variable or a secrets manager integration.

---

## Module Call Example

```hcl
module "msk_topics" {
  source = "../../modules/msk-topics"

  topics = var.topics
}
```

The module consumes no additional variables beyond `topics` — broker connectivity is handled entirely through the caller-configured `kafka` provider.

---

## Stability Guarantees

| Property                 | Guarantee                                                              |
|--------------------------|------------------------------------------------------------------------|
| Resource addresses       | Stable by topic name; adding/removing topics does not shift other addresses |
| Idempotency              | `terraform apply` with unchanged tfvars produces zero changes          |
| No side effects          | Module does not create IAM roles, security groups, or MSK clusters     |
| Backward compatibility   | Adding a new optional variable will not break existing callers         |
| Breaking changes         | Removing or renaming an existing variable is a breaking change; requires major version bump |
