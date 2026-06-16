# Module Interface Contract: msk-topics

**Registry source**: `dasmeta/msk-topics/kafka`
**Provider**: `Mongey/kafka ~> 0.6`
**Terraform**: `~> 1.3`

## Input Variables

| Variable | Type | Required | Default | Description |
|---|---|---|---|---|
| `bootstrap_brokers` | `string` | **Yes** | — | Comma-separated MSK SASL/SCRAM broker string (port 9096). Use the SASL endpoint, not the TLS-only endpoint. |
| `sasl_username` | `string` | No | `""` | SASL/SCRAM username. Leave empty for TLS-only clusters. |
| `sasl_password` | `string` (sensitive) | No | `""` | SASL/SCRAM password. Pass via secret manager or `TF_VAR_sasl_password` — never hardcode. |
| `sasl_mechanism` | `string` | No | `"scram-sha-512"` | SASL mechanism. Accepted values: `scram-sha-256`, `scram-sha-512`. |
| `topics` | `map(object)` | **Yes** | — | Map of Kafka topic definitions. Map key is the topic name. |

### Topic Object Shape

```hcl
map(object({
  partitions         = number                    # required, >= 1
  replication_factor = number                    # required, must not exceed broker count
  config             = optional(map(string), {}) # optional, Kafka topic config key-value pairs
}))
```

### Common `config` Keys

| Key | Example | Description |
|---|---|---|
| `retention.ms` | `"604800000"` | Message retention in milliseconds. `-1` = infinite. |
| `cleanup.policy` | `"delete"` | `delete`, `compact`, or `delete,compact`. |
| `min.insync.replicas` | `"2"` | Minimum in-sync replicas before a write is acknowledged. |
| `unclean.leader.election.enable` | `"false"` | Whether to allow out-of-sync replicas to become leader. |
| `max.message.bytes` | `"1048576"` | Maximum message size in bytes. |
| `compression.type` | `"lz4"` | Message compression codec. |

All config values must be **quoted strings** — Kafka protocol requirement.

## Outputs

| Output | Type | Description |
|---|---|---|
| `topic_names` | `list(string)` | Names of all Kafka topics managed by this module. |
| `topic_ids` | `map(string)` | Map of topic name → Terraform resource ID (`kafka_topic.topics[name].id`). |

## Stable Addressing

Topics use `for_each` on the map key. Adding a new topic produces `Plan: 1 to add, 0 to change, 0 to destroy`. Removing a topic produces a destruction plan that requires explicit approval.

## Wrapper YAML Example

```yaml
source: dasmeta/msk-topics/kafka
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
providers:
  - <<: *provider_aws_prod
linked_workspaces:
  - 0-accounts/prod/msk
  - 0-accounts/root/master-secret
```
