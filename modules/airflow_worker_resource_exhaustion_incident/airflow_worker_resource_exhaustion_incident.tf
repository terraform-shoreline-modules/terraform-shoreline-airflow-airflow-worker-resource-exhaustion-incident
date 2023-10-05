resource "shoreline_notebook" "airflow_worker_resource_exhaustion_incident" {
  name       = "airflow_worker_resource_exhaustion_incident"
  data       = file("${path.module}/data/airflow_worker_resource_exhaustion_incident.json")
  depends_on = [shoreline_action.invoke_worker_diagnosis,shoreline_action.invoke_worker_scaling]
}

resource "shoreline_file" "worker_diagnosis" {
  name             = "worker_diagnosis"
  input_file       = "${path.module}/data/worker_diagnosis.sh"
  md5              = filemd5("${path.module}/data/worker_diagnosis.sh")
  description      = "The worker may not have been configured with enough resources to handle the workload it was given."
  destination_path = "/agent/scripts/worker_diagnosis.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "worker_scaling" {
  name             = "worker_scaling"
  input_file       = "${path.module}/data/worker_scaling.sh"
  md5              = filemd5("${path.module}/data/worker_scaling.sh")
  description      = "Scale up the number of airflow workers to ensure sufficient resources are available to handle the workload."
  destination_path = "/agent/scripts/worker_scaling.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_worker_diagnosis" {
  name        = "invoke_worker_diagnosis"
  description = "The worker may not have been configured with enough resources to handle the workload it was given."
  command     = "`chmod +x /agent/scripts/worker_diagnosis.sh && /agent/scripts/worker_diagnosis.sh`"
  params      = ["AIRFLOW_LOG_FILE","WORKER_PID","WORKER_CONFIG_FILE"]
  file_deps   = ["worker_diagnosis"]
  enabled     = true
  depends_on  = [shoreline_file.worker_diagnosis]
}

resource "shoreline_action" "invoke_worker_scaling" {
  name        = "invoke_worker_scaling"
  description = "Scale up the number of airflow workers to ensure sufficient resources are available to handle the workload."
  command     = "`chmod +x /agent/scripts/worker_scaling.sh && /agent/scripts/worker_scaling.sh`"
  params      = ["DESIRED_NUMBER_OF_WORKERS"]
  file_deps   = ["worker_scaling"]
  enabled     = true
  depends_on  = [shoreline_file.worker_scaling]
}

