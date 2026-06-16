---

description: "Task list for feature implementation"
---

# Tasks: Correct Speckit Bootstrap Location

**Input**: Design documents from `/specs/004-fix-speckit-bootstrap/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Not requested for this feature. Verification is via the `quickstart.md` checks instead of an automated test suite.

**Organization**: Tasks are grouped by user story to enable independent verification of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)

## Path Conventions

Single Terraform module repository. Paths are relative to the repository root (`terraform-aws-msk/`).

---

## Phase 1: Setup

**Purpose**: Confirm the already-applied relocation produced the expected repository-root layout.

- [X] T001 Verify `.specify/`, `.claude/skills/`, and `specs/001-msk-kafka-topics/`, `specs/002-registry-publish/`, `specs/003-remove-provider-block/`, `specs/004-fix-speckit-bootstrap/` exist at the repository root

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Confirm the submodule directory is clean before claiming either user story is satisfied.

**⚠️ CRITICAL**: Both user stories depend on this phase.

- [X] T002 Verify `modules/msk-topics/` contains no `.specify`, `.claude`, `.gitignore`, or `.git` entries
- [X] T003 [P] Verify the repository-root `.gitignore` still covers `.terraform/`, `*.tfstate`, `*.lock.hcl`, `.idea/`, and `.DS_Store` for every module, including `modules/msk-topics/`

**Checkpoint**: Foundation confirmed — user story verification/closeout can proceed.

---

## Phase 3: User Story 1 - Reviewer Sees a Coherent Speckit Trail (Priority: P1) 🎯 MVP

**Goal**: PR #23's diff shows the corrected, single Speckit bootstrap at the repository root, and both of the reviewer's comments on `modules/msk-topics/.gitignore` are resolved.

**Independent Test**: Open the repository at the tip of `004-fix-speckit-bootstrap` (or after it is merged into `feature/msk-topics`) and confirm the structure described in `spec.md`'s acceptance scenarios.

### Implementation for User Story 1

- [X] T004 [US1] Confirm `git diff --cached --stat` (or `git status`) shows `specs/001-*`, `specs/002-*`, `specs/003-*` as renames, not delete+add pairs
- [X] T005 [US1] Confirm `specs/004-fix-speckit-bootstrap/{spec.md,plan.md,research.md,data-model.md,quickstart.md,checklists/requirements.md}` are staged alongside the relocation
- [ ] T006 [US1] Commit the staged relocation and the `004-fix-speckit-bootstrap` spec package on branch `004-fix-speckit-bootstrap`
- [ ] T007 [US1] Merge (or fast-forward) `004-fix-speckit-bootstrap` into `feature/msk-topics` so the fix becomes part of PR #23
- [ ] T008 [US1] Push the updated `feature/msk-topics` to `origin` so PR #23 reflects the fix
- [ ] T009 [US1] Reply to reviewer `mrdntgrn`'s comment thread on `modules/msk-topics/.gitignore` in PR #23, explaining the correction and linking `specs/004-fix-speckit-bootstrap/spec.md`

**Checkpoint**: PR #23 diff is clean of the reported structural issues; reviewer thread has a response.

---

## Phase 4: User Story 2 - Future Module Work Bootstraps Speckit Correctly (Priority: P2)

**Goal**: The next module or feature in this repository never repeats the per-submodule Speckit bootstrap mistake.

**Independent Test**: A contributor reading `.claude/skills/terraform-module-developer/references/speckit-module-workflow.md` cannot reasonably conclude that Speckit should be initialized inside a `modules/<name>/` directory.

### Implementation for User Story 2

- [X] T010 [P] [US2] Re-read `.claude/skills/terraform-module-developer/references/speckit-module-workflow.md` and confirm it already states Speckit bootstraps once at the downstream module repository root (no edit needed if confirmed — this doc already shipped with that guidance)
- [ ] T011 [US2] Only if T010 finds a gap: clarify `.claude/skills/terraform-module-developer/references/speckit-module-workflow.md` to explicitly warn against running `specify init` inside a `modules/<name>/` subdirectory (N/A — T010 confirmed no gap; doc already scopes Speckit to the downstream repo root)

**Checkpoint**: Guidance is unambiguous for the next contributor; no further doc changes pending.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation that nothing else regressed.

- [ ] T012 [P] Run all six steps in `specs/004-fix-speckit-bootstrap/quickstart.md` end-to-end
- [X] T013 [P] Run `terraform validate` in `modules/msk-topics` and in `modules/msk-topics/examples/basic` to confirm no Terraform behavior changed

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS both user stories
- **User Story 1 (Phase 3)**: Depends on Foundational; no dependency on User Story 2
- **User Story 2 (Phase 4)**: Depends on Foundational; independent of User Story 1
- **Polish (Phase 5)**: Depends on both user stories being addressed

### Parallel Opportunities

- T003 can run in parallel with T002 (different file scopes)
- T010 can run in parallel with any Phase 3 task (different files)
- T012 and T013 can run in parallel with each other

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 — this alone resolves both reviewer comments on PR #23
4. **STOP and VALIDATE**: re-check PR #23's review thread

### Incremental Delivery

1. Setup + Foundational → confirms the already-applied relocation
2. User Story 1 → commit, merge into `feature/msk-topics`, push, reply to reviewer (closes PR #23's open comments)
3. User Story 2 → confirm/clarify guidance so this doesn't recur
4. Polish → quickstart + `terraform validate` sweep

---

## Notes

- Most of the filesystem relocation work was already performed in the working tree before this spec/plan/tasks package was authored; these tasks formalize verification and the remaining git/PR follow-through (commit, merge, push, reviewer reply).
- No tests were requested; `quickstart.md` (T012) serves as the verification pass instead.
- Avoid committing directly to `feature/msk-topics` for T006 — commit on `004-fix-speckit-bootstrap` first, then merge, to keep the Speckit evidence trail on its own feature branch per this repository's established pattern (matching how `001`–`003` were each tied to their own branch).
