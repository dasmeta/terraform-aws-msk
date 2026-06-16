# Data Model: Correct Speckit Bootstrap Location

This change has no application data model. The "entities" are filesystem/repository structures:

## Speckit Bootstrap

- **Represents**: The `.specify/` directory (config, scripts, templates, memory/constitution) plus `.claude/skills/` (the `speckit-*` and `terraform-module-developer` command set).
- **Cardinality**: Exactly one per downstream module repository.
- **Location invariant**: Repository root only. Never nested inside a `modules/<name>/` directory.
- **Relationships**: Owns zero or more Feature Spec Packages under the root `specs/` directory.

## Feature Spec Package

- **Represents**: A `specs/<NNN>-<slug>/` directory documenting one unit of work (`spec.md`, optionally `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`, `tasks.md`, `checklists/`).
- **Cardinality**: One per Speckit feature; numbered sequentially (`001`, `002`, `003`, `004`, ...).
- **Location invariant**: Lives under the repository-root `specs/` directory, never under a `modules/<name>/specs/` path.
- **Identity**: The `NNN-slug` prefix is unique within the repository and matches the git branch created for that feature (e.g. `004-fix-speckit-bootstrap`).
- **State transitions**: Draft → Clarified (optional) → Planned → Tasked → Implemented. This feature (`004`) is currently at Planned, moving to Tasked next.

## Terraform Submodule Directory (`modules/msk-topics/`)

- **Represents**: Ordinary Terraform module source — not a Speckit-owned structure.
- **Invariant enforced by this change**: Contains only `*.tf` files, `README.md`, `examples/`, and local Terraform working-directory artifacts (`.terraform/`, `.terraform.lock.hcl`, both already covered by the root `.gitignore`). No `.specify/`, `.claude/`, `.gitignore`, or `.git`.
