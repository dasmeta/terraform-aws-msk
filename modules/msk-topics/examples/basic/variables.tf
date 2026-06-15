# DO NOT COMMIT — default values are for local testing only
variable "bootstrap_brokers" {
  type        = string
  description = "Comma-separated MSK SASL/SCRAM broker string (port 9096)."
  default     = ""
}

variable "sasl_username" {
  type        = string
  description = "SASL/SCRAM username."
  default     = ""
}

variable "sasl_password" {
  type        = string
  sensitive   = true
  description = "SASL/SCRAM password."
  default     = ""
}
