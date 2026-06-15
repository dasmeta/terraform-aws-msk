provider "kafka" {
  bootstrap_servers = split(",", var.bootstrap_brokers)
  tls_enabled       = true
  sasl_username     = var.sasl_username
  sasl_password     = var.sasl_password
  sasl_mechanism    = var.sasl_mechanism
}
