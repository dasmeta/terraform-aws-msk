---
name: terraform-module-developer
description: Use when creating, standardizing, or extending a Terraform module. Defaults to Speckit-first workflow (/speckit.specify, clarify, plan, tasks, implement) in the downstream module repository before editing module files, plus dasmeta standards, wrapper guidance, and approval gates
---

# Terraform Module Developer

## Overview

Use this skill when a Terraform module needs to be created, brought up to internal standards, or extended for a new use case. Internal dasmeta standards come first, modules should preserve DasMeta's opinionated wrapper pattern, shared cross-repository governance must come from the constitution repository, direct resource-based creation is fallback-only, and no conflict or breaking change should be applied silently. Module-impacting work must be Speckit-first: before editing module source, interface, examples, tests, behavior-affecting usage documentation, or module automation, create or update the downstream repository's Speckit package and record the Speckit evidence in the pre-change plan. When shaping the consumer interface, prefer grouped object variables over many flat top-level variables when grouping is safe, and represent non-critical attributes as optional fields (using Terraform's optional attribute mechanism when supported). When repository-local Terraform layout conventions are already established across the target repo or closely related DasMeta module repos, preserve those conventions instead of forcing a generic default layout.

Read [references/speckit-module-workflow.md](references/speckit-module-workflow.md) first for default Speckit command routing, then [references/internal-module-standards.md](references/internal-module-standards.md), [references/upstream-template-source.md](references/upstream-template-source.md), and [references/planning-checklist.md](references/planning-checklist.md) before planning or editing. When a managed repository requires the `speckit-module-change-gate`, use the downstream module repository's Speckit evidence as part of the planning baseline rather than treating the gate as an after-the-fact CI concern.

## Default Speckit-first workflow

For **module-impacting** work in a downstream Terraform module repository, **do not start by editing** `main.tf`, `variables.tf`, examples, or tests. **Start with Speckit** unless a documented skip condition in [references/speckit-module-workflow.md](references/speckit-module-workflow.md) applies.

### On a new user request

1. Confirm the **downstream module repository** (working directory), not the constitution repository.
2. If no `specs/<NNN>-<slug>/` package exists for this request, run **`/speckit.specify`** using the user's message as the feature description.
3. Report the created feature directory, branch (if any), and recommend **`/speckit.clarify`** or **`/speckit.plan`** as the next step.
4. Apply [references/planning-checklist.md](references/planning-checklist.md) and module standards only inside the Speckit plan/spec context until **`/speckit.implement`** (or explicit user approval to implement early).

### When the user continues the same request

Advance the Speckit chain in the **same downstream repository** based on what they ask for or say (e.g. "continue", "plan it", "implement"):

| Stage | Command |
|-------|---------|
| Refine requirements | `/speckit.clarify` |
| Technical plan | `/speckit.plan` |
| Task breakdown | `/speckit.tasks` |
| Apply module changes | `/speckit.implement` |

If the user describes a **new unrelated** module feature, run **`/speckit.specify`** again rather than reusing the previous package.

Minimum evidence before module-impacting edits: `spec.md`, `plan.md`, and `tasks.md` under the active `specs/<NNN>-<slug>/` directory.

## When to Use

- A user asks to create a new Terraform module for a provider or infrastructure capability.
- A module already exists and needs cleanup, standardization, or missing file coverage.
- A module needs support for a new feature, resource pattern, or provider-specific capability.
- The request mentions `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `providers.tf`, `locals.tf`, `README.md`, `examples/`, `tests/`, or repository automation files.

Do not use this skill for ad hoc Terraform root configuration, non-module repositories, or broad git/release automation by default.

## Source Order

1. Start with [references/internal-module-standards.md](references/internal-module-standards.md).
2. For new-module creation, inspect approved provider-maintained module collections before considering direct resource-based creation:
   - `https://github.com/terraform-aws-modules`
   - `https://github.com/Azure/terraform-azure-modules`
   - `https://github.com/terraform-google-modules`
3. If a suitable upstream provider module exists, design the local module as an opinionated wrapper around that lower-level module with a smaller consumer interface, predefined defaults, preconfiguration, and validated variable sets.
4. Inspect the target repository and closely related DasMeta module repos for layout conventions that should be preserved, especially around `versions.tf`, `providers.tf`, example/test structure, and Terraform version-constraint style.
5. For shared standards, rules, and conventions that apply across repositories, use the constitution repository as the single source of truth instead of restating those rules locally inside an individual module repository.
6. Use [references/upstream-template-source.md](references/upstream-template-source.md) only when no suitable provider-maintained module exists and the request must fall back to direct resource-based scaffolding.
7. Use official Terraform or OpenTofu documentation and widely accepted community conventions only when the bundled references are insufficient.

## Workflow

1. Inspect the current repository module scope: current module, related submodules, relevant repository automation files in the same repository, and nearby DasMeta module repos when repository-local conventions are likely relevant.
2. **Speckit (default)**: In the downstream module repo, run **`/speckit.specify`** on a new module-impacting request; on continuation run **`/speckit.clarify`**, **`/speckit.plan`**, **`/speckit.tasks`**, then **`/speckit.implement`** as appropriate. See [references/speckit-module-workflow.md](references/speckit-module-workflow.md). Require `spec.md`, `plan.md`, and `tasks.md` under `specs/<NNN>-<slug>/` before editing module-impacting files.
3. Draft or update the pre-change plan using Speckit `plan.md`/`tasks.md` where present, [templates/module-plan-outline.md](templates/module-plan-outline.md) when helpful, and the required checks in [references/planning-checklist.md](references/planning-checklist.md).
4. For a new module, inspect the approved provider-maintained module collection for the target cloud and record which candidate modules were considered.
5. If a suitable upstream module exists, choose the module whose scope is closest to the requested wrapper module and document how the local module improves usability through a narrower consumer interface (including grouping related inputs into grouped object variables when safe), defaults, preconfiguration, and validated inputs.
6. For an existing module, compare current files and behavior against internal standards, the wrapper pattern, and established repository-local layout conventions before proposing edits.
7. When the request needs shared cross-repository governance, source that guidance from the constitution repository and keep local repository guidance limited to repository-specific details.
8. If no suitable upstream module exists, document the fallback decision before considering direct resource-based scaffolding from the upstream template reference.
9. Stop and present conflicts when the existing module, selected baseline, or local governance guidance disagrees with internal standards or constitution-repository standards.
10. If a breaking change or interface-widening change is cleaner, explain the tradeoff and wait for explicit approval before applying it.
11. Update documentation, examples, tests, and related scaffolding alongside the module change.

## Modern Capabilities Rule

Before designing net-new module abilities, apply the **Modern Capabilities Rule** from [references/internal-module-standards.md](references/internal-module-standards.md#modern-capabilities).

### When the rule is active

- **create mode**: Classify every net-new ability as supported, replaced, or exempted in the pre-change plan.
- **extend mode**: Apply only to wholly net-new abilities when the module's **minimum supported provider version** already supports the modern capability; otherwise record `out_of_scope_provider_bound` in the plan.
- **improve mode** and extend work without net-new abilities: Rule is **not** active—preserve established interfaces; do not require deprecation-only refactors.

Raising minimum supported provider version in the same change still limits rule scope to the net-new ability only—not established interfaces.

### Deprecation authority

- **Primary**: Provider/platform documentation.
- **Secondary** (wrapper modules): Upstream README/changelog deprecation notices.

Prefer supported replacements over deprecated capabilities when designing net-new abilities. Record a bounded exception in the plan when no supported alternative exists or repository capability constraints block the modern path.

## Naming and Hostname Policy (Terraform Artifacts)

- Do not use client-specific or customer-specific names or hostnames in Terraform-related content.
- This policy applies to Terraform code blocks, Terraform configuration snippets, comment blocks, examples, and tests.
- Allowed naming should use `dasmeta` context or generic placeholders such as `example`, `test`, `sample`, `demo`, and similarly neutral non-identifying labels.
- Apply a touch-and-fix rule: all new content must comply, and any existing content you modify must be normalized to compliant naming.

### Allowed vs Disallowed Patterns

- Allowed: `dasmeta-network`, `example-vpc`, `test-subnet`, `demo.internal.example.com`
- Disallowed: any real client/customer organization names, tenant labels, or client-identifying hostnames.

### Replacement Guidance

- When you encounter non-compliant naming, replace it with neutral placeholders that preserve intent.
- Prefer pattern-preserving replacements (for example, environment-role identifiers) while removing organization identity.
- Keep replacements consistent across code, comments, examples, and tests so reviewers can verify policy compliance by inspection.

## Request Modes

### Create a New Module

- Inspect the approved provider-maintained module collection for the requested cloud first.
- If a suitable upstream module exists, wrap it rather than recreating the same capability directly from provider resources.
- If multiple upstream modules are suitable, select the module whose scope is closest to the requested wrapper module.
- State what opinionated usability or interface improvements the local wrapper module adds beyond the upstream module.
- Keep the exposed consumer inputs intentionally smaller than the full upstream module surface unless a broader interface is explicitly justified and approved.
- Prefer predefined defaults, preconfiguration, and validated variable sets over forwarding rarely used upstream inputs.
- Prefer representing related consumer inputs as grouped object variables rather than many flat top-level variables when grouping is unambiguous and does not change the required/optional contract.
- For grouped object inputs, prefer representing non-critical attributes as optional (using Terraform optional attribute types when supported) so consumers can omit them without breaking validation.
- If grouping would introduce ambiguity, change requiredness semantics, or create compatibility risk, fall back to flat inputs (or an equivalent safe interface shape) and record the fallback reason.
- Use the upstream scratch template reference only when no suitable provider-maintained module exists and direct resource-based creation is necessary.
- Keep the generated module aligned with internal standards rather than copying upstream modules or templates wholesale.
- Create the standard file set when relevant: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `locals.tf`, `README.md`, `examples/`, and tests or executable examples. Add `providers.tf` only when the target repository convention or actual provider configuration needs a separate file; otherwise keep required provider declarations in `versions.tf`.
- Apply the Modern Capabilities Rule to every net-new ability; classify each in the pre-change plan (supported, replaced, or exempted).

### Improve an Existing Module

- Report current state, gaps versus internal standards, gaps versus the new-module baseline when relevant, proposed file changes, conflicts, and potential breaking changes before editing.
- Preserve good existing patterns when they do not conflict with internal standards.
- Preserve the wrapper-module interface shape when the module already follows the opinionated pattern.
- When standardizing interfaces, preserve the required/optional contract even if you refactor related inputs into grouped object variables.
- Do not upgrade optional attributes to required, and do not introduce grouped attribute ambiguity; if grouping would drift the contract, fall back to a safe flat representation.
- If the current module exposes too much upstream surface, call out the drift and require explicit approval before proposing a breaking simplification.
- Prefer small standardization steps over broad speculative refactors.
- Modern Capabilities Rule is **not** active in **improve mode** unless the request introduces a wholly net-new ability (unusual for improve); default to compatibility and approval gates.

### Extend an Existing Module

- Add the new capability with the smallest interface expansion that still serves common use cases.
- For wholly net-new abilities, apply the Modern Capabilities Rule when minimum supported provider versions already support the modern capability; otherwise document `out_of_scope_provider_bound` without forcing a provider bump solely for this rule.
- If the same change raises minimum supported provider version, the rule still applies only to the net-new ability—not established interfaces.
- Prefer adding or reusing opinionated inputs over exposing the upstream module's full option set.
- If the request would materially broaden consumer inputs or weaken defaults, present the tradeoff and wait for explicit approval before proceeding.
- If the extension would require shifting required/optional semantics of existing grouped inputs, treat that as a contract drift and require explicit approval.
- Re-check variables, outputs, examples, tests, and version constraints after the change.
- Use fallback guidance only for uncovered provider details, then fold the decision back into the plan.

## File Coverage Expectations

When relevant to the request, review or update:

- `main.tf`
- `variables.tf`
- `outputs.tf`
- `versions.tf`
- `providers.tf` when repository convention or provider configuration separation calls for it
- `locals.tf`
- `README.md`
- `examples/`
- `tests/`
- related repository automation files in the same repository

When version constraints are introduced or standardized, prefer DasMeta's usual pessimistic range form such as `~> 1.3` unless the target repository already documents a different convention or a stricter constraint is required for a specific technical reason.

## Approval Gates

- Standards conflict: stop and present the mismatch before editing.
- Breaking change: notify the user, explain the impact, and wait for explicit approval.
- Wrapper-baseline mismatch: if the best available upstream module still conflicts with required internal standards or requested scope, stop and present the tradeoff before proceeding.
- Interface widening: if a requested change would turn the wrapper into a broad upstream pass-through or weaken established defaults, stop and wait for explicit approval.
- Required/optional contract drift from grouped object refactors: stop and require explicit approval when grouping/optional attribute changes would materially alter what consumers must provide.
- Governance-source conflict: if local repository guidance disagrees with cross-repository standards from the constitution repository, treat the constitution repository as authoritative and surface the conflict before proceeding.
- Scope expansion outside the current repository: do not proceed without new direction.

## Common Mistakes

- Recreating a module directly from provider resources when a suitable provider-maintained module could be wrapped instead.
- Picking the broadest upstream module instead of the closest scope match for the requested wrapper.
- Exposing the upstream module's full input surface instead of preserving a smaller opinionated interface.
- Changing required/optional semantics when refactoring flat inputs into grouped object variables.
- Using optional attribute types without verifying they are supported by the module's Terraform constraints and by how consumers interpret omission behavior.
- Copying the upstream scratch template wholesale instead of using it only for fallback scaffolding.
- Re-authoring shared governance rules locally instead of using the constitution repository as the shared source of truth.
- Using official or community guidance before checking bundled internal standards.
- Treating notification as enough for a breaking change.
- Updating module code without aligning examples, tests, and README content.
- Adding broad edge-case branching instead of keeping the module useful for the common case.
- Forcing a separate `providers.tf` when the repository convention keeps `required_providers` in `versions.tf`.
- Using broad `>=` or exact `=` Terraform version constraints when the repository convention expects pessimistic `~>` constraints for compatible minor-version ranges.
- Defaulting to deprecated provider or platform capabilities for net-new abilities when a supported replacement exists in primary provider/platform documentation (or secondary upstream notices when wrapping).
- Expanding Modern Capabilities Rule scope to established interfaces after raising minimum supported provider version in the same change.
- Editing module-impacting Terraform files before running **`/speckit.specify`** (or confirming an existing feature package) in the downstream module repository.
- Running Speckit commands from the constitution repository when the change targets a downstream module repo.
