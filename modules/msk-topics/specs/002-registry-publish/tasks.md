# Tasks: Terraform Registry Publishing

**Input**: Design documents from `/specs/002-registry-publish/`
**Branch**: `002-registry-publish`
**Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- All file paths are relative to the repository root

---

## Phase 1: Setup (Validate Current State)

**Purpose**: Confirm the restructuring done earlier is clean and complete before any publishing work begins.

- [x] T001 Run `terraform validate` at repo root and confirm exit 0
- [x] T002 [P] Run `terraform validate` inside `examples/basic/` and confirm exit 0
- [x] T003 [P] Confirm no consumer-only files remain at root (`kafka_topics.tf` absent, no leftover `variables.tf`/`versions.tf` added solely for direct-apply use)

---

## Phase 2: Foundational (README — Blocks All User Stories)

**Purpose**: Restore the `README.md` that was lost during the module restructure. The README is required by the Terraform registry to display module documentation and is a prerequisite for publishing.

**⚠️ CRITICAL**: The registry will not display useful documentation without a README at root. US1 should not proceed without it.

- [x] T004 Create `README.md` at repo root documenting: registry source string (`dasmeta/msk-topics/kafka`), all input variables, outputs, wrapper YAML usage example, direct Terraform usage example, SASL endpoint note, and stable-addressing behaviour

**Checkpoint**: README.md present at root — registry publishing can proceed.

---

## Phase 3: User Story 1 — Publish Module to Terraform Registry (Priority: P1) 🎯 MVP

**Goal**: The module is published to `registry.terraform.io/modules/dasmeta/msk-topics/kafka` at version `1.0.0` and any consumer can run `terraform init` with `source = "dasmeta/msk-topics/kafka"` and `version = "1.0.0"` successfully.

**Independent Test**: Navigate to `registry.terraform.io/modules/dasmeta/msk-topics/kafka` and confirm the module page shows version `1.0.0`, all input variables, and outputs. Run `terraform init` in a scratch directory with the registry source and confirm it downloads successfully.

- [ ] T005 [US1] Create GitHub repository named `terraform-kafka-msk-topics` under the `dasmeta` organisation *(manual step — requires GitHub admin access)*
- [ ] T006 [US1] Configure git remote: `git remote add origin git@github.com:dasmeta/terraform-kafka-msk-topics.git`
- [ ] T007 [US1] Create initial commit: stage all module files (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `providers.tf`, `README.md`, `.terraform.lock.hcl`, `.gitignore`, `examples/`, `wrappers/`, `specs/`) and commit with message `feat: initial msk-topics module release`
- [ ] T008 [US1] Push `main` branch to GitHub: `git push -u origin main`
- [ ] T009 [US1] Tag version and push: `git tag v1.0.0 && git push origin v1.0.0`
- [ ] T010 [US1] Connect repository to Terraform registry: sign in at `registry.terraform.io` with the `dasmeta` GitHub account → Publish → Module → select `dasmeta/terraform-kafka-msk-topics` *(manual step)*
- [ ] T011 [US1] Verify the module appears at `registry.terraform.io/modules/dasmeta/msk-topics/kafka` with version `1.0.0`, correct inputs, and outputs

**Checkpoint**: Module is live on the registry. Consumers can reference `source = "dasmeta/msk-topics/kafka"` and `version = "1.0.0"`.

---

## Phase 4: User Story 2 — Consumer Wrapper YAML References Registry (Priority: P2)

**Goal**: `wrappers/dev.yaml` and `wrappers/prod.yaml` reference the published registry module at `version: 1.0.0`, so any infrastructure repo copying these files gets the correct published source.

**Independent Test**: Inspect `wrappers/dev.yaml` and `wrappers/prod.yaml` — both must contain `source: dasmeta/msk-topics/kafka` and `version: 1.0.0`. In an infrastructure repo using the DSL system, apply the wrapper and confirm topics are created on the target MSK cluster.

- [x] T012 [P] [US2] Confirm `wrappers/dev.yaml` contains `source: dasmeta/msk-topics/kafka` and `version: 1.0.0` — update if registry source or version was changed during US1
- [x] T013 [P] [US2] Confirm `wrappers/prod.yaml` contains `source: dasmeta/msk-topics/kafka` and `version: 1.0.0` — update if registry source or version was changed during US1
- [x] T014 [US2] Verify `README.md` wrapper usage example matches the actual `wrappers/dev.yaml` structure (source, version, variables, linked_workspaces shape)

