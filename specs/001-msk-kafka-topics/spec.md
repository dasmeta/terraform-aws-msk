# Feature Specification: AWS MSK Kafka Topic Provisioning Module

**Feature Branch**: `001-msk-kafka-topics`
**Created**: 2026-05-29
**Status**: Draft
**Input**: User description: "Create a separate Terraform module for AWS MSK Kafka topic provisioning."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Provision Topics on a Fresh Cluster (Priority: P1)

A platform engineer provisions a brand-new AWS MSK Kafka cluster and needs all required topics created automatically before any application connects. They run `terraform apply` inside the appropriate environment directory and all topics are created with the correct partition count, replication factor, and retention settings — without touching the Kafka broker or enabling auto topic creation.

**Why this priority**: This is the core disaster-recovery use case. Without it, applications start against an empty cluster and fail.

**Independent Test**: Can be fully tested by pointing the module at a real or local Kafka cluster, running `terraform apply`, and confirming each topic exists with the correct configuration via `kafka-topics.sh --describe`.

**Acceptance Scenarios**:

1. **Given** a fresh MSK cluster with no topics and a `terraform.tfvars` file listing 5 topic definitions, **When** `terraform apply` is executed in the `environments/dev` directory, **Then** all 5 topics are created with the exact partition count, replication factor, and config values defined in the tfvars file.
2. **Given** the same setup with `auto.create.topics.enable=false` on the MSK cluster, **When** `terraform apply` completes, **Then** all topics exist and applications can produce/consume without error.
3. **Given** `terraform apply` is re-run with no changes to the tfvars file, **Then** Terraform reports zero changes (idempotent).

---

### User Story 2 - Add a New Topic Without Touching Existing Ones (Priority: P2)

A developer needs to add a new Kafka topic for a new service. They add one entry to the `topics` map in the environment's `terraform.tfvars` and run `terraform plan` to confirm only one new topic will be created, then apply.

**Why this priority**: Safely extending the topic set without risk of modifying or destroying existing topics is critical for production stability.

**Independent Test**: Add one topic to tfvars, run `terraform plan`, verify exactly one resource addition is planned, apply, confirm the new topic exists and all prior topics are unchanged.

**Acceptance Scenarios**:

1. **Given** 5 existing topics already managed by Terraform, **When** one new entry is added to the `topics` map and `terraform plan` runs, **Then** the plan shows exactly 1 resource to add and 0 resources to change or destroy.
2. **Given** the plan is applied, **Then** the new topic exists on the cluster with correct config and all 5 pre-existing topics are unchanged.

---

### User Story 3 - Reuse Module Across Environments (Priority: P3)

A platform engineer maintains separate dev, staging, and production environments. Each environment calls the same `msk-topics` module but supplies different topic configs (e.g., lower retention in dev, higher replication in production) via its own `terraform.tfvars`.

**Why this priority**: Reusability across environments eliminates config drift and reduces maintenance overhead.

**Independent Test**: Deploy the module in two environments with different tfvars and verify each environment gets its own topic configuration independent of the other.

**Acceptance Scenarios**:

1. **Given** dev uses `replication_factor = 1` and production uses `replication_factor = 3` for the same topic name, **When** each environment's Terraform is applied independently, **Then** each cluster has its own topic with the correct replication factor for that environment.
2. **Given** a topic config change is made only in the staging tfvars, **When** staging is applied, **Then** only the staging topic is modified and dev/production are unaffected.

---

### Edge Cases

