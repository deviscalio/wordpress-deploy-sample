resource "kubernetes_role" "webdev_role" {
  metadata {
    name      = "webdev-role"
    namespace = kubernetes_namespace.web.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role" "webadmins_role_web" {
  metadata {
    name      = "webadmins-role"
    namespace = kubernetes_namespace.web.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role" "webadmins_role_databases" {
  metadata {
    name      = "webadmins-role"
    namespace = kubernetes_namespace.databases.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "webdev_rolebinding" {
  metadata {
    name      = "webdev-rolebinding"
    namespace = kubernetes_namespace.web.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.webdev_role.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "webdev"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_binding" "webadmins_rolebinding_web" {
  metadata {
    name      = "webadmins-rolebinding"
    namespace = kubernetes_namespace.web.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.webadmins_role_web.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "webadmins"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_binding" "webadmins_rolebinding_databases" {
  metadata {
    name      = "webadmins-rolebinding"
    namespace = kubernetes_namespace.databases.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.webadmins_role_databases.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "webadmins"
    api_group = "rbac.authorization.k8s.io"
  }
}
