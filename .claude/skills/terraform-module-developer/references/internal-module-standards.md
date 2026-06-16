# Terraform Module Developer Internal Standards

Use this file as the primary local reference. It contains the reusable module-development guidance migrated from the former root `tf-module-development.md` source.

## Module Design Boundaries

- Keep the module focused on infrastructure that is normally deployed together.
- Stay within one privilege boundary; do not mix responsibilities owned by separate groups unless the request explicitly needs that coupling.
- Separate long-lived infrastructure from high-churn infrastructure when combining them would increase risk.
- Aim for the common 80% use case before adding edge-case branching.
- Prefer a narrow first version over condition-heavy abstractions.
- When wrapping an official or public upstream module, keep the local module opinionated and consumer-friendly rather than mirroring the upstream surface area.

## Naming and Layout

- Use underscores in Terraform identifiers such as resources, data sources, variables, outputs, and locals.
- Keep Terraform identifiers lowercase with numbers only when possible.
- Use file names that reflect resource groups or responsibilities instead of catch-all names when that improves clarity.
- Keep configuration locals in `locals.tf` or a clearly scoped config file.
- End text files with a trailing newline.

## Variables

- Expose only the most commonly changed inputs.
- Prefer defaults and derived values when safe.
- Prefer predefined defaults, preconfiguration, and validated variable sets over forwarding rarely used upstream module inputs.
- When it improves readability and contract clarity, prefer grouping related consumer inputs into a grouped object variable rather than many flat top-level variables; only do this when the grouping boundary is unambiguous.
- For grouped object variables, prefer representing non-critical attributes as optional fields so consumers can omit them without breaking validation. Use Terraform optional attribute types (via `optional(...)`) when supported by the module's Terraform constraints.
- Preserve the required/optional contract when refactoring: do not upgrade optional attributes to required, and do not apply grouped-object refactors when doing so would introduce ambiguous attribute behavior or change what consumers must provide. Fall back to flat inputs (or an equivalent safe interface shape) and record why.
- Reuse provider argument names, descriptions, and defaults where that improves familiarity.
- Use plural names for list and map variables.
- Order variable fields as `type`, `default`, `description`.
- Add descriptions for every variable.
- Let the module closest to the resource own the validation logic.
- If a requested change would materially broaden consumer inputs, treat it as an exception that needs an explicit tradeoff and approval.

## Outputs

- Add descriptions for every output.
- Prefer descriptive names in the shape `{name}_{type}_{attribute}` when the output maps directly to a resource value.
- Use plural output names for lists.
- Return useful values generously in the MVP when they do not confuse the interface.

## Providers and Versions

- Inspect the target repository and related DasMeta module repos before deciding whether `required_providers` belongs in `providers.tf` or `versions.tf`.
- Prefer preserving the repository's established layout convention instead of forcing a separate `providers.tf`.
- If no repository-local convention exists, keep version expectations explicit in `versions.tf` and use `providers.tf` only when actual provider configuration or clear separation adds value.
- Add provider configuration in modules only when the default provider behavior is not enough.
- Keep version expectations explicit in `versions.tf`.
- Prefer pessimistic Terraform version constraints such as `~> 1.3` for compatible minor-version ranges unless the repository already defines a different rule or a stricter constraint is technically required.
- Re-check version constraints when adding provider-specific features or changing interface expectations.

## Modern Capabilities

Use recently supported, non-deprecated provider and platform capabilities when introducing net-new module abilities. Registry metadata alone is not authoritative for deprecation decisions.

### When the rule applies

- **Create mode**: All net-new abilities introduced in a new module.
- **Extend mode**: Only wholly net-new abilities (not preserved baseline surfaces), and only when the module's **minimum supported provider version** (from repository capability constraints, typically `versions.tf` / `providers.tf` per repo convention) already supports the modern capability for that ability.
- **Improve mode**: The rule does not apply; do not perform deprecation-only refactors on established interfaces solely because a newer capability exists.

### Deprecation source hierarchy

1. **Primary**: Official provider or platform documentation for the target environment.
2. **Secondary** (when wrapping an upstream module): Upstream README or changelog deprecation notices—use these to decide which deprecated upstream inputs are intentionally not forwarded to consumers.

### Pre-change plan classification

For each in-scope net-new ability, record one of:

- **supported** — primary docs confirm a non-deprecated path for the intended use
- **replaced** — a deprecated path was avoided; document the supported replacement and citation
- **exempted** — bounded exception (see below)
- **out_of_scope_provider_bound** — extend-mode only; minimum supported provider versions do not yet support the modern capability; document the version bound without requiring a provider constraint bump solely for this rule

### Same-change provider version bumps

Raising minimum supported provider version in the same delivery as a net-new ability does **not** expand this rule to established module interfaces. Scope stays limited to that net-new ability.

### Bounded exception example

When a provider marks a capability deprecated but documents no supported replacement yet, you may proceed with the deprecated path for that specific net-new ability only if the pre-change plan records an **exempted** classification with:

- the ability name
- primary (and if wrapping, secondary) documentation citations showing no viable replacement
- a review-visible reason bounded to that ability and change

Do not use this exception to justify retrofitting deprecated patterns across established interfaces in improve or non-net-new extend work.

## Resource Block Conventions

- Put `count` near the top of the resource block when used.
- Keep tags near the end of the real arguments, followed by `depends_on` and `lifecycle` only when needed.
- Prefer boolean or length-based conditions over extra inversion variables where the intent stays clear.
- Use singular nouns for resource and data source labels.
- Use hyphens only in human-facing values, not Terraform identifiers.

## Documentation, Examples, and Tests

- Keep `README.md` focused on how the module works and include copy-pasteable examples.
- Keep examples aligned with the live module interface.
- Add or update tests for materially different use cases rather than trivial value variations.
- Prefer the test layout `0-setup.tf`, `1-example.tf`, and `2-assert.tf` when using Terraform-based example tests.
- Update tests when refactoring module behavior.
- Keep examples and tests in sync with new supported use cases.

## Repository Automation

- Preserve or add reusable automation patterns such as pre-commit configuration and GitHub Actions workflows when they are relevant to the module repository.
- Limit automation changes to the current repository scope.
- Do not use git operations as a default part of this skill.

## Review Questions

1. Is the module still scoped to a coherent responsibility?
2. Are the exposed variables and outputs minimal, descriptive, and documented?
3. Did the change keep README, examples, and tests aligned?
4. Are provider and version expectations explicit where needed?
5. Did the change improve the common case without overfitting edge cases?
6. Does the module still behave like an opinionated wrapper instead of a broad pass-through to the upstream module?
