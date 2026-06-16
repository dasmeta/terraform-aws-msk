# Implementation Plan: Terraform Registry Publishing

**Branch**: `002-registry-publish` | **Date**: 2026-06-03 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-registry-publish/spec.md`

## Summary

Prepare the `msk-topics` Terraform module for publication to registry.terraform.io as `dasmeta/msk-topics/kafka`. The repository must be restructured so module files live at the root (not in `modules/msk-topics/`), consumer-only files removed, a README.md restored, and a `v1.0.0` git tag applied before connecting the GitHub repository to the Terraform registry.

## Technical Context

**Language/Version**: HCL (Terraform `~> 1.3` — required for `optional()` in object type constraints)
**Primary Dependencies**: `Mongey/kafka` provider `~> 0.6` (`registry.terraform.io/Mongey/kafka`)
**Storage**: Terraform remote state per consumer environment (S3 + DynamoDB locking — operator-configured, not part of this module)
**Testing**: `terraform validate` at repo root and in `examples/basic/`; manual `kafka-topics.sh --describe` at apply time
**Target Platform**: registry.terraform.io (public Terraform registry); consumed by AWS MSK deployments
**Project Type**: Terraform module library published to public registry
**Performance Goals**: `terraform apply` for ≤ 50 topics completes under 2 minutes
**Constraints**: Terraform `~> 1.3`; GitHub repository must be named `terraform-kafka-msk-topics`; module files must be at repo root for registry indexing
**Scale/Scope**: 10–100 Kafka topics per environment; consumed by multiple DasMeta infrastructure repositories

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

No project constitution has been defined (constitution.md contains only the blank template). Gates are derived from the `terraform-module-developer` skill's internal standards and Terraform registry requirements:

| Gate | Status | Notes |
|------|--------|-------|
| Module files at repository root for registry indexing | PASS | Files moved to root in current session |
| No consumer-only files at repository root | PASS | `kafka_topics.tf` and consumer `variables.tf`/`versions.tf` removed |
| README.md present and documents module interface | FAIL → TO FIX | README.md was lost during restructure; must be recreated |
| `examples/basic/` resolves to module root via `../../` | PASS | Path confirmed correct after move |
| Version tag exists for registry indexing | FAIL → TO FIX | No git tag yet; `v1.0.0` required |
| GitHub repo named `terraform-kafka-msk-topics` | PENDING | Requires GitHub repo creation |
| Naming policy: no client-specific names in `.tf` files | PASS | `kafka_topics_payconomy_manual.tf` renamed to `kafka_topics.tf` then removed |
| `terraform validate` exits 0 at repo root | PASS | Confirmed in current session |

## Project Structure

### Documentation (this feature)

```text
specs/002-registry-publish/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0: registry requirements and provider decisions
├── contracts/
│   └── module-interface.md   # Phase 1: module input/output contract
└── tasks.md             # Phase 2 output (/speckit-tasks — not yet created)
```

### Source Code (repository root)

```text
terraform-kafka-msk-topics/    ← GitHub repo name
├── main.tf                    # kafka_topic.topics resource with for_each
├── variables.tf               # bootstrap_brokers, sasl vars, topics map
├── outputs.tf                 # topic_names, topic_ids
├── versions.tf                # required_version ~> 1.3, required_providers
├── providers.tf               # kafka provider configuration (internal pattern)
├── README.md                  # Registry documentation: usage, inputs, outputs
├── .terraform.lock.hcl        # Provider version lock (committed)
├── examples/
│   └── basic/
│       ├── main.tf            # Example module call with sample topics
│       ├── variables.tf       # bootstrap_brokers, sasl vars
│       ├── outputs.tf         # topic_names output
│       └── versions.tf        # required_version and required_providers
└── wrappers/
    ├── dev.yaml               # Reference wrapper for dev environment (DSL pattern)
    └── prod.yaml              # Reference wrapper for prod environment (DSL pattern)
