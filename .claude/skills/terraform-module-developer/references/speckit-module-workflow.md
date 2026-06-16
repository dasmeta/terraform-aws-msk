# Speckit Module Workflow (Default)

Use this reference when the **terraform-module-developer** skill is active. Speckit runs in the **downstream Terraform module repository** (where `main.tf`, `modules/`, and module examples live)—not in the constitution repository unless you are changing constitution shared standards themselves.

## Default behavior

When a user asks to create, improve, or extend a Terraform module and the request is **module-impacting**, **start with Speckit** instead of editing module files first.

1. Confirm the target repository path and that `.specify/` exists (bootstrap Speckit in that repo if missing and the user approves).
2. If there is no active feature package for this request, run **`/speckit.specify`** with the user's request as the feature description (include scope, cloud/provider, and module path when known).
3. Stop after specify (and clarify if needed) and summarize the spec path, branch, and suggested next command—unless the user explicitly asked to run the full chain in one session.

Do **not** edit module-impacting Terraform files until `specs/<NNN>-<slug>/` contains at least `spec.md`, `plan.md`, and `tasks.md` for this change, or a documented bounded exemption applies.

## Command routing

| User intent | Speckit command | Prerequisite |
|-------------|-----------------|--------------|
| New module/feature request (first touch) | `/speckit.specify` | Working directory = downstream module repo |
| Spec exists but needs decisions | `/speckit.clarify` | `specs/<NNN>-<slug>/spec.md` |
| Spec ready, need technical plan | `/speckit.plan` | Clarifications resolved or consciously skipped |
| Plan ready, need executable tasks | `/speckit.tasks` | `plan.md` exists |
| Optional consistency review | `/speckit.analyze` | `tasks.md` exists |
| Ready to apply Terraform changes | `/speckit.implement` | `tasks.md` exists; user wants implementation |
| Domain-specific validation list | `/speckit.checklist` | As needed before or after implement |

## Suggested handoff after each step

After each command, tell the user the feature directory (from `.specify/feature.json` or the command output) and the **single recommended next command**, for example:

- After specify: "Next: `/speckit.clarify` if requirements are unclear, otherwise `/speckit.plan`."
- After clarify: "Next: `/speckit.plan`."
- After plan: "Next: `/speckit.tasks`."
- After tasks: "Next: `/speckit.implement` when you want module files updated."

When the user says **continue**, **proceed**, or names the next phase, run the matching command in the same downstream repository without restarting specify unless they are describing a **new** unrelated feature.

## When to skip or shorten Speckit

Skip the default Speckit-first start only when one of these applies; record the reason in the pre-change plan:

- The change is clearly **non-module-impacting** (formatting-only, comments-only with no behavior change, etc.).
- A **bounded emergency** exemption is approved per `speckit-module-change-gate`.
- The user explicitly requests a **spike or exploratory edit** without Speckit—warn that downstream merge gates may block the PR.
- Speckit is not yet bootstrapped in the repo—offer to initialize or document bootstrap as the first step.

## Alignment with module-change gate

Module-impacting pull requests must include a corresponding Speckit package. The specify → clarify → plan → tasks → implement sequence produces the evidence the gate expects. See `workflows/speckit-module-change-gate.md` in the constitution repository for enforcement details.

## Constitution vs downstream work

| Work location | Speckit usage |
|---------------|---------------|
| Downstream module repo (e.g. `terraform-aws-eks`) | Full default workflow above |
| Constitution repo (`skills/`, `workflows/`) | Use constitution's own Speckit feature packages; do not use module-repo packages |
