locals {
  normalized_resources = merge(
    length(try(var.resources.limits, {})) > 0 ? { limits = var.resources.limits } : {},
    length(try(var.resources.requests, {})) > 0 ? { requests = var.resources.requests } : {}
  )

  sasl_existing_secret = try(var.kafka.sasl_existing_secret, null)
  sasl_password        = try(var.kafka.sasl_password, null)
  sasl_user            = try(var.kafka.sasl_user, null)

  use_sasl_existing_secret = local.sasl_existing_secret != null && local.sasl_existing_secret != ""
  use_sasl_password        = local.sasl_password != null && local.sasl_password != ""

  external_kafka_sasl = merge(
    local.sasl_user != null && local.sasl_user != "" ? { user = local.sasl_user } : {},
    local.use_sasl_existing_secret ? { existingSecret = local.sasl_existing_secret } : {},
    local.use_sasl_password && !local.use_sasl_existing_secret ? { password = local.sasl_password } : {},
  )

  # Required when kafka.enabled is false; see bitnami/charts#16288 and research.md.
  kafka_workaround = {
    enabled = false
    auth = {
      protocol = {}
    }
    service = {
      ports = {
        client = {}
      }
    }
  }

  ingress_enabled = try(var.ingress.enabled, false)
  ingress_values = merge(
    {
      enabled          = local.ingress_enabled
      ingressClassName = try(var.ingress.ingress_class_name, "")
      path             = try(var.ingress.path, "/")
      pathType         = try(var.ingress.path_type, "ImplementationSpecific")
      annotations      = try(var.ingress.annotations, {})
      tls              = try(var.ingress.tls, false)
    },
    var.hostname != null ? { hostname = var.hostname } : {},
  )

  # Chart reads .Values.auth.kafka.saslMechanism (not kafka.saslMechanism).
  auth_kafka = try(var.kafka.sasl_mechanism, null) != null && var.kafka.sasl_mechanism != "" ? {
    auth = {
      kafka = {
        saslMechanism = var.kafka.sasl_mechanism
      }
    }
  } : {}

  helm_values = merge(
    {
      replicaCount = var.replicas
      listeners    = var.listeners
      kafka        = local.kafka_workaround
      externalKafka = merge(
        {
          brokers = var.kafka.brokers
          listener = {
            protocol = var.kafka.listener_protocol
          }
        },
        length(local.external_kafka_sasl) > 0 ? { sasl = local.external_kafka_sasl } : {},
      )
      service = {
        type = var.service_type
      }
      ingress = local.ingress_values
    },
    local.auth_kafka, # must stay separate from kafka_workaround (different Helm keys)
    length(local.normalized_resources) > 0 ? { resources = local.normalized_resources } : {},
    length(var.pod_labels) > 0 ? { podLabels = var.pod_labels } : {},
  )
}

resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  depends_on = [kubernetes_namespace_v1.this]

  name             = var.name
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "schema-registry"
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = false

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  wait            = var.wait
  timeout         = var.helm_timeout

  values = [
    file("${path.module}/values.yaml"),
    yamlencode(local.helm_values),
  ]

  # Highest-precedence guard: bundled Kafka must stay off for external/MSK brokers.
  set {
    name  = "kafka.enabled"
    value = "false"
    type  = "auto"
  }

  lifecycle {
    precondition {
      condition     = !local.use_sasl_existing_secret || !local.use_sasl_password
      error_message = "Set only one of kafka.sasl_existing_secret or kafka.sasl_password for SASL credentials."
    }

    precondition {
      condition     = !local.ingress_enabled || (var.hostname != null && var.hostname != "")
      error_message = "When ingress.enabled is true, set hostname to the public host for Schema Registry."
    }
  }
}
