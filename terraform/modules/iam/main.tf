data "google_service_account" "github_terraform" {
  account_id = "github-terraform@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-nodes"
  display_name = "GKE Nodes"
}

resource "google_service_account_iam_member" "impersonate_gke_nodes" {
  service_account_id = google_service_account.gke_nodes.name
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${data.google_service_account.github_terraform.email}"
}
