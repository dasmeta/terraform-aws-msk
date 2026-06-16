# Research: Remove Embedded Provider Block

## Decision 1 — Provider configuration placement

**Decision**: Remove `providers.tf` from the module. Caller root module configures `provider "kafka"`.

**Rationale**: Terraform best practice and dasmeta `terraform-module-developer` standards require provider configuration at the caller. The original `001-msk-kafka-topics` design placed the provider in the environment root module. The `002-registry-publish` bounded exception is superseded.

**Alternatives considered**:
- Keep embedded provider for DSL self-containment — rejected; user explicitly requested caller-owned provider and no wrapper YAML in README.

---

## Decision 2 — Module variable surface

**Decision**: Module accepts only `topics`. Remove `bootstrap_brokers`, `sasl_username`, `sasl_password`, `sasl_mechanism`.

**Rationale**: Broker connectivity variables existed solely to feed the embedded provider block. With caller-owned provider, they belong in the caller's variable set.

**Alternatives considered**:
- Keep broker vars as passthrough without using them — rejected; confusing dead interface.

---

## Decision 3 — Provider inheritance pattern

**Decision**: Use implicit default provider inheritance. No `configuration_aliases` or explicit `providers` meta-argument required on module call when caller defines a single default `kafka` provider.

**Rationale**: Simplest pattern for single-cluster topic management. Matches `001-msk-kafka-topics` contract.

**Alternatives considered**:
- Explicit `providers = { kafka = kafka }` on module block — valid but unnecessary for default provider case; example uses implicit inheritance.

---

## Decision 4 — Version strategy

**Decision**: Ship as `v1.0.0` interface correction before first registry publish.

**Rationale**: Per plan assumption, `v1.0.0` is not yet live on the registry. No major version bump required.

**Alternatives considered**:
- `v2.0.0` if v1 already published — not applicable per current repo state.
