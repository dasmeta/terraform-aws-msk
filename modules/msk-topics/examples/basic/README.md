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
