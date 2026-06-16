# Tasks: Remove Embedded Provider Block

**Input**: Design documents from `/specs/003-remove-provider-block/`
**Branch**: `003-remove-provider-block`
**Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

## Format: `[ID] [P?] [Story?] Description`

---

## Phase 1: Speckit Artifacts

**Purpose**: Feature specification and design documents.

- [x] T001 Create `specs/003-remove-provider-block/spec.md`
- [x] T002 [P] Create `specs/003-remove-provider-block/plan.md`, `research.md`, `contracts/module-interface.md`, `quickstart.md`
- [x] T003 Create `specs/003-remove-provider-block/tasks.md`

---

## Phase 2: Module Refactor (US1)

**Goal**: Module has no embedded provider; `topics` is the only input.

- [x] T004 [US1] Delete `providers.tf` at repository root
- [x] T005 [US1] Remove `bootstrap_brokers`, `sasl_username`, `sasl_password`, `sasl_mechanism` from `variables.tf`

**Checkpoint**: Module `.tf` files contain no `provider "kafka"` block and only `topics` variable.

---

## Phase 3: Example Update (US3)

**Goal**: `examples/basic/` demonstrates caller-owned provider pattern.

- [x] T006 [P] [US3] Create `examples/basic/providers.tf` with kafka provider configuration
- [x] T007 [US3] Update `examples/basic/main.tf` — module call passes only `topics`
- [x] T008 [P] [US3] Add `sasl_mechanism` variable to `examples/basic/variables.tf` if missing

**Checkpoint**: Example root configures provider; module receives `topics` only.

---

## Phase 4: README (US2)

**Goal**: README leads with minimal Terraform example; no YAML wrapper section.

- [x] T009 [US2] Rewrite `README.md` — minimal provider + module example first
- [x] T010 [US2] Update inputs table to `topics` only; document caller provider responsibility
- [x] T011 [US2] Remove YAML wrapper usage section and `wrappers/` references

**Checkpoint**: README matches dasmeta minimal-example standard.

---

## Phase 5: Validation

**Goal**: Confirm configuration is syntactically valid.

- [x] T012 Run `terraform init -backend=false` and `terraform validate` at repo root
- [x] T013 [P] Run `terraform init -backend=false` and `terraform validate` in `examples/basic/`

**Checkpoint**: Both validations exit 0.

---

## Phase 6: Agent Context

- [x] T014 Update `CLAUDE.md` SPECKIT section to reference `specs/003-remove-provider-block/plan.md`

---

## Dependencies

```text
T004, T005 → T006-T008 → T009-T011 → T012, T013 → T014
```
