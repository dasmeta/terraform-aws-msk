# Implementation Plan: Correct Speckit Bootstrap Location

**Branch**: `004-fix-speckit-bootstrap` | **Date**: 2026-06-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-fix-speckit-bootstrap/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`specify init` was run inside `modules/msk-topics/` instead of at the repository root, bootstrapping a duplicate, mis-scoped Speckit installation (embedded `.git`, module-local `.gitignore`, `specs/` nested under the submodule). The fix relocates the one true Speckit bootstrap (`.specify/`, `.claude/skills/`) and the three existing feature packages (`specs/001-003`) to the repository root via `git mv` (history-preserving rename), deletes the stray embedded git repository and the redundant `.gitignore`, and leaves `modules/msk-topics/` containing only module source files. This is a structural/tooling correction with no Terraform behavior change.

## Technical Context

**Language/Version**: Terraform (HCL2); no application language involved — this change is repository structure/tooling only
**Primary Dependencies**: `specify` CLI 0.7.3 (Spec Kit), git
**Storage**: N/A — filesystem/git tree relocation only
**Testing**: `terraform validate` / `terraform fmt` at repo root and in `modules/msk-topics/examples/basic/` (already passing per the module's own PR checks; unaffected by this change since no `.tf` files are touched)
**Target Platform**: N/A (repository tooling, not a deployable artifact)
**Project Type**: Terraform module repository (single project; `modules/msk-topics/` is a submodule directory within it)
**Performance Goals**: N/A
**Constraints**: Must preserve git history/content of `specs/001-003` (rename, not delete+recreate); must not modify any `.tf` file under `modules/msk-topics/`; must not lose or corrupt PR #23's existing review thread
**Scale/Scope**: Single repository (`terraform-aws-msk`), one submodule (`modules/msk-topics`), 3 pre-existing spec packages relocated + 1 new spec package added

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is still the unfilled Spec Kit template (placeholder principles, never ratified for this repository) — there are no repository-specific constitution gates to evaluate. The applicable governance instead comes from the bundled `terraform-module-developer` skill (`speckit-module-workflow.md`): Speckit must be bootstrapped once at the downstream module repository root, not per-submodule. This plan implements exactly that correction, so it is gate-compliant by construction. No violations to record.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
terraform-aws-msk/                  # repository root — Speckit bootstrap lives here
├── .specify/                       # Speckit config, scripts, templates (relocated here)
├── .claude/skills/                  # speckit-* and terraform-module-developer skills (relocated here)
├── specs/                          # all feature packages, including this one
│   ├── 001-msk-kafka-topics/
│   ├── 002-registry-publish/
│   ├── 003-remove-provider-block/
│   └── 004-fix-speckit-bootstrap/   # this feature
├── main.tf / kafka.tf / kms.tf ...  # root-module Terraform files (untouched)
├── .gitignore                      # single repo-wide ignore file (already covers .terraform/, *.tfstate, *.lock.hcl, .idea/, .DS_Store)
└── modules/
    └── msk-topics/                  # submodule — Terraform source only after this change
        ├── main.tf / variables.tf / outputs.tf / versions.tf
        ├── README.md
        └── examples/basic/
```

**Structure Decision**: Single-repository Terraform module repo. Speckit bootstrap and all `specs/` packages live once at the repository root (matching `terraform-module-developer`'s downstream-module-repo convention). `modules/msk-topics/` keeps only Terraform source, README, and examples — no tooling/config directories, no nested `.gitignore`, no nested `.git`.

## Complexity Tracking

No Constitution Check violations — this section is not applicable.
