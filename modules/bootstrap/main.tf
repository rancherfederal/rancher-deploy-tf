resource "rancher2_bootstrap" "bootstrap" {
  initial_password = var.initial_password
  telemetry        = false
}