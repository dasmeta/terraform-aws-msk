# basic

Terraform validation tests for `modules/schema-registry`.

These tests run `terraform validate` only; they do not require a live cluster or
Kafka brokers. Use the basic example for an optional end-to-end Helm install.

## Validate

```bash
terraform -chdir=modules/schema-registry/tests/basic init -backend=false
terraform -chdir=modules/schema-registry/tests/basic validate
```
