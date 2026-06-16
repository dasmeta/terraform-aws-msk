# Terraform Module Developer Planning Checklist

Use this checklist before proposing or applying module changes.

## Required Plan Sections

Every pre-change plan must include:

- current repository module state
- gaps versus bundled internal standards
- wrapper-preservation assessment for the current or proposed module interface
- provider collection checked for new-module creation
- candidate upstream modules considered for new-module creation
- chosen wrapper baseline and wrapper-added usability rationale when a suitable upstream module exists
- constitution repository source used for shared cross-repository governance decisions
- corresponding Speckit evidence in the downstream module repository
- downstream module-change gate compatibility or exemption status
- fallback rationale when no suitable upstream module exists
- gaps versus the upstream scratch template when the request falls back to direct resource-based creation
- proposed file changes
- potential breaking changes
- potential interface-widening changes
- conflicts requiring approval

## Repository Scope Check

- Confirm the starting module path.
- Confirm whether related submodules in the same repository are affected.
- Confirm whether repository-level automation files are affected.
- Confirm whether the target repository or closely related DasMeta module repos already establish layout conventions for `versions.tf`, `providers.tf`, executable examples, and Terraform version-constraint style.
- Confirm whether the request needs repository-specific local guidance or shared cross-repository governance from the constitution repository.
- Stop if the requested change expands beyond the current repository scope.

## Speckit Workflow Check (default)

- Confirm work runs in the **downstream module repository** (not constitution) unless editing constitution shared standards.
- For a **new** module-impacting request, confirm **`/speckit.specify`** was run (or an existing package already covers this scope).
- For **continued** work, confirm the matching command was used: `/speckit.clarify`, `/speckit.plan`, `/speckit.tasks`, or `/speckit.implement` per [speckit-module-workflow.md](speckit-module-workflow.md).
- Record the active feature directory (`specs/<NNN>-<slug>/`) and the recommended next Speckit command for the user.
- If Speckit was skipped, record the skip reason (non-impacting change, emergency exemption, or explicit user spike approval).

## Corresponding Speckit Evidence Check

- Confirm whether the change is module-impacting: module source, interface, examples, tests, behavior-affecting usage documentation, or module automation.
- For module-impacting work, confirm the downstream module repository contains a corresponding Speckit package under `specs/<NNN>-<slug>/`.
- Verify the downstream package includes `spec.md`, `plan.md`, and `tasks.md`.
- Verify the Speckit package identifies the affected repository or module path clearly enough to satisfy the `speckit-module-change-gate`.
- If the downstream module repository lacks Speckit structure, treat the work as bootstrap or stop for explicit guidance before editing module-impacting files.
- If the change is emergency, bootstrap-only, or non-behavioral, record the bounded exemption reason and review trigger instead of silently bypassing the gate.

## New-Module Sourcing Check

- Confirm the target cloud for the request.
- Check the approved provider-maintained module collection for that cloud before considering direct resource-based creation.
- Record the candidate upstream modules reviewed.
- If multiple candidates are suitable, choose the closest scope match.
- If a suitable upstream module is selected, record how the local module wraps it, which consumer inputs stay exposed, and what opinionated usability improvements it adds.
- If no suitable upstream module exists, record the fallback reason before consulting the scratch template reference.

## Wrapper Preservation Check

- Confirm whether the module currently behaves like an opinionated wrapper or has already drifted toward a broad pass-through interface.
- Record which defaults, preconfiguration, and validated variable sets define the supported consumer experience.
- Record any requested upstream options that are intentionally not exposed because they are outside the supported common use case.
- If the module interface uses grouped object variables, record which inputs are grouped and why the grouping boundary is unambiguous.
- If grouped object variables are used, verify that non-critical attributes are represented as optional attributes (and that optional omission behavior matches the required/optional contract). Prefer the Terraform optional attribute mechanism when supported by the module's Terraform constraints.
- Verify determinism: repeated interface-shaping runs over the same input description should produce the same grouped-vs-flat decision and the same required/optional mapping.
- If grouping would change required/optional semantics or compatibility expectations, record this as contract drift and require explicit approval before proceeding; otherwise fall back to a safe flat interface shape and record the fallback reason.
- If the change would materially broaden consumer inputs or weaken defaults, record the tradeoff and require explicit approval before implementation.

