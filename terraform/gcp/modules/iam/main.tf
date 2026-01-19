resource "google_service_account" "nodes" {
  account_id   = var.node_identity
  display_name = "GKE nodes service account (${var.env_name})"
}

resource "google_project_iam_member" "nodes_roles" {
  for_each = toset(var.node_identity_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}
