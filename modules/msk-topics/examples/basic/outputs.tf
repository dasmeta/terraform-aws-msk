output "topic_names" {
  description = "Names of all topics created by the example."
  value       = module.msk_topics.topic_names
}
