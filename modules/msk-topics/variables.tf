variable "bootstrap_brokers" {
  type        = string
  description = "Comma-separated MSK SASL/SCRAM bootstrap broker string (port 9096). Use the SASL endpoint, not the TLS-only endpoint."
}

variable "sasl_username" {
  type        = string
  default     = ""
  description = "SASL/SCRAM username. Leave empty for TLS-only auth (not applicable to SCRAM-enabled MSK clusters)."
}

variable "sasl_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "SASL/SCRAM password. Pass via workspace secret or DSL secret interpolation — never hardcode."
}

variable "sasl_mechanism" {
  type        = string
  default     = "scram-sha512"
  description = "SASL mechanism. Accepted values: 'scram-sha256', 'scram-sha512'. Defaults to scram-sha512."
}

variable "topics" {
  type = map(object({
    partitions         = number
    replication_factor = number
    config             = optional(map(string), {})
  }))
  description = "Map of Kafka topic definitions. Map key is the topic name."
}
