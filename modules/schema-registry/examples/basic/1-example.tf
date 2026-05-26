# Example Schema Registry deployment against consumer-managed Kafka.
#
# Prerequisites:
# - Existing Kubernetes cluster (Helm + Kubernetes providers configured)
# - Reachable Kafka bootstrap endpoint from the cluster
#
# Replace broker URL and secrets before apply. Do not commit real credentials.

module "schema_registry" {
  source = "../.."

  name      = "schema-registry"
  namespace = "schema-registry"

  create_namespace = true
  chart_version    = "26.0.5"
  helm_timeout     = 900

  kafka = {
    brokers = [
      "PLAINTEXT://kafka.example.internal:9092",
    ]
    listener_protocol = "PLAINTEXT"
  }

  replicas = 1

  resources = {
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "1000m"
      memory = "1Gi"
    }
  }
}

module "schema_registry_with_ingress" {
  source = "../.."

  name      = "schema-registry-ingress"
  namespace = "schema-registry"

  create_namespace = false

  hostname = "schema-registry.example.com"

  kafka = {
    brokers = [
      "PLAINTEXT://kafka.example.internal:9092",
    ]
  }

  ingress = {
    enabled            = true
    ingress_class_name = "alb"
    path               = "/"
    path_type          = "Prefix"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internal"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }
}

module "schema_registry_sasl" {
  source = "../.."

  name      = "schema-registry-sasl"
  namespace = "schema-registry"

  create_namespace = false

  kafka = {
    brokers = [
      "SASL_PLAINTEXT://kafka.example.internal:9096",
    ]
    listener_protocol = "SASL_PLAINTEXT"
    sasl_user         = "example-user"
    sasl_password     = "change-me"
  }
}
