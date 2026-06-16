# Implementation Plan: Remove Embedded Provider Block

**Branch**: `003-remove-provider-block` | **Date**: 2026-06-15 | **Spec**: [spec.md](spec.md)
**Input**: Remove embedded provider block from msk-topics; caller configures kafka provider; minimal README example.

## Summary

Align the `msk-topics` module with Terraform and dasmeta standards by deleting [`providers.tf`](../../providers.tf), narrowing module inputs to `topics` only, moving kafka provider configuration to `examples/basic/`, and rewriting [`README.md`](../../README.md) with a minimal copy-paste Terraform example. Supersedes Decision 3 in [002 plan](../002-registry-publish/plan.md).

## Technical Context

**Language/Version**: HCL (Terraform `~> 1.3`)
**Primary Dependencies**: `Mongey/kafka` provider `~> 0.6`
**Testing**: `terraform validate` at repo root and `examples/basic/`
**Target Platform**: registry.terraform.io (`dasmeta/msk-topics/kafka`)
**Project Type**: Terraform module library
**Constraints**: No provider block in module; wrapper YAML out of scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| No provider block in child module | PASS → TO FIX | `providers.tf` will be deleted |
| `required_providers` in `versions.tf` only | PASS | Already correct |
| README with copy-pasteable example | FAIL → TO FIX | Rewrite README |
| `terraform validate` at root and example | PASS → VERIFY | Re-run after changes |
| Module inputs minimal (`topics` only) | FAIL → TO FIX | Remove broker/SASL vars |

## Project Structure

### Documentation (this feature)

```text
specs/003-remove-provider-block/
├── spec.md
├── plan.md              # This file
├── research.md
├── tasks.md
├── quickstart.md
├── contracts/
│   └── module-interface.md
└── checklists/
    └── requirements.md
```

### Source changes

```text
terraform-kafka-msk-topics/
├── main.tf              # unchanged
├── variables.tf         # topics only
├── outputs.tf           # unchanged
├── versions.tf          # unchanged
├── providers.tf         # DELETE
├── README.md            # minimal example first
└── examples/basic/
    ├── providers.tf     # NEW — kafka provider at example root
    ├── main.tf          # topics-only module call
    └── variables.tf     # broker/SASL for provider (unchanged vars)
```

## Phase 0 Decisions

See [research.md](research.md). Key supersession: 002 Decision 3 (embedded provider) is reverted.

## Phase 1: Module Interface Contract

See [contracts/module-interface.md](contracts/module-interface.md).

**Inputs**: `topics` only
**Outputs**: `topic_names`, `topic_ids` (unchanged)
**Provider**: Caller's responsibility — see [quickstart.md](quickstart.md)
