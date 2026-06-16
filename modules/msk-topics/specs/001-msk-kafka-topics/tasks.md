# Tasks: AWS MSK Kafka Topic Provisioning Module

**Input**: Design documents from `/specs/001-msk-kafka-topics/`
**Branch**: `001-msk-kafka-topics`
**Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- All file paths are relative to the repository root

---

## Phase 1: Setup (Directory Structure)

**Purpose**: Create all directories required by the project structure defined in plan.md.

- [x] T001 Create directory structure: `modules/msk-topics/`, `environments/dev/`, `environments/staging/`, `environments/production/`

---

## Phase 2: Foundational (Core Module — Blocks All User Stories)

**Purpose**: Implement the `msk-topics` Terraform module. All user stories depend on this module existing and being syntactically valid before any environment root module can be written.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T002 Create `modules/msk-topics/versions.tf` declaring `required_version = ">= 1.3.0"` and `required_providers { kafka = { source = "Mongey/kafka", version = ">= 0.6.0" } }`
- [x] T003 [P] Create `modules/msk-topics/variables.tf` with the `topics` variable typed as `map(object({ partitions = number, replication_factor = number, config = optional(map(string), {}) }))`
- [x] T004 [P] Create `modules/msk-topics/main.tf` with a single `kafka_topic "topics"` resource using `for_each = var.topics`, setting `name = each.key`, `partitions = each.value.partitions`, `replication_factor = each.value.replication_factor`, `config = each.value.config`
- [x] T005 [P] Create `modules/msk-topics/outputs.tf` with `topic_names` output (list of map keys) and `topic_ids` output (map of topic name to `kafka_topic.topics[name].id`)
- [x] T006 Run `terraform init && terraform validate` inside `modules/msk-topics/` and confirm exit code 0 with "Success! The configuration is valid."

**Checkpoint**: Module is syntactically valid — environment root module work can now begin.

---

## Phase 3: User Story 1 - Provision Topics on a Fresh Cluster (Priority: P1) 🎯 MVP

**Goal**: A platform engineer can run `terraform apply` in `environments/dev/` against a fresh MSK cluster and have all topics from `terraform.tfvars` created automatically — no Kafka CLI required.

**Independent Test**: Run `terraform init && terraform validate` in `environments/dev/`. If broker is available: run `terraform apply` and confirm all tfvars topics appear in `kafka-topics.sh --list` output with correct partition and replication counts.

- [x] T007 [US1] Create `environments/dev/variables.tf` declaring: `bootstrap_brokers` (string), `topics` (same `map(object)` type as the module), `sasl_username` (string, default `""`), `sasl_password` (string, sensitive, default `""`), `sasl_mechanism` (string, default `""`)
- [x] T008 [P] [US1] Create `environments/dev/main.tf` with a `provider "kafka"` block setting `bootstrap_servers = split(",", var.bootstrap_brokers)`, `tls_enabled = true`, `sasl_username`, `sasl_password`, `sasl_mechanism`; and a `module "msk_topics"` block with `source = "../../modules/msk-topics"` and `topics = var.topics`
- [x] T009 [P] [US1] Create `environments/dev/outputs.tf` with a `topic_names` output that re-exports `module.msk_topics.topic_names`
- [x] T010 [P] [US1] Create `environments/dev/backend.tf` with an S3 backend block using placeholder values: `bucket = "REPLACE-WITH-YOUR-TFSTATE-BUCKET"`, `key = "msk-topics/dev/terraform.tfstate"`, `region = "us-east-1"`, `dynamodb_table = "REPLACE-WITH-YOUR-LOCK-TABLE"`
- [x] T011 [US1] Create `environments/dev/terraform.tfvars` with `bootstrap_brokers` set to a placeholder MSK TLS endpoint and a `topics` map containing at least 3 topic definitions: `"orders"` (6 partitions, rf=1, retention.ms+cleanup.policy), `"payments"` (12 partitions, rf=1, retention.ms+min.insync.replicas), `"audit-log"` (3 partitions, rf=1, cleanup.policy=compact)
- [x] T012 [US1] Run `terraform init && terraform validate` inside `environments/dev/` and confirm the module source resolves and the configuration is valid

