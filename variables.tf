variable "name" {
  type        = string
  description = "Kafka name"
  default     = "msk"
}

variable "kafka_version" {
  type        = string
  default     = "3.4.0"
  description = "Specify the desired Kafka software version"
}

variable "enable_kms_key_rotation" {
  type        = bool
  default     = true
  description = "KMS key rotation"
}

variable "broker_node_instance_type" {
  type        = string
  default     = "kafka.t3.small"
  description = "A list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster"
}

variable "number_of_broker_nodes" {
  type        = number
  default     = 3
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets"
}

variable "client_authentication" {
  description = "Configuration block for specifying a client authentication"
  type        = any
  default     = {}
}

variable "cloudwatch_logs_enabled" {
  description = "Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs"
  type        = bool
  default     = true
}

variable "create_scram_secret_association" {
  description = "Determines whether to create SASL/SCRAM secret association"
  type        = bool
  default     = true
}

variable "kafka_auth" {
  type = any
  default = {
    username = "dev",
    password = "AAaa123456789!!"
  }
  description = "Credentials which is using for connect kafka"
}

variable "vpc_id" {
  type        = string
  description = "The vpc where redis cluster will be created"
}

variable "ingress_access" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Use cidr for get access to connect kafka"
}
