# example: basic

Demonstrates the minimal usage of the `msk-topics` module. Creates a single Kafka topic on an existing AWS MSK cluster using SASL/SCRAM authentication.

## What this example creates

| Topic | Partitions | Replication factor |
|-------|------------|-------------------|
| `example-orders` | 1 | 2 |

## Requirements

| Name | Version |
|------|---------|
| Terraform | `~> 1.3` |
| Mongey/kafka | `~> 0.6` |

## How to run

The example requires an MSK cluster with SASL/SCRAM enabled (port 9096). Pass credentials via environment variables — never hardcode them in `.tf` files.

```bash
export TF_VAR_bootstrap_brokers="b-1.example.kafka.eu-central-1.amazonaws.com:9096,b-2.example.kafka.eu-central-1.amazonaws.com:9096"
export TF_VAR_sasl_username="your-username"
export TF_VAR_sasl_password="your-password"

terraform init
terraform plan
terraform apply
```

> **Note:** The MSK brokers are on private VPC IPs. Run this from a machine with VPC access (VPN, bastion, EKS pod, or CI runner inside the VPC).

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `bootstrap_brokers` | `string` | Comma-separated MSK SASL/SCRAM broker string (port 9096) |
| `sasl_username` | `string` | SASL/SCRAM username |
| `sasl_password` | `string` | SASL/SCRAM password — pass via env var or secret manager |

## Outputs

| Name | Description |
|------|-------------|
| `topic_names` | Names of all topics created by this example |

## Clean up

```bash
terraform destroy
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_kafka"></a> [kafka](#requirement\_kafka) | ~> 0.6 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_msk_topics"></a> [msk\_topics](#module\_msk\_topics) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_brokers"></a> [bootstrap\_brokers](#input\_bootstrap\_brokers) | Comma-separated MSK SASL/SCRAM broker string (port 9096). | `string` | `""` | no |
| <a name="input_sasl_password"></a> [sasl\_password](#input\_sasl\_password) | SASL/SCRAM password. | `string` | `""` | no |
| <a name="input_sasl_username"></a> [sasl\_username](#input\_sasl\_username) | SASL/SCRAM username. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_topic_names"></a> [topic\_names](#output\_topic\_names) | Names of all topics created by the example. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->