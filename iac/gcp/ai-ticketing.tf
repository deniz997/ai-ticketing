resource "google_storage_bucket" "ai-ticketing-bucket" {
  name                        = var.function_bucket_name # Every bucket name must be globally unique
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "default" {
  type        = "zip"
  output_path = "/tmp/function-source.zip"
  source_dir  = "../../src/ticketingservice"
}

resource "google_storage_bucket_object" "object" {
  name   = "ai-ticketing-source.zip"
  bucket = google_storage_bucket.ai-ticketing-bucket.name
  source = data.archive_file.default.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "ai-ticketing" {
  name        = var.function_name
  location    = var.region
  description = "Bridging function between ChatGPT and OtelDemo for AI ticketing"

  build_config {
    runtime     = "nodejs22"
    entry_point = var.entry_point # Set the entry point
    
    source {
      storage_source {
        bucket = google_storage_bucket.ai-ticketing-bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    service_account_email = google_service_account.cnae-sa.email
    
    environment_variables = {
        MODEL_TYPE: var.model_type
    }

    secret_environment_variables {
      key        = "OPENAI_API_KEY"
      project_id = var.project_id
      secret     = google_secret_manager_secret.openaikey.secret_id
      version    = "latest"
    }

    secret_environment_variables {
      key        = "NOTION_API_KEY"
      project_id = var.project_id
      secret     = google_secret_manager_secret.openaikey.secret_id
      version    = "latest"
    }
  }
}

resource "google_cloud_run_service_iam_member" "member" {
  location = google_cloudfunctions2_function.ai-ticketing.location
  service  = google_cloudfunctions2_function.ai-ticketing.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_secret_manager_secret_iam_binding" "secret_accessor" {
  secret_id = google_secret_manager_secret.openaikey.secret_id
  role      = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${google_service_account.cnae-sa.email}",
  ]
}

resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  secret_id = google_secret_manager_secret.openaikey.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cnae-sa.email}"
}

resource "google_secret_manager_secret" "openaikey" {
  secret_id = "openaikey"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret" {
  secret = google_secret_manager_secret.openaikey.name

  secret_data = var.openai_key
  enabled = true
}

resource "google_secret_manager_secret" "notionapikey" {
  secret_id = "notion_apikey"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret" {
  secret = google_secret_manager_secret.notionapikey.name

  secret_data = var.notion_apikey
  enabled = true
}

output "function_uri" {
  value = google_cloudfunctions2_function.ai-ticketing.service_config[0].uri
}

resource "local_file" "otel_configmap_template" {
  content  = templatefile("../../kubernetes/opentelemetry-demo.tpl", { ai_ticketing_endpoint = google_cloudfunctions2_function.ai-ticketing.service_config[0].uri })
  filename = "../../kubernetes/opentelemetry-demo.yaml"
}