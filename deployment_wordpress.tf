resource "kubernetes_config_map" "wordpress_config" {
  metadata {
    name      = "wordpress-config"
    namespace = kubernetes_namespace.web.metadata.0.name
  }

  data = {
    wordpress-database-name = var.mysql_database_name
    wordpress-user-username = var.mysql_user_username
  }
}

resource "kubernetes_secret" "wordpress_secret" {
  metadata {
    name      = "wordpress-pass"
    namespace = kubernetes_namespace.web.metadata.0.name
  }

  data = {
    wordpress-user-password = var.mysql_user_password
  }
}

resource "kubernetes_service" "wordpress" {
  depends_on = [kubernetes_deployment.wordpress]
  metadata {
    name      = "wordpress-service"
    namespace = kubernetes_namespace.web.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.wordpress.metadata.0.labels.app
    }

    port {
      port        = 8080
      target_port = 80
    }

    type = "NodePort"

  }
}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = kubernetes_namespace.web.metadata.0.name
    labels = {
      app = "wordpress"
    }
  }
  spec {
    replicas = 1
    strategy {
      type = "RollingUpdate"
    }
    selector {
      match_labels = {
        app = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }
      spec {
        container {
          image = "wordpress:latest"
          name  = "wordpress"

          env {
            name  = "WORDPRESS_DB_HOST"
            value = "mysql-service.databases.svc.cluster.local"
          }

          env {
            name = "WORDPRESS_DB_NAME"
            value_from {
              config_map_key_ref {
                key  = "wordpress-database-name"
                name = kubernetes_config_map.wordpress_config.metadata.0.name
              }
            }
          }

          env {
            name = "WORDPRESS_DB_USER"
            value_from {
              config_map_key_ref {
                key  = "wordpress-user-username"
                name = kubernetes_config_map.wordpress_config.metadata.0.name
              }
            }
          }

          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "wordpress-user-password"
                name = kubernetes_secret.wordpress_secret.metadata.0.name
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "wordpress_ingress" {
  metadata {
    name      = "wordpress-ingress"
    namespace = kubernetes_namespace.web.metadata.0.name
  }

  spec {
    default_backend {
      service {
        name = kubernetes_service.wordpress.metadata.0.name
        port {
          number = 80
        }
      }
    }
  }
}
