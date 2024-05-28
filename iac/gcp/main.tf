terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "cnae-sa" {
  account_id   = "service-account-cnae"
  display_name = "Service Account cnae-open-telemetrics"
}
