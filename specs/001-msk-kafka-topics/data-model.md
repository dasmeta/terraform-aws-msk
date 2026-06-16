# Data Model: AWS MSK Kafka Topic Provisioning Module

**Feature**: 001-msk-kafka-topics
**Date**: 2026-05-29

## Entities

### TopicDefinition

The logical description of a single Kafka topic, used as the value type in the `topics` input variable map.

| Field               | Type            | Required | Default | Constraints                              |
|---------------------|-----------------|----------|---------|------------------------------------------|
| *(key = topic name)*| string (map key)| Yes      | —       | Valid Kafka topic name; unique across map |
| `partitions`        | number          | Yes      | —       | Integer ≥ 1; typically a power of 2      |
| `replication_factor`| number          | Yes      | —       | Integer ≥ 1; must not exceed broker count |
| `config`            | map(string)     | No       | `{}`    | Key-value broker topic config; all values are strings per Kafka protocol |

**Common `config` keys**:

| Config Key         | Example Value   | Meaning                                      |
|--------------------|-----------------|----------------------------------------------|
| `retention.ms`     | `"604800000"`   | How long messages are retained (milliseconds)|
| `cleanup.policy`   | `"delete"`      | `"delete"` or `"compact"` or `"delete,compact"` |
| `max.message.bytes`| `"1048576"`     | Max message size in bytes                    |
| `min.insync.replicas` | `"2"`        | Minimum in-sync replicas before write succeeds |
| `compression.type` | `"lz4"`         | Message compression codec                    |

---

### MSKClusterReference

The network addressing information for the target Kafka cluster. Passed to the `msk-topics` module as input variables.

| Field               | Type   | Required | Notes                                                   |
|---------------------|--------|----------|---------------------------------------------------------|
| `bootstrap_brokers` | string | Yes      | Comma-separated `host:port` list; use TLS endpoint (port 9094) or SASL endpoint (port 9096) from MSK output |

---

### KafkaProviderConfig

The Terraform provider configuration block in each environment root module. Not an input to the `msk-topics` module itself — lives in the caller.

| Field                | Type   | Required | Default | Notes                                       |
|----------------------|--------|----------|---------|---------------------------------------------|
| `bootstrap_servers`  | string | Yes      | —       | Same value as `bootstrap_brokers`           |
| `tls_enabled`        | bool   | No       | `true`  | Must be `true` for MSK TLS endpoints        |
| `ca_cert_file`       | string | No       | `""`    | Path to CA cert; empty = system trust store |
| `sasl_username`      | string | No       | `""`    | SASL/SCRAM username (MSK SCRAM secret)      |
| `sasl_password`      | string | No       | `""`    | SASL/SCRAM password; supply via env var     |
| `sasl_mechanism`     | string | No       | `""`    | `"scram-sha-256"` or `"scram-sha-512"`      |

---

### EnvironmentConfig

The per-environment configuration expressed in `terraform.tfvars`. Combines the `topics` map with environment-specific provider inputs.

| Field               | Type                      | Notes                                             |
|---------------------|---------------------------|---------------------------------------------------|
| `bootstrap_brokers` | string                    | MSK cluster endpoint for this environment         |
| `topics`            | map(TopicDefinition)      | Full topic set for this environment               |

---

## State Transitions

```
Topic lifecycle in Terraform state:

[Not in tfvars]  ──── add to topics map ────►  [Planned: create]
                                                      │
                                                  terraform apply
                                                      │
                                                      ▼
                                              [Created on broker]
                                                      │
                         ┌────────────────────────────┼──────────────────────────────┐
                         │                            │                              │
                    change config               no tfvars change            remove from topics map
                         │                            │                              │
                         ▼                            ▼                              ▼
                 [Planned: update]           [No-op: 0 changes]           [Planned: destroy]
                         │                                                            │
                   terraform apply                                            terraform apply
                         │                                                    (requires approval)
                         ▼                                                            │
               [Updated on broker]                                                    ▼
                                                                          [Deleted from broker]
```

---

## Validation Rules

- Topic names must be valid Kafka topic names: `[a-zA-Z0-9._-]`, max 249 characters, cannot be `.` or `..`.
- `partitions` must be a positive integer. Terraform and the Kafka broker both reject ≤ 0.
- `replication_factor` must not exceed the number of available MSK broker nodes. A mismatch causes the Kafka provider to return an error at apply time.
- All `config` values must be strings (Kafka protocol requirement). Numeric values like `retention.ms` must be quoted in tfvars.
- Duplicate topic names are structurally impossible with a map type (Terraform enforces map key uniqueness at parse time).
