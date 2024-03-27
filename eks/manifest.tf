resource "kubectl_manifest" "anonymous_role" {
  yaml_body = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: anonymous-role
    rules:
    - apiGroups: ["*"]
      resources: ["*"]
      verbs: ["*"]
  EOF
}

resource "kubectl_manifest" "anonymous_role_binding" {
  yaml_body = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: anonymous-binding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: anonymous-role
    subjects:
    - apiGroup: rbac.authorization.k8s.io
      kind: User
      name: system:anonymous
  EOF
}

resource "kubectl_manifest" "eni_config" {
  for_each = zipmap(var.availability_zones, var.subnet_ids_eks_custom)

  yaml_body = yamlencode({
    apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
    kind       = "ENIConfig"
    metadata = {
      name = each.key
    }
    spec = {
      securityGroups = [
        module.eks.cluster_primary_security_group_id,
      ]
      subnet = each.value
    }
  })
}