# Implementation Plan: AWS MSK Kafka Topic Provisioning Module

**Branch**: `001-msk-kafka-topics` | **Date**: 2026-05-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-msk-kafka-topics/spec.md`

## Summary

Build a reusable Terraform module named `msk-topics` that provisions Kafka topics on AWS MSK clusters using the `Mongey/kafka` provider. The module accepts a `map(object)` of topic definitions and creates each topic via `for_each`, supporting environment-specific configurations through separate root modules and tfvars files. This enables declarative, drift-detectable Kafka topic management as code for disaster recovery scenarios.

## Technical Context

**Language/Version**: HCL (Terraform ≥ 1.3.0 — required for `optional()` in object constraints)
**Primary Dependencies**: `Mongey/kafka` provider ≥ 0.6.0 (`registry.terraform.io/Mongey/kafka`)
**Storage**: Terraform remote state per environment (S3 backend with DynamoDB locking — standard pattern, operator-configured)
**Testing**: `terraform validate`, `terraform plan` against a local or dev Kafka cluster; manual `kafka-topics.sh --describe` verification
**Target Platform**: AWS MSK (Kafka-compatible managed service); module is broker-agnostic at the Kafka protocol level
**Project Type**: Terraform module (infrastructure-as-code library)
**Performance Goals**: `terraform apply` for ≤ 50 topics completes in under 2 minutes
**Constraints**: Terraform ≥ 1.3.0; network reachability to MSK TLS endpoint (port 9094) required at plan/apply time
**Scale/Scope**: Designed for typical microservice platforms with 10–100 topics per environment

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

No project constitution has been defined (`constitution.md` is a blank template). Gates are derived from the feature requirements and Terraform community standards:

| Gate | Status | Notes |
|------|--------|-------|
| Module does not embed provider configuration | PASS | Provider block stays in caller root module |
| No hardcoded environment-specific values in the module | PASS | All env-specific values come via variables |
| `for_each` used (not `count`) for stable resource addressing | PASS | Map key = topic name → stable addresses |
| Secrets not stored in tfvars | PASS | SASL password via env var only |
| Terraform version constraint specified | PASS | `>= 1.3.0` in `versions.tf` |

## Project Structure

### Documentation (this feature)

```text
specs/001-msk-kafka-topics/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0: provider & pattern decisions
├── data-model.md        # Phase 1: entity definitions & state transitions
├── quickstart.md        # Phase 1: operator how-to guide
├── contracts/
│   └── module-interface.md   # Phase 1: module input/output contract
└── tasks.md             # Phase 2 output (/speckit.tasks — not yet created)
```

### Source Code (repository root)

```text
modules/
└── msk-topics/
    ├── main.tf          # kafka_topic.topics resource with for_each
    ├── variables.tf     # topics map variable definition
    ├── outputs.tf       # topic_names and topic_ids outputs
    └── versions.tf      # required_providers block (Mongey/kafka >= 0.6.0)

environments/
├── dev/
│   ├── main.tf          # module "msk_topics" call + provider "kafka" block
│   ├── variables.tf     # bootstrap_brokers, topics, optional sasl vars
│   ├── outputs.tf       # re-export topic_names for downstream use
│   ├── backend.tf       # S3 remote state (dev prefix)
│   └── terraform.tfvars # dev-specific broker endpoint and topic definitions
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── terraform.tfvars
└── production/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── backend.tf
    └── terraform.tfvars
```

**Structure Decision**: Terraform module library layout. The `modules/msk-topics` directory is the reusable component; `environments/` contains environment-specific root modules that call it. This separation ensures the module itself is environment-agnostic and the only per-environment variation lives in tfvars and backend configuration.

## Complexity Tracking

No constitution violations. Standard Terraform module pattern — no additional justification required.

## Phase 0: Research Findings

See [research.md](research.md) for full decision records. Summary:

| Decision | Choice | Key Reason |
|----------|--------|------------|
| Kafka Terraform provider | `Mongey/kafka` | Only provider supporting `kafka_topic` on AWS MSK with TLS/SASL |
| Authentication scope | TLS default, SASL/SCRAM opt-in | Covers all practical MSK auth modes; IAM deferred (requires unsupported client library) |
| Topic variable type | `map(object({...}))` with `optional()` | Stable resource addresses by name; enforces unique topic names at parse time |
| Environment separation | One root module per env | Strongest state isolation; Terragrunt-compatible if adopted later |
| Provider config placement | Caller root module only | Follows Terraform module design guidelines; enables per-environment broker config |

## Phase 1: Design Artifacts

### Module Core: `modules/msk-topics/main.tf`

```hcl
resource "kafka_topic" "topics" {
  for_each = var.topics

  name               = each.key
  partitions         = each.value.partitions
  replication_factor = each.value.replication_factor
  config             = each.value.config
}
```

### Module Variables: `modules/msk-topics/variables.tf`

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

### Module Outputs: `modules/msk-topics/outputs.tf`

```hcl
output "topic_names" {
  description = "List of all Kafka topic names managed by this module."
  value       = [for name, _ in var.topics : name]
}

output "topic_ids" {
  description = "Map of topic name to Terraform resource ID."
  value       = { for name, t in kafka_topic.topics : name => t.id }
}
```

### Module Version Lock: `modules/msk-topics/versions.tf`

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

### Environment Root Module: `environments/dev/main.tf`

```hcl
provider "kafka" {
  bootstrap_servers = split(",", var.bootstrap_brokers)
  tls_enabled       = true

  sasl_username  = var.sasl_username
  sasl_password  = var.sasl_password
  sasl_mechanism = var.sasl_mechanism
}

module "msk_topics" {
  source = "../../modules/msk-topics"
  topics = var.topics
}
```

### Environment Variables: `environments/dev/variables.tf`

```hcl
variable "bootstrap_brokers" {
  description = "Comma-separated MSK TLS or SASL bootstrap broker string."
  type        = string
}

variable "topics" {
  description = "Map of Kafka topic definitions."
  type = map(object({
    partitions         = number
    replication_factor = number
    config             = optional(map(string), {})
  }))
}

variable "sasl_username" {
  description = "SASL username. Leave empty for TLS-only auth."
  type        = string
  default     = ""
}

variable "sasl_password" {
  description = "SASL password. Provide via TF_VAR_sasl_password — never in tfvars."
  type        = string
  default     = ""
  sensitive   = true
}

variable "sasl_mechanism" {
  description = "SASL mechanism. Use 'scram-sha-256' or 'scram-sha-512'. Leave empty for TLS-only."
  type        = string
  default     = ""
}
```

### Environment tfvars: `environments/dev/terraform.tfvars` (example)

```hcl
bootstrap_brokers = "b-1.example.c2.kafka.us-east-1.amazonaws.com:9094,b-2.example.c2.kafka.us-east-1.amazonaws.com:9094"

topics = {
  "orders" = {
    partitions         = 6
    replication_factor = 1
    config = {
      "retention.ms"   = "86400000"
      "cleanup.policy" = "delete"
    }
  }
  "payments" = {
    partitions         = 12
    replication_factor = 1
    config = {
      "retention.ms"        = "604800000"
      "min.insync.replicas" = "1"
    }
  }
  "audit-log" = {
    partitions         = 3
    replication_factor = 1
    config = {
      "cleanup.policy" = "compact"
    }
  }
}
```

### Post-Design Constitution Re-check

All gates pass post-design. No violations introduced during Phase 1.

## Next Step

Run `/speckit-tasks` to generate the ordered task list for implementation.
