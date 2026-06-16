# Terraform Module Developer Plan Outline

Use this outline to draft the pre-change plan before editing a module.

```markdown
## Current State

- Starting module path:
- Related submodules in scope:
- Repository automation files in scope:
- Existing standard files present:
- Existing gaps or inconsistencies:

## Comparison Against Internal Standards

- Module design boundary:
- Variable and output alignment:
- Interface shaping (grouped vs flat inputs):
  - Grouping boundary (which related inputs become one grouped object):
  - Required/optional contract preservation (what must remain required vs optional):
- Optional grouped-attribute mapping:
  - Which grouped attributes are optional:
  - How optional omission is expected to behave (prefer Terraform optional attribute mechanism when supported):
- Fallback decision (if grouping is not applied):
  - Grouping reason not safe / unambiguous:
  - What safe interface shape is kept instead:
- Documentation, examples, and tests alignment:
- Version and provider alignment:

## New-Module Sourcing Assessment

- Use this section only for new-module creation.
- Target cloud:
- Provider collection checked:
- Candidate upstream modules considered:
- Selected upstream wrapper baseline:
- Why this is the closest scope match:
- Wrapper-added usability or interface improvements:
- Fallback required:
- Fallback reason:

## Comparison Against Scratch Template

- Use this section only when new-module creation falls back to direct resource-based scaffolding.
- Relevant upstream patterns:
- Patterns intentionally not copied:

## Proposed File Changes

- Files to create:
- Files to update:
- Files to leave unchanged:

## Risks and Approvals

- Potential breaking changes:
- Conflicts requiring approval:
- Fallback sources needed:

## Execution Notes

- Recommended order of edits:
- Validation after edits:
```
