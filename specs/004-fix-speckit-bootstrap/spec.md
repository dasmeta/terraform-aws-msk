# Feature Specification: Correct Speckit Bootstrap Location

**Feature Branch**: `004-fix-speckit-bootstrap`
**Created**: 2026-06-16
**Status**: Draft
**Input**: User description: "Correct Speckit bootstrap location for the msk-topics module. `.specify/`, `.claude/skills/`, and `specs/001-msk-kafka-topics`, `specs/002-registry-publish`, `specs/003-remove-provider-block` were mistakenly initialized inside `modules/msk-topics/` instead of at the repository root. This caused a stray embedded git repository, and a module-level `.gitignore` that duplicated the root `.gitignore` and hid `.claude/` and `.specify/` from version control. PR #23 reviewer flagged both symptoms. Remediation already applied in the working tree: moved `.specify/`, `.claude/skills/`, and `specs/001-003` to the repository root; deleted the stray embedded git repo; deleted the redundant `.gitignore`."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reviewer Sees a Coherent Speckit Trail (Priority: P1)

A PR reviewer opens a module-impacting pull request for `modules/msk-topics` and inspects the diff. The Speckit scaffold (`.specify/`, `.claude/skills/`) and the feature spec packages (`specs/<NNN>-<slug>/`) appear once, at the repository root, exactly where the repository's own `terraform-module-developer` convention says Speckit is bootstrapped for a downstream module repo. No nested `.gitignore` or embedded git repository exists under `modules/msk-topics/`.

**Why this priority**: This is the reviewer-visible defect that blocked PR #23 — without it, every future module PR repeats the same two review comments.

**Independent Test**: Open the repository at the tip of this branch and confirm `modules/msk-topics/` contains only module source files (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`, `examples/`) plus local Terraform artifacts (`.terraform/`, `.terraform.lock.hcl`); confirm `.specify/`, `.claude/skills/`, and `specs/001-msk-kafka-topics`, `specs/002-registry-publish`, `specs/003-remove-provider-block` exist at the repository root; confirm no `.git` directory exists under `modules/msk-topics/`.

**Acceptance Scenarios**:

1. **Given** the repository at this branch, **When** a contributor lists `modules/msk-topics/`, **Then** no `.specify/`, `.claude/`, `.gitignore`, or `.git` entries are present.
2. **Given** the repository at this branch, **When** a contributor lists the repository root, **Then** `.specify/`, `.claude/skills/`, and `specs/001-msk-kafka-topics`, `specs/002-registry-publish`, `specs/003-remove-provider-block` are present and tracked by git.
3. **Given** the relocated `specs/` packages, **When** a contributor diffs their content against the pre-move versions, **Then** the content is unchanged (pure relocation, no rewrites).

---

### User Story 2 - Future Module Work Bootstraps Speckit Correctly (Priority: P2)

A contributor adds a new submodule under `modules/` (or extends `msk-topics` further) and needs to run `/speckit.specify` for the first time. They run it from the repository root — not from inside the submodule directory — so Speckit never re-creates a nested `.git`, a duplicate `.gitignore`, or a misplaced `specs/` directory.

**Why this priority**: Prevents recurrence of the same defect for the next module or the next feature on this one.

**Independent Test**: Starting a new Speckit feature from the repository root produces `specs/00N-<slug>/` at the root and does not modify anything under any `modules/<name>/` directory except the Terraform files a task explicitly changes.

**Acceptance Scenarios**:

1. **Given** a contributor working at the repository root, **When** they run `/speckit.specify` for a new module change, **Then** the new spec package is created under the root `specs/` directory.
2. **Given** the repository's `terraform-module-developer` skill guidance, **When** a contributor reads it, **Then** it is unambiguous that Speckit bootstraps once per downstream module repository, not per submodule.

### Edge Cases

- What happens to the git history of the three pre-existing spec packages? They are relocated via `git mv` (rename-tracked), preserving content and history linkage rather than delete+recreate.
- What happens to the stray embedded git repository under `modules/msk-topics/.git`? It contained no commits relevant to the parent repository's history (a single unused "Initial commit from Specify template") and is deleted outright; no data is lost from the parent repository's perspective.
- What happens to local Terraform test artifacts (`.terraform/`, `.terraform.lock.hcl`) under `modules/msk-topics/`? They remain covered by the existing root `.gitignore` patterns (`**/.terraform/*`, `*.lock.hcl`); no new ignore rule is needed at the module level.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST have exactly one Speckit bootstrap (`.specify/` and `.claude/skills/`) located at the repository root.
- **FR-002**: `modules/msk-topics/` MUST NOT contain a `.specify/`, `.claude/`, `.gitignore`, or `.git` entry after this change.
- **FR-003**: The existing feature spec packages (`001-msk-kafka-topics`, `002-registry-publish`, `003-remove-provider-block`) MUST be preserved with unchanged content under the repository-root `specs/` directory.
- **FR-004**: `.specify/feature.json` MUST point to a valid `specs/<NNN>-<slug>/` path under the repository-root `specs/` directory.
- **FR-005**: The root `.gitignore` MUST continue to cover Terraform working-directory and state artifacts for all modules, including `modules/msk-topics/`, without a module-local `.gitignore` duplicate.

## Key Entities

- **Speckit bootstrap**: The `.specify/` configuration/scripts/templates directory and `.claude/skills/` command set that make `/speckit.*` commands available; must exist exactly once, at the repository root.
- **Feature spec package**: A `specs/<NNN>-<slug>/` directory (e.g. `spec.md`, `plan.md`, `tasks.md`) documenting one unit of module-impacting or repository-impacting work.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A reviewer inspecting the PR diff finds zero remaining comments about misplaced or missing Speckit artifacts under `modules/msk-topics/`.
- **SC-002**: `modules/msk-topics/` contains zero non-module files (no `.specify/`, `.claude/`, `.gitignore`, `.git`).
- **SC-003**: All three pre-existing spec packages remain readable and unchanged at their new root-level path, verified by zero content diff (renames only).

## Assumptions

- The repository root is the correct "downstream module repository" scope for Speckit, consistent with the bundled `terraform-module-developer` skill's `speckit-module-workflow.md` guidance.
- Settings such as `.claude/settings.local.json` remain personal/local and stay excluded from version control via the user's global git ignore, independent of this fix.
- No other open branch or PR depends on the now-removed `modules/msk-topics/.git` embedded repository (confirmed: it held no commits beyond the unused template-initialization commit).
