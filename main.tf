
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


data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

data "databricks_spark_version" "gpu_ml" {
  ml  = true
}

/*resource "databricks_cluster" "tiny-packt" {
  cluster_name = "tiny-packt-etl"
  spark_version = data.databricks_spark_version.latest_lts.id
  node_type_id = "m5.large"
  autotermination_minutes = 10
    autoscale {
    min_workers = 1
    max_workers = 2
  }
#   spark_conf = {
#    "spark.databricks.cluster.profile" : "singleNode"
#    "spark.master" : "local[*]"
 # }
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
  cluster_name = "tiny-packt-ml"
  node_type_id = "g4dn.xlarge"
  autotermination_minutes = 10
   spark_version = data.databricks_spark_version.gpu_ml.id
    autoscale {
    min_workers = 1
    max_workers = 2
  }
 # spark_conf = {
 #   "spark.databricks.cluster.profile" : "singleNode"
 #   "spark.master" : "local[*]"
 # }
  aws_attributes {
    first_on_demand = 1
    availability = "SPOT_WITH_FALLBACK"
    zone_id = "us-west-2b"
    spot_bid_price_percent = 100
    ebs_volume_type = "GENERAL_PURPOSE_SSD"
    ebs_volume_count = 3
    ebs_volume_size = 100
  }
}*/


resource "databricks_job" "etl" {
 name = "etl"
 max_concurrent_runs = 1

 # job schedule
 #schedule {
 #  quartz_cron_expression = "0 0 0 ? 1/1 * *" # cron schedule of job
 #  timezone_id = "UTC"
 # }

 # notifications at job level
 email_notifications {
   on_success = ["bclipp770@gmail.com", "bclipp770@gmail.com"]
     on_start   = ["bclipp770@gmail.com"]
     on_failure = ["bclipp770@gmail.com"]
 }

   job_cluster {
   new_cluster {
     resource "databricks_library" "fbprophet" {
  cluster_id = databricks_cluster.Shared_job_cluster.id
  pypi {
    package = "etl-jobs==0.1.1"
    // repo can also be specified here
  }
}
     
    spark_version = data.databricks_spark_version.latest_lts.id
    node_type_id = "m5.large"
     #spark_env_vars = {
     #  PYSPARK_PYTHON = "/databricks/python3/bin/python3"
     #}
     num_workers        = 1
     data_security_mode = "NONE"

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
   job_cluster_key = "Shared_job_cluster"
 }

  task {
    task_key = "a_extract"
    job_cluster_key = "Shared_job_cluster"
    library {
     pypi {
       package = "etl-jobs"
     }
   }
        python_wheel_task {
      package_name = "etl-jobs"
      entry_point = "main"
    }

       # timeout and retries
   timeout_seconds = 1000
   min_retry_interval_millis = 900000
   max_retries = 1
  }



  task {
    task_key = "b_ransform_and_Load"
    job_cluster_key = "Shared_job_cluster"
   # you can stack multiple depends_on blocks
   depends_on {
     task_key = "a_extract"
   }

   # libraries needed
   library {
     pypi {
       package = "etl-jobs"
     }
   }
        python_wheel_task {
      package_name = "etl-jobs"
      entry_point = "main"
    }

   # timeout and retries
   timeout_seconds = 1000
   min_retry_interval_millis = 900000
   max_retries = 1
 }
}
