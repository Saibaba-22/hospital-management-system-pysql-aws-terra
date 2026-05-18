resource "time_sleep" "wait_for_eks" {
  depends_on      = [aws_eks_node_group.sai01]
  create_duration = "120s"
}

resource "kubernetes_namespace_v1" "hospital_system" {
  metadata {
    name = "hospital-system"
  }

  depends_on = [time_sleep.wait_for_eks]
}

resource "kubectl_manifest" "frontend" {
  yaml_body = templatefile(
    "${path.module}/kubernetes/frontend.yaml.tpl",
    {
      frontend_image = var.frontend_image
    }
  )

  wait_for_rollout = false

  depends_on = [
    kubernetes_namespace_v1.hospital_system
  ]
}

resource "kubectl_manifest" "backend" {
  yaml_body = templatefile(
    "${path.module}/kubernetes/backend.yaml.tpl",
    {
      backend_image = var.backend_image
    }
  )

  wait_for_rollout = false

  depends_on = [
    kubernetes_namespace_v1.hospital_system,
    kubernetes_secret_v1.db_secret
  ]
}
