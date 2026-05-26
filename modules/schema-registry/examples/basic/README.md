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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_schema_registry"></a> [schema\_registry](#module\_schema\_registry) | ../.. | n/a |
| <a name="module_schema_registry_msk"></a> [schema\_registry\_msk](#module\_schema\_registry\_msk) | ../.. | n/a |
| <a name="module_schema_registry_sasl"></a> [schema\_registry\_sasl](#module\_schema\_registry\_sasl) | ../.. | n/a |
| <a name="module_schema_registry_with_ingress"></a> [schema\_registry\_with\_ingress](#module\_schema\_registry\_with\_ingress) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
