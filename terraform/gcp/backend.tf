terraform {
  backend "gcs" {
    bucket = "github_actions-k8s-terraform-state"
  }
}
