module "msk_topics" {
  source = "../../"

  topics = {
    "example-orders" = {
      partitions         = 6
      replication_factor = 3
      config = {
        "retention.ms"   = "604800000"
        "cleanup.policy" = "delete"
      }
    }

    "example-audit-log" = {
      partitions         = 3
      replication_factor = 3
      config = {
        "cleanup.policy" = "compact"
      }
    }

    "example-notifications" = {
      partitions         = 3
      replication_factor = 3
    }
  }
}
