# Quickstart: Verify Speckit Bootstrap Correction

No `contracts/` directory is included for this feature — it has no external interface (API, CLI, or module consumer contract); it is a repository-structure correction only.

## Verification Steps

1. **Module directory is clean**

   ```bash
   ls -la modules/msk-topics
   ```

   Expect only: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`, `examples/`, plus local Terraform artifacts (`.terraform/`, `.terraform.lock.hcl`). No `.specify`, `.claude`, `.gitignore`, or `.git`.

2. **Speckit bootstrap is at the root**

   ```bash
   ls -la .specify .claude/skills specs
   ```

   Expect `.specify/`, `.claude/skills/`, and `specs/001-msk-kafka-topics`, `specs/002-registry-publish`, `specs/003-remove-provider-block`, `specs/004-fix-speckit-bootstrap`.

3. **No embedded git repository remains**

   ```bash
   find modules/msk-topics -maxdepth 1 -iname ".git"
   ```

   Expect no output.

4. **Relocated specs are renames, not rewrites**

   ```bash
   git diff --cached --stat | grep -E "^\s*\.\.\." # renamed entries show old -> new path
   ```

   Expect `renamed:` entries for every file under `specs/001-*`, `specs/002-*`, `specs/003-*`, with no content changes.

5. **Module still works**

   ```bash
   terraform -chdir=modules/msk-topics validate
   terraform -chdir=modules/msk-topics/examples/basic validate
   ```

   Expect both to pass, unchanged from before this fix (no `.tf` files were touched).

6. **Reviewer comments resolved**

   Confirm PR #23's two comments on `modules/msk-topics/.gitignore` (redundant ignore file; misplaced/incomplete-looking Speckit artifacts) are both addressed by the new diff and reply to the thread accordingly.
