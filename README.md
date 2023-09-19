# terraform-aws-msk

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kafka"></a> [kafka](#module\_kafka) | terraform-aws-modules/msk-kafka-cluster/aws | 2.1.0 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | 2.0.0 |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | dasmeta/modules/aws//modules/secret | 2.6.3 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.allow_kafka_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_broker_node_instance_type"></a> [broker\_node\_instance\_type](#input\_broker\_node\_instance\_type) | A list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster | `string` | `"kafka.t3.small"` | no |
| <a name="input_client_authentication"></a> [client\_authentication](#input\_client\_authentication) | Configuration block for specifying a client authentication | `any` | `{}` | no |
| <a name="input_cloudwatch_logs_enabled"></a> [cloudwatch\_logs\_enabled](#input\_cloudwatch\_logs\_enabled) | Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs | `bool` | `true` | no |
| <a name="input_create_scram_secret_association"></a> [create\_scram\_secret\_association](#input\_create\_scram\_secret\_association) | Determines whether to create SASL/SCRAM secret association | `bool` | `true` | no |
| <a name="input_enable_kms_key_rotation"></a> [enable\_kms\_key\_rotation](#input\_enable\_kms\_key\_rotation) | KMS key rotation | `bool` | `true` | no |
| <a name="input_ingress_access"></a> [ingress\_access](#input\_ingress\_access) | Use cidr for get access to connect kafka | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_kafka_auth"></a> [kafka\_auth](#input\_kafka\_auth) | Credentials which is using for connect kafka | `any` | <pre>{<br>  "password": "AAaa123456789!!",<br>  "username": "dev"<br>}</pre> | no |
| <a name="input_kafka_version"></a> [kafka\_version](#input\_kafka\_version) | Specify the desired Kafka software version | `string` | `"3.4.0"` | no |
| <a name="input_name"></a> [name](#input\_name) | Kafka name | `string` | `"msk"` | no |
| <a name="input_number_of_broker_nodes"></a> [number\_of\_broker\_nodes](#input\_number\_of\_broker\_nodes) | The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets | `number` | `3` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The vpc where redis cluster will be created | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
