resource "kubernetes_config_map" "mysql_config" {
  metadata {
    name      = "mysql-config"
    namespace = kubernetes_namespace.databases.metadata.0.name
  }

  data = {
    mysql-database-name = var.mysql_database_name
    mysql-user-username = var.mysql_user_username
  }
}

resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name      = "mysql-pass"
    namespace = kubernetes_namespace.databases.metadata.0.name
  }

  data = {
    mysql-root-password = "r00tpwd$"
    mysql-user-password = var.mysql_user_password
  }
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name      = "mysql-service"
    namespace = kubernetes_namespace.databases.metadata.0.name
    labels = {
      app = "mysql-wordpress"
    }
  }

  spec {
    selector = {
      app  = kubernetes_deployment.mysql_deployment.metadata.0.labels.app
      tier = "mysql"
    }

    port {
      port = 3306
    }
  }
}

resource "kubernetes_deployment" "mysql_deployment" {
  metadata {
    name      = "mysql-wordpress"
    namespace = kubernetes_namespace.databases.metadata.0.name
    labels = {
      app = "mysql-wordpress"
    }
  }

  spec {
    selector {
      match_labels = {
        app  = "mysql-wordpress"
        tier = "mysql"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app  = "mysql-wordpress"
          tier = "mysql"
        }
      }

      spec {
        container {
          image = "mysql:latest"
          name  = "mysql"

          env {
            name = "MYSQL_DATABASE"
            value_from {
              config_map_key_ref {
                key  = "mysql-database-name"
                name = kubernetes_config_map.mysql_config.metadata.0.name

              }
            }
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "mysql-root-password"
                name = kubernetes_secret.mysql_secret.metadata.0.name

              }
            }
          }

          env {
            name = "MYSQL_USER"
            value_from {
              config_map_key_ref {
                key  = "mysql-user-username"
                name = kubernetes_config_map.mysql_config.metadata.0.name

              }
            }
          }

          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "mysql-user-password"
                name = kubernetes_secret.mysql_secret.metadata.0.name

              }
            }
          }

          liveness_probe {
            tcp_socket {
              port = 3306
            }
          }

          port {
            name           = "mysql"
            container_port = 3306
          }

          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
        }

        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql_pvc.metadata.0.name
          }
        }
      }
    }
  }
}
