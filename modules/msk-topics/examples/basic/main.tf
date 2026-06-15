module "msk_topics" {
  source = "../../"

  bootstrap_brokers = var.bootstrap_brokers
  sasl_username     = var.sasl_username
  sasl_password     = var.sasl_password
  sasl_mechanism    = "scram-sha512"

  topics = {
    "example-orders" = {
      partitions         = 1
      replication_factor = 2
    }




  }
}