**Checkpoint**: User Story 1 is complete. `terraform apply` with a real broker endpoint will create all tfvars-defined topics on a fresh cluster with zero manual broker steps.

---

## Phase 4: User Story 2 - Add a New Topic Without Touching Existing Ones (Priority: P2)

**Goal**: Adding a new entry to the `topics` map in tfvars produces a plan with exactly 1 addition and 0 changes or destructions to previously managed topics — demonstrating `for_each` stable addressing.

**Independent Test**: Add a new topic key to `environments/dev/terraform.tfvars`, run `terraform plan`, and confirm the plan summary shows `Plan: 1 to add, 0 to change, 0 to destroy.`

- [x] T013 [US2] Append a 4th topic entry `"notifications"` (3 partitions, rf=1, no config) to `environments/dev/terraform.tfvars` as a live demonstration of the add-topic workflow
- [x] T014 [US2] Run `terraform validate` in `environments/dev/` after the tfvars addition to confirm the updated map passes type validation; add a comment block at the top of `environments/dev/terraform.tfvars` documenting the expected `terraform plan` output ("Plan: 1 to add, 0 to change, 0 to destroy") for operator reference

**Checkpoint**: User Story 2 is demonstrably satisfied by the map key / `for_each` design. Any new topic added to the map produces an isolated, additive plan.

---

## Phase 5: User Story 3 - Reuse Module Across Environments (Priority: P3)

**Goal**: The `msk-topics` module is called identically from `environments/staging/` and `environments/production/`, each with environment-appropriate topic configs (higher replication factor, longer retention) and independent Terraform state.

**Independent Test**: Run `terraform validate` in `environments/staging/` and `environments/production/`. Confirm both environments reference the same module source and each tfvars carries environment-appropriate `replication_factor` values independent of dev.

- [x] T015 [US3] Create `environments/staging/variables.tf`, `environments/staging/main.tf`, `environments/staging/outputs.tf` as identical copies of the dev equivalents (same variable declarations, same module call, same output); update `environments/staging/backend.tf` with S3 key `"msk-topics/staging/terraform.tfstate"`
- [x] T016 [P] [US3] Create `environments/staging/terraform.tfvars` with the same topic names as dev but `replication_factor = 3` for all topics and staging-appropriate `retention.ms` values (e.g., 7 days = `"604800000"`); set `bootstrap_brokers` to a staging MSK TLS endpoint placeholder
- [x] T017 [P] [US3] Create `environments/production/variables.tf`, `environments/production/main.tf`, `environments/production/outputs.tf` (same structure as dev/staging); update `environments/production/backend.tf` with S3 key `"msk-topics/production/terraform.tfstate"`
- [x] T018 [US3] Create `environments/production/terraform.tfvars` with production-grade values: `replication_factor = 3`, `"min.insync.replicas" = "2"` for critical topics, `retention.ms` of 30 days or more; set `bootstrap_brokers` to a production MSK TLS endpoint placeholder
- [x] T019 [US3] Run `terraform init && terraform validate` in `environments/staging/` and `environments/production/` and confirm both exit 0

**Checkpoint**: All three environments are wired to the same module. Changing a topic config in one tfvars file has zero effect on other environments.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: Repository hygiene and formatting consistency across all HCL files.

