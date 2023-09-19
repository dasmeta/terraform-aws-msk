module "kafka" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "2.1.0"

  kafka_version                            = var.kafka_version
  number_of_broker_nodes                   = var.number_of_broker_nodes
  broker_node_client_subnets               = data.aws_subnets.private.ids
  broker_node_instance_type                = var.broker_node_instance_type
  broker_node_security_groups              = [aws_security_group.allow_kafka_connection.id]
  client_authentication                    = var.client_authentication
  cloudwatch_logs_enabled                  = var.cloudwatch_logs_enabled
  create_scram_secret_association          = var.create_scram_secret_association
  encryption_at_rest_kms_key_arn           = module.kms.key_arn
  scram_secret_association_secret_arn_list = [module.secrets.secret_id]

  depends_on = [
    module.kms,
    module.secrets,
    aws_security_group.allow_kafka_connection
  ]
}
