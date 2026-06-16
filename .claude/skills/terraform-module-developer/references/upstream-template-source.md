# Terraform Module Developer Upstream Template Source

Use this reference only when new-module creation has no suitable provider-maintained module to wrap and direct resource-based scaffolding is required.

## Canonical Reference

- `reference_url`: `https://github.com/dasmeta/terraform-null-empty`
- `default_branch`: `main`
- `usage_scope`: fallback-only new-module scaffolding after provider-module lookup fails
- `refresh_expectation`: check the current upstream `HEAD` on `main` before using template-derived patterns
- `exception_note`: this fresh-reference rule is a deliberate exception to the repository's default preference for versioned upstream references and applies only after provider-module wrapper options are exhausted

## Last Verified Upstream State

- `verified_on`: `2026-03-12`
- `head_ref`: `refs/heads/main`
- `head_commit`: `fdc7bd8dd4d1dd5f37e1dddf77c0faf559382c39`

## How to Use It

1. Confirm the latest upstream `main` branch state before planning a new module.
2. Record that no suitable provider-maintained module was found in the approved AWS, Azure, or Google Cloud module collections for the request.
3. Inspect the module structure, standard file coverage, examples shape, tests layout, and repository automation patterns.
4. Inherit reusable patterns selectively for the fallback direct-resource path.
5. Apply internal standards first when the upstream scratch template and local standards differ.

## How to Refresh It

- Prefer checking the current upstream ref before each new-module scaffolding run.
- A lightweight check is `git ls-remote --symref https://github.com/dasmeta/terraform-null-empty HEAD`.
- If direct network access is unavailable, record that limitation and avoid claiming the upstream state is fresh.

## Guardrails

- Do not copy the upstream repository wholesale into this repository.
- Do not use this reference as the default starting point when a suitable provider-maintained module exists.
- Do not treat the upstream repository as the primary source for upgrade or extension work on existing modules.
- Do not let fresh upstream patterns override explicit internal standards without stating the difference in the plan.
