# Feature Specification: Terraform Registry Publishing

**Feature Branch**: `002-registry-publish`
**Created**: 2026-06-03
**Status**: Draft
**Input**: Restructure the msk-topics Terraform module for Terraform registry publishing.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Publish Module to Terraform Registry (Priority: P1)

A platform engineer prepares the `msk-topics` Terraform module and publishes it to registry.terraform.io as `dasmeta/msk-topics/kafka` so that any consumer can reference it by registry source rather than a local path.

**Why this priority**: Without a published registry module, consumers cannot reference `source: dasmeta/msk-topics/kafka` in their wrapper YAMLs or Terraform configs. This is the foundational requirement for all downstream use.

**Independent Test**: Connect the GitHub repository to registry.terraform.io, tag `v1.0.0`, and confirm the module appears at `registry.terraform.io/modules/dasmeta/msk-topics/kafka` with correct inputs, outputs, and version listing.

**Acceptance Scenarios**:

1. **Given** the repository follows the `terraform-kafka-msk-topics` naming convention, **When** a version tag is pushed to GitHub, **Then** the Terraform registry automatically picks up the new version.
2. **Given** the module is published, **When** a consumer runs `terraform init` with `source = "dasmeta/msk-topics/kafka"`, **Then** Terraform downloads the correct module version without errors.
3. **Given** the module is at the repo root, **When** the registry indexes it, **Then** all input variables and outputs are correctly documented on the registry page.

---

### User Story 2 - Consumer Uses Module via Wrapper YAML (Priority: P2)

A platform engineer defines Kafka topics in a `wrappers/*.yaml` file in their infrastructure repository, referencing the published registry module. The DSL system resolves broker credentials from linked workspaces and applies the topic configuration.

**Why this priority**: This is the primary consumption pattern for DasMeta teams. The wrapper YAML approach is the standard way topics are managed across environments.

**Independent Test**: In an infrastructure repo, create a wrapper YAML with `source: dasmeta/msk-topics/kafka` and `version: 1.0.0`, run the DSL apply, and confirm the specified Kafka topics are created on the target MSK cluster.

**Acceptance Scenarios**:

1. **Given** a wrapper YAML referencing `dasmeta/msk-topics/kafka`, **When** the DSL system processes it, **Then** it resolves the module from the registry and applies all defined topics.
2. **Given** topics are defined in the wrapper, **When** a new topic entry is added and applied, **Then** only the new topic is created and existing topics remain unchanged.
3. **Given** credentials are injected from linked workspaces, **When** the module runs, **Then** no credentials appear in any committed file.

---

### User Story 3 - Example Validates Module Interface (Priority: P3)

A module contributor runs the `examples/basic/` example against the module to verify the interface works before publishing a new version.

**Why this priority**: Examples serve as living documentation and a local smoke-test before tagging a release. They ensure the module interface stays correct as it evolves.

**Independent Test**: Run `terraform validate` inside `examples/basic/` and confirm it exits 0 with no errors, verifying the example correctly calls the module interface.

**Acceptance Scenarios**:

1. **Given** the module files are at the repo root, **When** `terraform validate` runs in `examples/basic/`, **Then** it exits 0 with no configuration errors.
2. **Given** a module variable is renamed or removed, **When** the example is not updated, **Then** `terraform validate` fails with a clear error pointing to the mismatch.

---

### Edge Cases

- What happens when a consumer pins `version = "1.0.0"` and a breaking change is released as `2.0.0`? → Pinned consumers are unaffected; they must explicitly upgrade.
- What happens if the GitHub repo is renamed away from the `terraform-kafka-msk-topics` convention? → The registry entry breaks; repo name must not change after registration.
- What if `terraform init` is run in the module root directly? → It should succeed since the module is valid HCL at root, but there is no backend — this is expected for a module library.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The module source files (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `providers.tf`) MUST reside at the repository root, not in a subdirectory.
- **FR-002**: The repository MUST be named `terraform-kafka-msk-topics` to satisfy the Terraform registry naming convention for provider `kafka`, module name `msk-topics`.
- **FR-003**: Consumer-only files (`kafka_topics.tf` and any root-level variables/versions files added solely for direct-apply use) MUST be removed from the repository root.
- **FR-004**: The `examples/basic/` directory MUST remain at the repository root level and its module source reference MUST resolve to the repo root module.
- **FR-005**: The module MUST carry a semantic version tag (e.g., `v1.0.0`) for the Terraform registry to index a usable version.
- **FR-006**: The `wrappers/dev.yaml` and `wrappers/prod.yaml` files MUST reference `source: dasmeta/msk-topics/kafka` and a pinned `version` matching the published release.
- **FR-007**: The module MUST pass `terraform validate` at the repo root after restructuring.
- **FR-008**: The `README.md` MUST document the registry source string, required inputs, outputs, and at least one usage example.

### Key Entities

- **Module root**: The repository root directory containing all Terraform module files.
- **Registry entry**: The published module record at `registry.terraform.io/modules/dasmeta/msk-topics/kafka`.
- **Wrapper YAML**: A per-environment DSL file in the consumer infrastructure repository that references the registry module and supplies topic definitions and credentials.
- **Version tag**: A Git tag in `vX.Y.Z` format that triggers the Terraform registry to index a new module version.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `terraform validate` exits 0 at the repository root with no errors or warnings.
- **SC-002**: `terraform validate` exits 0 in `examples/basic/` with no errors or warnings.
- **SC-003**: The module appears on `registry.terraform.io` under `dasmeta/msk-topics/kafka` with version `1.0.0` within 5 minutes of the version tag being pushed.
- **SC-004**: A consumer running `terraform init` with `source = "dasmeta/msk-topics/kafka"` and `version = "1.0.0"` downloads the module successfully with no manual steps.
- **SC-005**: The repository contains no files with client-specific or customer-specific names (naming policy compliance).

## Assumptions

- The `dasmeta` GitHub organisation exists and the publisher has admin rights to create the `terraform-kafka-msk-topics` repository under it.
- The Terraform registry account is linked to the `dasmeta` GitHub organisation.
- The `Mongey/kafka` provider is available on the public Terraform registry and remains the correct provider for MSK topic management.
- The module will use `v1.0.0` as the initial published version.
- No Terraform backend configuration is needed in the module itself — backend configuration belongs in the consumer's root module.
- The `wrappers/` directory in this repository serves as reference examples for consumers; the actual wrapper files used by consumers live in their own infrastructure repositories.
