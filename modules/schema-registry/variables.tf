variable "name" {
  type        = string
  default     = "schema-registry"
  description = "Name of the Helm release."
}

variable "namespace" {
  type        = string
  default     = "schema-registry"
  description = "Kubernetes namespace for Schema Registry."
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Create the namespace with the Kubernetes provider before the Helm release."
}

variable "chart_version" {
  type        = string
  default     = "26.0.5"
  description = "Version of the Bitnami schema-registry Helm chart."
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm wait timeout in seconds."
}

variable "atomic" {
  type        = bool
  default     = true
  description = "Wait for release to succeed and roll back on failure."
}

variable "cleanup_on_fail" {
  type        = bool
  default     = true
  description = "Allow deletion of new resources created when an upgrade fails."
}

variable "wait" {
  type        = bool
  default     = true
  description = "Wait until all resources are ready."
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Number of Schema Registry replicas (chart value replicaCount)."
}

variable "hostname" {
  type        = string
  default     = null
  description = "Hostname for Ingress when ingress.enabled is true."
}

variable "kafka" {
  type = object({
    brokers              = list(string)
    listener_protocol    = optional(string, "PLAINTEXT")
    sasl_mechanism       = optional(string)
    sasl_user            = optional(string)
    sasl_password        = optional(string)
    sasl_existing_secret = optional(string)
  })
  description = "Consumer-managed Kafka connection (externalKafka). Brokers use protocol://host:port entries. Set sasl_mechanism (e.g. SCRAM-SHA-512 for MSK) when using SASL."
}

variable "listeners" {
  type        = string
  default     = "http://0.0.0.0:8081"
  description = "Schema Registry HTTP listeners (chart value listeners)."
}

variable "service_type" {
  type        = string
  default     = "ClusterIP"
  description = "Kubernetes Service type for Schema Registry (chart value service.type)."
}

variable "ingress" {
  type = object({
    enabled            = optional(bool, false)
    ingress_class_name = optional(string)
    annotations        = optional(map(string), {})
    path               = optional(string, "/")
    path_type          = optional(string, "ImplementationSpecific")
    tls                = optional(bool, false)
  })
  default     = {}
  description = "Ingress configuration for consumer-managed controllers (ALB, nginx, etc.)."
}

variable "resources" {
  type = object({
    limits   = optional(map(string), {})
    requests = optional(map(string), {})
  })
  default     = {}
  description = "Container resources for Schema Registry pods."
}

variable "pod_labels" {
  type        = map(string)
  default     = {}
  description = "Extra labels for Schema Registry pods."
}
