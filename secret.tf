module "secrets" {
  source  = "dasmeta/modules/aws//modules/secret"
  version = "2.6.3"

  kms_key_id              = module.kms.key_arn
  name                    = "AmazonMSK_${var.name}"
  recovery_window_in_days = 0
  value = {
    "password" : var.kafka_auth.username,
    "username" : var.kafka_auth.username
  }

  depends_on = [
    module.kms
  ]
}
