
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


# https://www.databricks.com/blog/2022/12/5/databricks-workflows-through-terraform.html
# https://stackoverflow.com/questions/75579462/how-to-create-azure-databricks-jobs-of-type-python-wheel-by-terraform
#workflow 1: ML
#        1. create model
#          wheel pip install ml-jobs

#workflow 2: SCHEMA
#        1. deploy schema
#          wheel pip install schema-jobs

#workflow 3: ETL
#        1. get data
#          wheel ???? missing!!!!
#        2. ETL data
#          wheel pip install etl-jobs

#workflow 1: ETL Int Tests
#        1. run int tests
#          wheel pip install etl-jobs


resource "databricks_job" "etl" {
 name = "Job with multiple tasks"
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

    spark_version = data.databricks_spark_version.latest_lts.id
    node_type_id = "m5.large"
     #spark_env_vars = {
     #  PYSPARK_PYTHON = "/databricks/python3/bin/python3"
     #}
     num_workers        = 1
     data_security_mode = "NONE"
  spark_version = data.databricks_spark_version.latest_lts.id
  node_type_id = "m5.large"
  autotermination_minutes = 10

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
    task_key = "a"
    name = "Extract"
    library {
     pypi {
       package = "faker"
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
    name = "Transform and Load"
    task_key = "b"

   # you can stack multiple depends_on blocks
   depends_on {
     task_key = "name_of_my_first_task"
   }

   # libraries needed
   library {
     pypi {
       package = "faker"
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
