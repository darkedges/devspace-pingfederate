provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

variable "coreservices" {
  type    = string
  default = "darkedges"
}

variable "bound_service_account_namespaces" {
  type    = list(string)
  default = ["darkedges"]
}

variable "bound_service_account_names" {
  type    = list(string)
  default = ["darkedges-idam-certmanager"]
}


data "kubernetes_service_account" "certmanager" {
  metadata {
    name      = "${var.coreservices}-certmanager"
    namespace = var.namespace
  }
}

data "kubernetes_secret" "certmanager" {
  metadata {
    name      = data.kubernetes_service_account.certmanager.default_secret_name
    namespace = var.namespace
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.docker.internal:6443"
  kubernetes_ca_cert     = data.kubernetes_secret.certmanager.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.certmanager.data["token"]
  issuer                 = "api"
  disable_iss_validation = "true"
}

resource "vault_policy" "certmanager-policy" {
  name = "certmanager-policy"

  policy = <<EOT
path "${var.namespace}_idam_intermediate/*" {
  capabilities = ["read","list","delete","update","create"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "certmanager" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "certmanager"
  bound_service_account_names      = var.bound_service_account_names
  bound_service_account_namespaces = var.bound_service_account_namespaces
  token_ttl                        = 3600
  token_policies                   = [vault_policy.certmanager-policy.name]
  audience                         = null
}

resource "vault_mount" "idam_secret_engine" {
  path        = "idam"
  type        = "kv-v2"
  description = "IDAM Key-Value Store"
}

resource "vault_policy" "idam-read-only-policy" {
  name = "idam-read-only"

  policy = <<EOT
path "idam/*" {
    capabilities = ["read", "list"] 
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "auth_backend_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "idam-read-only"
  bound_service_account_names      = var.bound_service_account_names
  bound_service_account_namespaces = var.bound_service_account_namespaces
  token_policies                   = [vault_policy.idam-read-only-policy.name]
}
