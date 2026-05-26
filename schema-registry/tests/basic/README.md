# basic

Terraform validation tests for `modules/schema-registry`.

These tests run `terraform validate` only; they do not require a live cluster or
Kafka brokers. Use the basic example for an optional end-to-end Helm install.

## Validate

```bash
terraform -chdir=modules/schema-registry/tests/basic init -backend=false
terraform -chdir=modules/schema-registry/tests/basic validate
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
| <a name="module_schema_registry"></a> [schema\_registry](#module\_schema\_registry) | ../../ | n/a |
| <a name="module_schema_registry_existing_sasl_secret"></a> [schema\_registry\_existing\_sasl\_secret](#module\_schema\_registry\_existing\_sasl\_secret) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
