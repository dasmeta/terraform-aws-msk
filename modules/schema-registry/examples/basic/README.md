# basic

Documents baseline and common customization paths for `modules/schema-registry`.

## Prerequisites

- An existing Kubernetes cluster reachable through the Helm and Kubernetes providers
- Consumer-managed Kafka brokers (this module does not install Kafka)
- Optional consumer-managed ingress controller when `ingress.enabled` is true

## Paths in this example

| Module block | Purpose |
|--------------|---------|
| `schema_registry` | Baseline external-Kafka deployment with resource sizing |
| `schema_registry_with_ingress` | Optional ingress for a consumer-managed controller |
| `schema_registry_sasl` | SASL password path for authenticated Kafka |

The module does not expose a generic Helm values pass-through and does not manage
ingress controllers, DNS, TLS certificates, or Kafka itself.

## Validate locally (no cluster)

```bash
cd modules/schema-registry/examples/basic
terraform init -backend=false
terraform validate
```

## Test against payconomy prod EKS

`0-setup.tf` points at `/Users/arsengspeyan/.kube/payconomy-prod-eks-prod` (from `meta exec payconomy eks-prod`).

```bash
meta exec payconomy eks-prod
cd modules/schema-registry/examples/basic
terraform init
terraform plan -target=module.schema_registry_msk
```
