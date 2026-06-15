output "topic_names" {
  description = "List of all Kafka topic names managed by this module."
  value       = [for name, _ in var.topics : name]
}

output "topic_ids" {
  description = "Map of topic name to Terraform resource ID."
  value       = { for name, t in kafka_topic.topics : name => t.id }
}
