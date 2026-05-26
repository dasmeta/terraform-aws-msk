module "schema_registry" {
  source = "../../"

  name      = "schema-registry"
  namespace = "schema-registry"

  kafka = {
    brokers = [
      "PLAINTEXT://kafka.example.internal:9092",
    ]
  }

  resources = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
  }
}

module "schema_registry_existing_sasl_secret" {
  source = "../../"

  name      = "schema-registry-secret"
  namespace = "schema-registry"

  create_namespace = false

  kafka = {
    brokers = [
      "SASL_PLAINTEXT://kafka.example.internal:9096",
    ]
    listener_protocol    = "SASL_PLAINTEXT"
    sasl_user            = "example-user"
    sasl_existing_secret = "kafka-sasl-credentials"
  }

  ingress = {
    enabled            = true
    ingress_class_name = "nginx"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt"
    }
    tls = true
  }

  hostname = "schema-registry.example.com"
  replicas = 2
}
