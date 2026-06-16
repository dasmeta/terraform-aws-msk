# Module Interface Contract: msk-topics

**Registry source**: `dasmeta/msk-topics/kafka`
**Provider**: `Mongey/kafka ~> 0.6` (configured by caller)
**Terraform**: `~> 1.3`

## Input Variables

| Variable | Type | Required | Default | Description |
|---|---|---|---|---|
| `topics` | `map(object)` | **Yes** | — | Map of Kafka topic definitions. Map key is the topic name. |

### Topic Object Shape

```hcl
map(object({
  partitions         = number
  replication_factor = number
  config             = optional(map(string), {})
}))
```

## Outputs

| Output | Type | Description |
|---|---|---|
| `topic_names` | `list(string)` | Names of all Kafka topics managed by this module. |
| `topic_ids` | `map(string)` | Map of topic name → Terraform resource ID. |

## Provider Requirements (versions.tf)

```hcl
terraform {
  required_version = "~> 1.3"

  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.6"
    }
  }
}
```

## Provider Configuration (caller's responsibility)

The root module must configure the `kafka` provider before calling this module:

```hcl
provider "kafka" {
  bootstrap_servers = split(",", var.bootstrap_brokers)
  tls_enabled       = true
  sasl_username     = var.sasl_username
  sasl_password     = var.sasl_password
  sasl_mechanism    = var.sasl_mechanism
}
```

## Module Call Example

```hcl
module "msk_topics" {
  source  = "dasmeta/msk-topics/kafka"
  version = "1.0.0"

  topics = var.topics
}
```

The module consumes no variables beyond `topics` — broker connectivity is handled entirely through the caller-configured `kafka` provider.

## Stability Guarantees

| Property | Guarantee |
|---|---|
| Resource addresses | Stable by topic name (`for_each` map key) |
| Idempotency | Unchanged inputs produce zero changes on apply |
| Breaking change | Removing `bootstrap_brokers` / SASL module variables — ship before v1.0.0 publish |
