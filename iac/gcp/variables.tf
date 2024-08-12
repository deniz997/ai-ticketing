variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "cnae-open-telemetrics"
}

variable "account_id" {
  description = "Service account ID"
  type        = string
  default     = "service-account-cnae"
}

variable "openai_key" {
    type = string
    nullable = false
    sensitive = true
}

variable "function_bucket_name" {
    type = string
    nullable = false
    default = "cnae_function"
}

variable "function_name" {
    type = string
    nullable = false
    default = "ai-ticketing"
}

variable "model_type" {
    type = string
    nullable = false
    default = "gpt-4o-mini"
}

variable "entry_point" {
    type = string
    nullable = false
    default = "ticketing"
}
