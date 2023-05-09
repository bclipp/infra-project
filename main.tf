
terraform {
  cloud {
    organization = "brians_stuff"

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


data "databricks_spark_version" "ETL" {
  spark_version = "1"
  cluster_name = "tiny-etl"
  long_term_support = true
}

data "databricks_spark_version" "ML" {
  long_term_support = true
  spark_version = "13.0 ML"
  cluster_name = "tiny-ml"
}

resource "databricks_cluster" "tiny-packt" {
  cluster_name = "tiny"
  spark_version = data.databricks_spark_version.etl.id
  node_type_id = "m5.large"
  autotermination_minutes = 10
  autoscale {
    min_workers = 1
    max_workers = 2
  }
   spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
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

resource "databricks_cluster" "tiny-packt-ml" {
  cluster_name = "tiny"
  spark_version = data.databricks_spark_version.databricks_spark_version.id
  node_type_id = "g4dn.xlarge"
  autotermination_minutes = 10
  autoscale {
    min_workers = 1
    max_workers = 2
  }
     spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
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

