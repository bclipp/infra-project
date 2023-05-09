
terraform {
  cloud {
    organization = "chapter_8"

    workspaces {
      name = "cli"
    }
  }
required_providers {
    databricks = {
      source = "databricks/databricks"
      version = "1.0.0"
    }
  }
}

variable "HOST" {
  type = string
}

variable "TOKEN" {
  type = string
}


provider "databricks" {
  host = var.HOST
  token = var.TOKEN
}


data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "tiny" {
  cluster_name = "tiny"
  spark_version = data.databricks_spark_version.latest_lts.id
  node_type_id = "m4.large"
  driver_node_type_id = "m4.large"
  autotermination_minutes = 10
  autoscale {
    min_workers = 1
    max_workers = 2
  }
  aws_attributes {
    first_on_demand = 1
    availability = "SPOT_WITH_FALLBACK"
    zone_id = "us-west-2b"
    spot_bid_price_percent = 100
    ebs_volume_type = "GENERAL_PURPOSE_SSD"
    ebs_volume_count = 3
    ebs_volume_size = 100
  }
}
