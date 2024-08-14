provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "kubeshark" {
  metadata {
    name = "kubeshark"
  }
}

resource "helm_release" "kubeshark" {
  name       = "kubeshark"
  repository = "https://helm.kubeshark.co"
  chart      = "kubeshark"
  version    = "52.3.74"
  namespace  = kubernetes_namespace.kubeshark.id
  depends_on = [
    kubernetes_namespace.kubeshark
  ]
  set {
    name  = "tap.namespaces"
    value = "otel-demo"
  }
}
