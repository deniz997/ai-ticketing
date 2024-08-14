data "google_client_config" "default" {}
resource "google_container_cluster" "primary" {
  name     = "gke-cnae-cluster"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1
  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 0
      maximum       = 1
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 0
      maximum       = 2
    }

  }
}

resource "google_container_node_pool" "node_pool" {
  name       = "cnae-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_locations = [var.availability_zone]

  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-standard-4"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cnae-sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}