variable "topics" {
  type = map(object({
    partitions         = number
    replication_factor = number
    config             = optional(map(string), {})
  }))
  description = "Map of Kafka topic definitions. Map key is the topic name."
}