## Modern Capabilities Check

Run when **create mode** applies, or **extend mode** introduces a wholly net-new ability.

- List each net-new ability in scope for the Modern Capabilities Rule.
- Confirm primary provider/platform documentation was consulted for deprecation status; when wrapping, confirm upstream README/changelog deprecation notices (secondary authority) were consulted.
- For extend-mode net-new abilities, record the **minimum provider support boundary** from repository capability constraints and whether it supports the modern capability.
- Classify each in-scope net-new ability: **supported**, **replaced**, **exempted**, or **out_of_scope_provider_bound**.
- Confirm established interfaces are not slated for deprecation-only refactor unless a separate approved migration scopes that work.
- If the same change raises minimum supported provider version, confirm rule scope stays limited to the net-new ability only.

## Governance Source Check

- Use the constitution repository as the single source of truth for shared standards, rules, and conventions that apply across repositories.
- Distinguish shared governance from repository-specific local guidance before proposing local documentation changes.
- If local repository guidance conflicts with the constitution repository, record the conflict and stop for approval.

## Conflict Prompt

Use this shape when internal standards or the baseline conflict with the current module:

```text
Conflict detected:
Affected files:
Why this conflicts with the baseline:
Options:
- keep current pattern
- align with internal standard
- revise scope
Approval needed before proceeding:
```

## Breaking Change Prompt

Use this shape when a breaking change is cleaner than a backward-compatible change:

```text
Breaking change proposed:
Affected interface:
Why the change is beneficial:
Downstream impact:
Approval needed before proceeding:
```

## Interface Widening Prompt

Use this shape when a requested change would turn the wrapper into a broader upstream pass-through or weaken defaults:

```text
Interface widening proposed:
Affected consumer inputs:
Why the broader interface is being considered:
Why the current wrapper shape may be insufficient:
Downstream impact:
Approval needed before proceeding:
```

## Fallback Guidance Rules

- Use bundled internal references first.
- Use approved provider-maintained module collections before the upstream scratch template for new-module creation.
- Use the upstream scratch template only after recording that no suitable provider-maintained module exists.
- Use official Terraform or OpenTofu documentation next.
- Use community conventions only when official docs and internal references still leave a gap.
- Record which fallback source was needed and why.
- Do not replace constitution-repository governance with local duplicated rules during fallback handling.

## Alignment Check

- Did the plan mention `README.md`, `examples/`, and `tests/` when the change affects interface or behavior?
- Did the plan mention `versions.tf` or `providers.tf` when provider features or constraints changed?
- Did the plan record whether the repository convention keeps `required_providers` in `versions.tf` or a separate `providers.tf`?
- Did the plan record the intended Terraform version-constraint style, preferring DasMeta's usual pessimistic `~>` form when no stronger repository-specific rule exists?
- Did the plan explicitly capture the grouped-vs-flat decision and optional-attribute mapping (including fallback reason when grouping is not applied)?
- Did the plan avoid git operations by default?
- Did the plan wait for explicit approval before any breaking change?
- Did the plan preserve an opinionated wrapper interface instead of defaulting to full upstream exposure?
- Did the plan source shared cross-repository governance from the constitution repository instead of defining it locally?
- Did the plan record corresponding Speckit evidence from the downstream module repository before module-impacting edits?
- Did the plan identify whether the downstream `speckit-module-change-gate` should pass, fail, or require a bounded exemption?
- When create or extend net-new work applies, did the plan complete the Modern Capabilities Check (classifications and provider boundary where relevant)?
- Did module-impacting work follow the default Speckit workflow (specify first on new requests; clarify/plan/tasks/implement when continuing)?
