# MSK SASL_SSL + existing Kubernetes secret (key: client-passwords).
#
# Prerequisites:
# - MSK with SASL/SCRAM and Secrets Manager secret (e.g. AmazonMSK_<username>)
# - Secret in the target namespace (ExternalSecret or manual) with key client-passwords
# - kafka.sasl_user must match the MSK SCRAM username
#
# Replace broker URLs, namespace, hostname, and ingress annotations before apply.

module "schema_registry_msk" {
  source = "../.."

  name      = "schema-registry"
  namespace = "schema-registry"

  create_namespace = true

  chart_version = "26.0.5"
  helm_timeout  = 900

  replicas = 1

  kafka = {
    brokers = [
      "SASL_SSL://b-1.example.c8.kafka.eu-central-1.amazonaws.com:9096",
      "SASL_SSL://b-2.example.c8.kafka.eu-central-1.amazonaws.com:9096",
    ]
    listener_protocol    = "SASL_SSL"
    sasl_mechanism       = "SCRAM-SHA-512"
    sasl_user            = "schema-registry"
    sasl_existing_secret = "schema-registry-kafka-secret"
  }

  hostname = "schema-registry.example.com"

  ingress = {
    enabled            = true
    ingress_class_name = "alb"
    path               = "/*"
    path_type          = "ImplementationSpecific"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internal"
    }
  }
}