```

**Structure Decision**: Standard Terraform registry module layout. Module files at repository root; `examples/` for usage demonstration and local validation; `wrappers/` for DasMeta DSL consumers (reference only — consumers copy these to their infrastructure repos).

## Complexity Tracking

No constitution violations requiring justification.

---

## Phase 0: Research Findings

### Decision 1 — Upstream module sourcing

**Decision**: Direct resource-based module using `Mongey/kafka` provider. No wrapper around an upstream provider module.

**Rationale**: No `terraform-aws-modules`, `terraform-azure-modules`, or `terraform-google-modules` equivalent exists for Kafka topic management. Kafka topic provisioning is provider-specific (not an AWS/Azure/GCP resource), and the `Mongey/kafka` provider is the only Terraform provider supporting `kafka_topic` resources compatible with AWS MSK. Direct resource creation is the correct fallback per the `terraform-module-developer` skill source order.

**Alternatives considered**: None viable — no provider-maintained module collection covers this use case.

**Modern Capabilities classification**: `kafka_topic` resource via `Mongey/kafka` provider — **supported** (non-deprecated path as of provider `v0.13.1`).

---

### Decision 2 — Terraform registry naming convention

**Decision**: Repository named `terraform-kafka-msk-topics`.

**Rationale**: Terraform registry maps `<NAMESPACE>/<MODULE>/<PROVIDER>` source addresses to GitHub repositories named `terraform-<PROVIDER>-<MODULE>`. For `dasmeta/msk-topics/kafka`: namespace=`dasmeta`, module=`msk-topics`, provider=`kafka` → repo name `terraform-kafka-msk-topics`.

**Alternatives considered**: Keeping repo named `msk-topics` — not viable; the registry would not index it under the correct source address.

---

### Decision 3 — Provider configuration placement

**Decision**: Provider configuration (`providers.tf`) stays in the module root.

**Rationale**: The DasMeta wrapper DSL pattern requires the module to be self-contained. Consumers pass `bootstrap_brokers` and SASL credentials directly to the module via variables; the module configures the `kafka` provider internally. This is the intentional design for the wrapper consumption pattern, documented as a bounded exception to the Terraform guideline of keeping provider config in root modules.

**Bounded exception record**: Provider config in child module is deprecated since Terraform 0.15 but functional. Exception is bounded to this module only. Consumers using the wrapper DSL cannot configure providers independently; the module must own it.

---

### Decision 4 — Version strategy

**Decision**: `v1.0.0` as initial published version using semantic versioning.

**Rationale**: Terraform registry requires `vX.Y.Z` git tags. Starting at `v1.0.0` signals a stable public interface. Future interface changes increment MINOR (backward-compatible additions) or MAJOR (breaking changes).

---

## Phase 1: Design Artifacts

### Module Interface Contract (see `contracts/module-interface.md`)

**Inputs:**

| Variable | Type | Required | Default | Description |
|---|---|---|---|---|
| `bootstrap_brokers` | `string` | Yes | — | Comma-separated MSK SASL/SCRAM broker endpoints (port 9096) |
| `sasl_username` | `string` | No | `""` | SASL/SCRAM username |
| `sasl_password` | `string` (sensitive) | No | `""` | SASL/SCRAM password — pass via secret manager, never hardcode |
| `sasl_mechanism` | `string` | No | `"scram-sha-512"` | SASL mechanism: `scram-sha-256` or `scram-sha-512` |
| `topics` | `map(object)` | Yes | — | Map of topic definitions; key = topic name |

**Topic object shape:**
```hcl
object({
  partitions         = number
  replication_factor = number
  config             = optional(map(string), {})
})
```

**Outputs:**

| Output | Type | Description |
|---|---|---|
| `topic_names` | `list(string)` | Names of all managed topics |
| `topic_ids` | `map(string)` | Map of topic name → Terraform resource ID |

### Post-Design Constitution Re-check

All gates pass post-design. README.md and version tag are the only remaining open items — both addressed in tasks.

## Next Step

Run `/speckit-tasks` to generate the ordered task list for completing the registry publishing work.
