variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "availability_zone" {
  description = "GCP availability zone"
  type        = string
  default     = "us-central1-a"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "cnae-open-telemetrics"
}