- What happens when a topic name in tfvars already exists on the broker but was created outside Terraform? Terraform import must be used; the module must not silently overwrite config.
- What happens when `replication_factor` exceeds the number of MSK broker nodes? The Kafka provider returns an error; Terraform surfaces it before any partial state is committed.
- What happens when the `bootstrap_brokers` variable points to an unreachable endpoint? The Kafka provider fails provider initialization; `terraform plan` fails with a connectivity error before any resources are touched.
- What happens when an optional config key has an invalid value (e.g., non-numeric `retention.ms`)? The Kafka broker rejects it; the provider surfaces the error and marks the resource as failed.
- What happens when a topic is removed from the tfvars map? Terraform plans a destroy for that topic; the operator must explicitly approve.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a reusable Terraform module named `msk-topics` that accepts a map of topic definitions as its primary input.
- **FR-002**: Each topic definition MUST support: topic name (map key), partition count, replication factor, and an optional map of broker-level config values (e.g., `retention.ms`, `cleanup.policy`).
- **FR-003**: The module MUST create all defined topics on the target Kafka cluster using a `for_each` pattern so each topic is independently addressable in Terraform state.
- **FR-004**: The module MUST NOT require Kafka auto topic creation to be enabled on the broker.
- **FR-005**: The module MUST accept the MSK bootstrap broker string as an input variable so it can be wired to the MSK cluster's Terraform output.
- **FR-006**: The module MUST be callable from environment-specific root modules (`environments/dev`, `environments/staging`, `environments/production`) each with their own `terraform.tfvars`.
- **FR-007**: Topic creation MUST be idempotent — repeated `terraform apply` with unchanged tfvars MUST produce zero changes.
- **FR-008**: The module MUST expose output values listing all managed topic names so downstream Terraform modules or CI pipelines can reference them.
- **FR-009**: The module MUST support TLS connectivity to MSK brokers; SASL/SCRAM authentication MUST be configurable via input variables.
- **FR-010**: All optional topic config values MUST default to empty (broker defaults) when not specified, so only explicitly set values are pushed to the broker.

### Key Entities

- **Topic Definition**: The logical description of a Kafka topic — name (map key), `partitions` (integer), `replication_factor` (integer), `config` (optional string-to-string map of broker topic configs).
- **MSK Cluster Reference**: The network endpoint — `bootstrap_brokers` string (TLS or plaintext, sourced from MSK Terraform output) used by the Kafka provider to connect.
- **Environment Root Module**: An environment-specific Terraform configuration (`environments/<env>/`) that instantiates the `msk-topics` module with environment-appropriate variable values.
- **Kafka Provider Configuration**: The provider block wiring broker endpoints, TLS settings, and auth credentials to the `msk-topics` module invocation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After a `terraform apply` against a fresh MSK cluster, 100% of topics defined in `terraform.tfvars` exist on the cluster within the same apply run — no manual broker interaction required.
- **SC-002**: A `terraform plan` with no tfvars changes reports zero additions, changes, or destructions (full idempotency).
- **SC-003**: Adding a single new topic to the tfvars map produces a plan with exactly 1 resource addition and 0 modifications or destructions to existing topics.
- **SC-004**: The module can be deployed independently to at least 3 environments (dev, staging, production) with different topic configurations, each environment converging to its own correct state.
- **SC-005**: A new team member can provision all topics in a new environment by following the quickstart guide in under 15 minutes with no prior Kafka CLI knowledge.

## Assumptions

- An AWS MSK cluster is already provisioned (by a separate Terraform root module) before the `msk-topics` module runs; the MSK bootstrap broker string is available as a Terraform output.
- Network connectivity between the machine running `terraform apply` (or the CI runner) and the MSK brokers exists (same VPC, Transit Gateway, or VPN).
- MSK is configured with TLS enabled; plaintext-only clusters are out of scope for the initial implementation.
- IAM-based MSK authentication is out of scope; SASL/SCRAM or TLS client certificate auth is used.
- Topic deletion (removing a topic from the map) is an intentional operator action and Terraform's standard destroy behavior is acceptable.
- The Terraform version in use supports the `optional()` modifier in object type constraints (Terraform ≥ 1.3).
- Each environment's Terraform state is stored independently (separate S3 backend prefixes or workspaces are managed by the operator).
