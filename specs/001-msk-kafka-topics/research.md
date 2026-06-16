# Research: AWS MSK Kafka Topic Provisioning Module

**Feature**: 001-msk-kafka-topics
**Date**: 2026-05-29

## Decision 1: Terraform Provider for Kafka Topic Management

**Decision**: Use the [`Mongey/kafka`](https://registry.terraform.io/providers/Mongey/kafka/latest) Terraform provider (`registry.terraform.io/Mongey/kafka`).

**Rationale**:
- The `Mongey/kafka` provider exposes the `kafka_topic` resource, which maps directly to Kafka's AdminClient API — the same mechanism used by `kafka-topics.sh`.
- It supports AWS MSK connectivity via TLS (port 9094) and SASL/SCRAM (port 9096), matching MSK's authentication options.
- Widely used in production for MSK topic management; actively maintained as of 2025.
- The provider requires only the broker bootstrap string and TLS/auth config — no AWS-specific credentials beyond what the Kafka broker requires.

**Alternatives considered**:
- `hashicorp/aws` provider: Has no `kafka_topic` resource. AWS MSK resources in this provider cover cluster lifecycle only (cluster, configuration, SCRAM secrets), not topic-level management.
- `aiven/kafka`: Tied to Aiven's managed Kafka service; cannot connect to self-managed or AWS MSK brokers.
- Custom script via `null_resource` + `local-exec` calling `kafka-topics.sh`: Works but produces no Terraform state — drift is undetectable, destroys are not modeled, and idempotency relies on shell script logic rather than Terraform's plan/apply cycle.

---

## Decision 2: MSK Connectivity and Authentication Scope

**Decision**: Support TLS (port 9094) as the default; make SASL/SCRAM (port 9096) opt-in via input variables. IAM authentication is excluded from v1.

**Rationale**:
- TLS-only authentication is the simplest MSK configuration and the most common starting point for new clusters.
- SASL/SCRAM provides user-level access control and is the recommended upgrade path for multi-team clusters; supporting it as opt-in covers the majority of production MSK setups.
- IAM authentication for Kafka clients requires the AWS MSK IAM Auth library in the Kafka client JAR — this is not available in the `Mongey/kafka` provider which uses the standard Kafka Go client. Supporting IAM would require a different provider or a sidecar approach, which is out of scope.

**Alternatives considered**:
- Plaintext (port 9092): Insecure; MSK clusters should have TLS enabled. Not supported as a primary mode.
- IAM: Would require a custom provider or `null_resource` workaround; deferred to a future iteration.

---

## Decision 3: Topic Map Structure and for_each Pattern

**Decision**: Use `map(object({...}))` keyed by topic name as the primary `topics` variable, with `for_each` iterating over it in the `kafka_topic` resource.

**Rationale**:
- Using the topic name as the map key gives each `kafka_topic` resource a stable, human-readable address in Terraform state (e.g., `module.msk_topics.kafka_topic.topics["orders"]`).
- `for_each` over a map (vs. a list) prevents resource address shifts when topics are added or removed in the middle of the list — a critical property for production safety.
- The `optional()` modifier (Terraform ≥ 1.3) allows the `config` field to be omitted entirely in tfvars, defaulting to `{}`, so simple topics need no boilerplate.

**Alternatives considered**:
- `list(object({...}))` with `for_each = { for t in var.topics : t.name => t }`: Adds a one-liner transform but introduces a footgun — duplicate names in the list silently cause a for expression error. The map type enforces uniqueness at the variable level.
- `count` over a list: Resource addresses become index-based (`kafka_topic.topics[0]`), making insertions or deletions in the middle of the list trigger unwanted destroys of subsequent topics.

---

## Decision 4: Environment Separation Strategy

**Decision**: One Terraform root module per environment under `environments/<env>/`, each calling the `msk-topics` module with its own `terraform.tfvars`. Separate remote state backends per environment.

**Rationale**:
- Separate root modules with separate state files provide the strongest blast-radius isolation — a broken apply in dev cannot affect production state.
- Each environment's tfvars file is the single source of truth for that environment's topic set, making diffs between environments readable in version control.
- This pattern is consistent with Terraform community best practices (Gruntwork Terragrunt, HashiCorp's own multi-environment guidance) and requires no additional tooling.

**Alternatives considered**:
- Terraform workspaces with a single root module: Workspaces share backend configuration and can accidentally target the wrong environment. The `${terraform.workspace}` variable in resource configs is error-prone. Not recommended for production isolation.
- Terragrunt: Adds abstraction and DRY benefits but introduces a dependency not everyone has installed. Out of scope for this module's v1; the directory structure chosen is Terragrunt-compatible if adopted later.

---

## Decision 5: Provider Configuration Placement

**Decision**: The `provider "kafka"` block lives in each environment's root module (not inside the `msk-topics` module itself), and is passed implicitly via Terraform's provider inheritance.

**Rationale**:
- Embedding provider configuration inside a module is a Terraform anti-pattern — it prevents callers from controlling provider versions, aliases, or credentials.
- Keeping the provider block in the root module lets each environment supply its own broker endpoint and credentials without forking the module.
- The `msk-topics` module declares only `required_providers` in `versions.tf`; the actual provider configuration is the caller's responsibility.

**Alternatives considered**:
- Provider configuration inside the module: Convenient for single-environment use but breaks reusability and violates Terraform's module design guidelines.
- Provider aliasing: Only needed when multiple Kafka clusters must be targeted in a single root module; not required for the standard one-cluster-per-environment pattern.
