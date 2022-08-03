provider "helm" {
  kubernetes {
    config_path = "~/.kube/demo-config"
  }
}

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${var.dns_name}"
  bootstrap = true
}

resource "helm_release" "certmanager" {
  count            = var.ingress_tls_source == "secret" || var.ingress_tls_source == "external" ? 0 : 1

  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = "true"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.8.2"

  set{
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "rancher" {
  name              = "rancher"
  namespace         = "cattle-system"
  create_namespace  = "true"
  repository        = "https://releases.rancher.com/server-charts/stable"
  chart             = "rancher"
  version           = "2.6.6"
  
  set {
    name  = "hostname"
    value = var.dns_name
  }
  
  set {
    name  = "ingress.tls.source"
    value = var.ingress_tls_source
  }
  
  set {
    name  = "letsEncrypt.email"
    value = var.letsencrypt_email
  }
  
  set {
    name  = "letsEncrypt.ingress.class"
    value = var.letsencrypt_ingress_class
  }
  
  set {
    name  = "auditLog.level"
    value = "1"
  }

  set {
    name  = "privateCA"
    value = var.private_ca
  }

  set {
    name  = "bootstrapPassword"
    value = var.bootstrap_password
  }

  depends_on = [helm_release.certmanager]
}

module "iam" {
  count = var.aws_ccm ? 1 : 0
  source = "./modules/policies"

  tags = var.tags
}

module "bootstrap" {
  source = "./modules/bootstrap"
  providers = {rancher2 = rancher2.bootstrap}

  initial_password  = var.bootstrap_password
  rancher_url       = "https://${var.dns_name}"

  depends_on = [helm_release.rancher]
}
