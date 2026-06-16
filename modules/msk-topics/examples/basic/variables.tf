variable "bootstrap_brokers" {
  type        = string
  default     = ""
  description = "Comma-separated MSK SASL/SCRAM broker string (port 9096)."
}

variable "sasl_username" {
  type        = string
  default     = ""
  description = "SASL/SCRAM username."
}

variable "sasl_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "SASL/SCRAM password."
}

variable "sasl_mechanism" {
  type        = string
  default     = "scram-sha512"
  description = "SASL mechanism: scram-sha256, scram-sha512, aws-iam, oauthbearer, or plain."
}