- [x] T020 [P] Create `.gitignore` at the repository root with Terraform-specific entries: `.terraform/`, `*.tfstate`, `*.tfstate.backup`, `override.tf`, `override.tf.json`, `*_override.tf`, `*_override.tf.json` (do NOT gitignore `.terraform.lock.hcl` — it should be committed for provider version consistency)
- [x] T021 Run `terraform fmt -recursive .` from the repository root to canonically format all `.tf` files; confirm no files are left with formatting differences

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (directories must exist) — **BLOCKS all user stories**
- **US1 (Phase 3)**: Depends on Phase 2 completion (module files must exist for the module call in `environments/dev/main.tf` to resolve)
- **US2 (Phase 4)**: Depends on Phase 3 completion (tfvars must already contain existing topics to demonstrate the non-destructive add)
- **US3 (Phase 5)**: Depends on Phase 2 completion; can run in parallel with US1/US2 since staging and production directories are independent of dev
- **Polish (Final Phase)**: Depends on all user story phases being complete

### User Story Dependencies

- **US1 (P1)**: Requires Phase 2 complete. Independent of US2 and US3.
- **US2 (P2)**: Requires US1 complete (needs pre-existing topics in tfvars to demonstrate safe addition).
- **US3 (P3)**: Requires Phase 2 complete. Independent of US1 and US2 — staging/production environments can be built in parallel with dev.

### Within Each Phase

- T003, T004, T005 (module files) can run in parallel — different files, no intra-phase dependencies
- T008, T009, T010 (dev environment files) can run in parallel after T007 sets the variable types
- T016, T017 (staging tfvars + production scaffolding) can run in parallel after T015 establishes the directory pattern

---

## Parallel Example: Phase 2 (Core Module)

```
After T002 (versions.tf) is written:

Parallel track A → T003: modules/msk-topics/variables.tf
Parallel track B → T004: modules/msk-topics/main.tf
Parallel track C → T005: modules/msk-topics/outputs.tf

Then sequentially → T006: terraform init && terraform validate
```

## Parallel Example: Phase 3 (US1 Dev Environment)

```
After T007 (variables.tf) is written:

Parallel track A → T008: environments/dev/main.tf
Parallel track B → T009: environments/dev/outputs.tf
Parallel track C → T010: environments/dev/backend.tf

Then sequentially → T011: terraform.tfvars
Then sequentially → T012: terraform init && terraform validate
```

## Parallel Example: Phase 5 (US3 Multi-Env)

```
After T015 (staging scaffold) is complete:

Parallel track A → T016: environments/staging/terraform.tfvars
Parallel track B → T017: environments/production/ scaffold + files

After T016 and T017 complete:
→ T018: environments/production/terraform.tfvars
→ T019: terraform validate in both environments
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational module (T002–T006) — **critical blocker**
3. Complete Phase 3: US1 dev environment (T007–T012)
4. **STOP and VALIDATE**: Run `terraform validate` in `environments/dev/`. If broker available, run `terraform apply` and verify all 3 topics exist on the cluster.
5. The module is now ready for disaster recovery use — US2 and US3 add production hardening.

### Incremental Delivery

1. Phase 1 + 2 → Module ready (foundation)
2. Phase 3 → Dev environment wired → **MVP: fresh cluster recoverable**
3. Phase 4 → Stable add-topic workflow confirmed
4. Phase 5 → Staging + production environments wired → **Full multi-env coverage**
5. Final Phase → Repository clean and formatted

### Parallel Team Strategy

With two developers after Phase 2 is complete:
- **Developer A**: Phase 3 (US1 — dev environment) → Phase 4 (US2 — add topic validation)
- **Developer B**: Phase 5 (US3 — staging + production environments)
- Both merge after Phase 5; one developer runs Final Phase

---

## Notes

- `[P]` tasks touch different files with no shared dependencies — safe to run concurrently
- `[USn]` labels map each task to its user story for traceability to spec.md
- `terraform validate` is the primary correctness gate — it requires no broker connectivity
- `terraform fmt -recursive` in T021 must be the final step to avoid formatting churn during development
- The `.terraform.lock.hcl` file generated by `terraform init` should be committed to version control (not gitignored) to pin provider versions
- SASL password must always be supplied via `TF_VAR_sasl_password` env var — never written to any `.tfvars` file
