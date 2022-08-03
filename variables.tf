variable "aws_ccm" {
  type    = bool
  default = false
}

variable "bootstrap_password" {
  type    = string
  default = ""
}

variable "dns_name" {
  type    = string
}

variable "ingress_tls_source" {
  type    = string
  default = "secret"

  validation {
    condition     = contains(["secret", "letsEncrypt", "rancher", "external"], var.ingress_tls_source)
    error_message = "ingress_tls_source valid values are: \"secret\", \"letsEncrypt\", \"rancher\", and \"external\""
  }
}

variable "letsencrypt_email" {
  type    = string
  default = ""
}

variable "letsencrypt_ingress_class" {
  type    = string
  default = "nginx"
}

variable "private_ca" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}