**Checkpoint**: Wrappers reference the published registry module. Infrastructure repos can copy them and use the module immediately.

---

## Phase 5: User Story 3 — Example Validates Module Interface (Priority: P3)

**Goal**: The `examples/basic/` Terraform configuration passes `terraform validate`, uses neutral (non-client) topic names, and correctly demonstrates the module interface as published.

**Independent Test**: Run `terraform validate` in `examples/basic/` — exits 0. Review `examples/basic/main.tf` — topic names use `example-` prefix (not client names).

- [x] T015 [US3] Run `terraform init -backend=false` and `terraform validate` in `examples/basic/` — confirm exit 0
- [x] T016 [US3] Review `examples/basic/main.tf` — confirm all topic names use neutral placeholders (`example-*`) and no client-specific names appear

**Checkpoint**: Examples are valid and naming-policy compliant. They serve as living documentation for module consumers.

---

## Final Phase: Polish & Repository Hygiene

**Purpose**: Formatting consistency, gitignore correctness, and lock file hygiene.

- [x] T017 [P] Run `terraform fmt -recursive .` from repo root and confirm no files are reformatted (or apply formatting and commit)
- [x] T018 [P] Verify `.gitignore` contains `.terraform/`, `*.tfstate`, `*.tfstate.backup` and does NOT contain `.terraform.lock.hcl`
- [x] T019 Verify `.terraform.lock.hcl` is present and will be committed (pins `Mongey/kafka v0.13.1`)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (validation must pass) — **BLOCKS US1**
- **US1 (Phase 3)**: Depends on Phase 2 (README must exist before publishing)
- **US2 (Phase 4)**: Depends on US1 (registry must be live to confirm version)
- **US3 (Phase 5)**: Depends on Phase 2; can run in parallel with US1 (examples are local, no registry needed)
- **Polish (Final Phase)**: Depends on all user story phases complete

### User Story Dependencies

- **US1 (P1)**: Requires Phase 2 complete. Independent of US2 and US3.
- **US2 (P2)**: Requires US1 complete (needs confirmed registry version).
- **US3 (P3)**: Requires Phase 2 complete. Independent of US1 and US2 — local validation only.

### Within Each Phase

- T001, T002, T003 (Phase 1 validation) can run in parallel
- T012, T013 (wrapper confirmation) can run in parallel after US1
- T017, T018 (polish) can run in parallel

---

## Parallel Example: Phase 1

```
T001: terraform validate at root
T002: terraform validate in examples/basic/   ← parallel with T001
T003: confirm no consumer files remain        ← parallel with T001
```

## Parallel Example: US3 + US1

```
After Phase 2 (README complete):

Parallel track A → T005–T011: US1 registry publishing
Parallel track B → T015–T016: US3 example validation

Both tracks can proceed simultaneously.
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Validation
2. Complete Phase 2: README
3. Complete Phase 3: Publish to registry (US1)
4. **STOP and VALIDATE**: Confirm module appears on registry, test `terraform init` with registry source
5. US2 and US3 add wrapper confirmation and example hygiene on top

### Incremental Delivery

1. Phase 1 + 2 → Local state valid, README restored
2. Phase 3 → Module live on registry → **MVP: any consumer can use `dasmeta/msk-topics/kafka`**
3. Phase 4 → Wrappers confirmed → **Teams can copy wrapper YAMLs and deploy immediately**
4. Phase 5 → Examples validated → **Module documentation is accurate and naming-compliant**
5. Final Phase → Repository clean and formatted

---

## Notes

- T005 and T010 are manual GitHub/registry steps — they cannot be automated by Terraform or CLI without browser interaction
- `[P]` tasks touch different concerns with no shared dependencies — safe to run concurrently
- `.terraform.lock.hcl` **must** be committed — it pins `Mongey/kafka v0.13.1` for reproducible `terraform init` runs
- SASL password must always be supplied via secret manager or `TF_VAR_sasl_password` — never written to any committed file
