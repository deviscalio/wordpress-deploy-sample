resource "kubernetes_namespace" "web" {
  metadata {
    name = "web"
  }
}

resource "kubernetes_namespace" "databases" {
  metadata {
    name = "databases"
  }
}
