resource "google_service_account" "nodes" {
  account_id   = var.node_identity
  display_name = "GKE nodes service account (${var.env_name})"
}

# Attach node roles to the node SA
resource "google_project_iam_member" "nodes_roles" {
  for_each = toset(var.node_identity_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

## Allow runner SA to act as the node SA
#resource "google_service_account_iam_member" "runner_act_as_nodes" {
#  service_account_id = google_service_account.nodes.name
#  role               = "roles/iam.serviceAccountUser"
#  member             = "serviceAccount:${var.runner_service_account_email}"
#}
