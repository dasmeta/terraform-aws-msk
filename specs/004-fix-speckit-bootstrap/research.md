# Research: Correct Speckit Bootstrap Location

No `[NEEDS CLARIFICATION]` markers were left in `spec.md`. This document records the decisions behind the chosen remediation approach.

## Decision: Relocate via `git mv`, not delete-and-recreate

**Rationale**: `specs/001-msk-kafka-topics`, `specs/002-registry-publish`, and `specs/003-remove-provider-block` are tracked, reviewed history. Using `git mv` (or an equivalent move that git's rename detection picks up) preserves blame/history continuity and produces a diff that reviewers can read as "moved", not "deleted 21 files / added 21 files".

**Alternatives considered**:
- Delete `modules/msk-topics/specs/` and hand-author fresh files at the root — rejected: destroys history and risks silent content drift during retyping.
- Leave specs where they are and only fix the `.gitignore`/embedded-git issues — rejected: does not address the reviewer's second comment (specs nested under the submodule instead of at the repository root), and perpetuates the wrong convention for the next module.

## Decision: Delete the embedded `modules/msk-topics/.git` outright

**Rationale**: Inspection showed this nested repository contained exactly one commit ("Initial commit from Specify template") and a branch named `003-remove-provider-block` that was never pushed anywhere and never consumed by the parent repository (the parent repository's history is built entirely from blobs committed directly into `terraform-aws-msk`'s own `.git`, since `git ls-tree` shows `modules/msk-topics` as a normal `040000 tree`, not a `160000` gitlink). There is no real history to preserve.

**Alternatives considered**:
- Convert it into a real git submodule — rejected: out of scope and not what the original work intended; `modules/msk-topics` is meant to be an ordinary subdirectory of this monorepo.

## Decision: Remove `modules/msk-topics/.gitignore` rather than trim it

**Rationale**: Reviewer (PR #23) asked directly: remove it if there's no special need. Every Terraform/editor/OS pattern it contained (`*.tfstate`, `.terraform/`, override files, `.idea/`, `.DS_Store`) is already covered by the repository-root `.gitignore`. Its two genuinely module-local entries (`.claude/`, `.specify/`) only existed because Speckit had been (incorrectly) bootstrapped inside the module in the first place — once that bootstrap moves to the root, those entries are moot.

**Alternatives considered**:
- Keep a trimmed module-level `.gitignore` with just `.vscode/`, `*.swp`, `*.swo` — rejected: not requested, and root `.gitignore` is the single established place for repo-wide ignore rules in this project; adding editor-specific patterns there instead is a trivial, low-risk follow-up if ever needed, not a reason to keep a per-module file now.

## Decision: No data migration tooling needed

**Rationale**: This is a one-time, already-applied filesystem/git-tree relocation within a single working tree. There is no recurring migration, no multi-environment rollout, and no runtime component — `tasks.md` only needs to capture verification steps, not a build pipeline.
