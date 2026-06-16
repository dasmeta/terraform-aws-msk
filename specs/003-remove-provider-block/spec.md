# Feature Specification: Remove Embedded Provider Block

**Feature Branch**: `003-remove-provider-block`
**Created**: 2026-06-15
**Status**: Draft
**Input**: Remove embedded provider block from msk-topics module; caller configures kafka provider; README leads with minimal Terraform example.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Caller-Owned Provider Configuration (Priority: P1)

A platform engineer consumes the `msk-topics` module and configures the `kafka` provider in their root module (or example), passing only `topics` to the module. Broker connectivity and SASL credentials stay at the caller level per Terraform best practice.

**Why this priority**: Embedded provider blocks in child modules prevent callers from controlling provider versions, aliases, and credentials. This is the core correction.

**Independent Test**: Inspect the module repository — no `provider "kafka"` block exists in module files. The module accepts only `topics`. `terraform validate` passes at repo root and in `examples/basic/`.

**Acceptance Scenarios**:

1. **Given** the module at repo root, **When** a contributor inspects `.tf` files, **Then** no `provider "kafka"` block is present in the module.
2. **Given** a root module with a configured `kafka` provider, **When** the engineer calls the module with `topics` only, **Then** Terraform plans topic resources without requiring broker variables on the module.
3. **Given** the refactored module, **When** `terraform validate` runs at repo root, **Then** it exits 0.

---

### User Story 2 - Minimal README Example (Priority: P2)

A module consumer opens `README.md` and finds a copy-pasteable minimal Terraform example showing provider configuration plus a module call — not just a source/version block.

**Why this priority**: DasMeta module READMEs should show how to use the module immediately. Source/version alone is insufficient.

**Independent Test**: Open `README.md` — the first usage section contains a complete minimal HCL example with `provider "kafka"` and `module "msk_topics"` passing only `topics`.

**Acceptance Scenarios**:

1. **Given** the updated README, **When** a consumer reads the top usage section, **Then** they see provider + module call in one snippet.
2. **Given** the updated README, **When** inspected for inputs documentation, **Then** only `topics` is listed as a module input (broker/SASL vars are documented as caller responsibility).
3. **Given** the updated README, **When** inspected for wrapper YAML, **Then** no YAML wrapper usage section is present.

---

### User Story 3 - Example Validates Caller Pattern (Priority: P3)

A contributor runs `examples/basic/` to verify the caller-owned provider pattern before tagging a release.

**Why this priority**: Examples are living documentation and smoke tests for the module interface.

**Independent Test**: Run `terraform validate` in `examples/basic/` — exits 0. Example contains `providers.tf` at example root; module call passes only `topics`.

**Acceptance Scenarios**:

1. **Given** `examples/basic/providers.tf` with kafka provider config, **When** `terraform validate` runs, **Then** it exits 0.
2. **Given** the example `main.tf`, **When** inspected, **Then** the module block does not pass `bootstrap_brokers` or SASL variables.

---

### Edge Cases

- What if `v1.0.0` was already published with broker/SASL module variables? → Requires `v2.0.0` major bump; document breaking change.
- What if caller forgets to configure the kafka provider? → `terraform plan` fails with provider configuration error before any resources are touched.
- What about existing wrapper YAML files in `wrappers/`? → Out of scope; not updated or documented in README for this feature.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The module MUST NOT contain a `provider "kafka"` configuration block.
- **FR-002**: The module MUST declare `required_providers` for `kafka` in `versions.tf` only.
- **FR-003**: The module input surface MUST be limited to `topics` (remove `bootstrap_brokers`, `sasl_username`, `sasl_password`, `sasl_mechanism`).
- **FR-004**: `examples/basic/` MUST configure the `kafka` provider at the example root and pass only `topics` to the module.
- **FR-005**: `README.md` MUST lead with a minimal copy-pasteable Terraform example (provider + module call).
- **FR-006**: `README.md` MUST NOT include YAML wrapper usage examples.
- **FR-007**: `terraform validate` MUST exit 0 at repo root and in `examples/basic/`.
- **FR-008**: Feature supersedes Decision 3 in `specs/002-registry-publish/plan.md` (embedded provider bounded exception).

### Key Entities

- **Module interface**: `topics` input, `topic_names` and `topic_ids` outputs.
- **Caller provider config**: Broker endpoints, TLS, and SASL credentials configured outside the module.
- **Module contract**: Documented in `specs/003-remove-provider-block/contracts/module-interface.md`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `terraform validate` exits 0 at repository root.
- **SC-002**: `terraform validate` exits 0 in `examples/basic/`.
- **SC-003**: Module `.tf` files contain zero `provider "kafka"` blocks.
- **SC-004**: README contains a minimal Terraform example as the primary usage section within the first 50 lines of usage content.
- **SC-005**: Module variables table documents only `topics` as input.

## Assumptions

- `v1.0.0` has not been published to the Terraform registry; interface correction ships before first public tag.
- Wrapper YAML files in `wrappers/` are out of scope and remain unchanged.
- The `Mongey/kafka` provider remains the correct provider for MSK topic management.
- Callers use implicit provider inheritance (default `kafka` provider passed to child module).
