terraform {
  required_providers {
    pingfederate = {
      source  = "iwarapter/pingfederate"
      version = "0.1.1"
    }
  }
}

provider "pingfederate" {
  username = "Administrator"
  password = "Passw0rd"
  base_url = "https://pingfederate.internal.darkedges.com"
  context  = "/pf-admin-api/v1"
}

# Create a DataStore
resource "pingfederate_ldap_data_store" "connectid" {
  name             = "connectid"
  ldap_type        = "PING_DIRECTORY"
  hostnames        = ["pingdirectory-directory-0.pingdirectory-directory.pingfederate:636"]
  user_dn          = "cn=Directory Manager"
  password         = "Passw0rd"
  use_ssl          = true
  bind_anonymously = false
  min_connections  = 1
  max_connections  = 10
}

# Craete Passworc Credential Validator
resource "pingfederate_password_credential_validator" "connectid" {
  name = "connectid"
  plugin_descriptor_ref {
    id = "org.sourceid.saml20.domain.LDAPUsernamePasswordCredentialValidator"
  }
  configuration {
    fields {
      name  = "LDAP Datastore"
      value = pingfederate_ldap_data_store.connectid.id
    }
    fields {
      name  = "Search Base"
      value = "ou=People,dc=darkedges,dc=com"
    }
    fields {
      name  = "Search Filter"
      value = "uid=$${username}"
    }
  }
}

#Create an TML Form IDP Adapter
resource "pingfederate_idp_adapter" "connectid" {
  name = "connectid"
  plugin_descriptor_ref {
    id = "com.pingidentity.adapters.htmlform.idp.HtmlFormIdpAuthnAdapter"
  }
  configuration {
    tables {
      name = "Credential Validators"
      rows {
        fields {
          name  = "Password Credential Validator Instance"
          value = pingfederate_password_credential_validator.connectid.name
        }
      }
    }
    fields {
      name  = "Login Template"
      value = "html.form.login.template.html"
    }
    fields {
      name  = "Challenge Retries"
      value = 3
    }
  }
  attribute_contract {
    core_attributes {
      name = "policy.action"
    }
    core_attributes {
      name      = "username"
      pseudonym = true
    }
  }
}

## Need for API Only

resource "pingfederate_authentication_policies_settings" "connectid" {
  enable_idp_authn_selection = true
  enable_sp_authn_selection  = false
}

resource "pingfederate_authentication_policy_contract" "connectid" {
  name                = "connectid"
  extended_attributes = ["given_name", "family_name", "birthdate", "email", "phone_number", "address", "address.street_address", "address.locality", "address.region", "address.postal_code", "address.country"]
}

resource "pingfederate_authentication_selector" "connectid" {
  name = "connectid"
  plugin_descriptor_ref {
    id = "com.pingidentity.pf.selectors.http.HTTPHeaderAdapterSelector"
  }
  configuration {
    tables {
      name = "Results"
      rows {
        fields {
          name  = "Match Expression"
          value = "mobiledevice"
        }
      }
    }
    fields {
      name  = "Header Name"
      value = "User-Agent"
    }
    fields {
      name  = "Case-Sensitive Matching"
      value = false
    }
  }
}

resource "pingfederate_idp_adapter" "connectidconsent" {
  name = "consent"
  plugin_descriptor_ref {
    id = "com.pingidentity.pf.adapters.referenceid.IdpBackchannelReferenceAuthnAdapter"
  }
  configuration {
    fields {
      name  = "Authentication Endpoint"
      value = "https://null"
    }
    fields {
      name  = "Reference Duration"
      value = 3
    }
    fields {
      name  = "Reference Length"
      value = 30
    }
    fields {
      name  = "User Name"
      value = "consent"
    }
    fields {
      name  = "Pass Phrase"
      value = "Passw0rd"
    }
  }
  attribute_contract {
    core_attributes {
      name      = "subject"
      pseudonym = true
    }
    extended_attributes {
      name = "approvedclaims"
    }
  }
}

resource "pingfederate_authentication_policies" "connectid" {
  fail_if_no_selection = false
  authn_selection_trees {
    name = "connectid"
    root_node {
      action {
        type = "AUTHN_SELECTOR"
        authentication_selector_ref {
          id = pingfederate_authentication_selector.connectid.id
        }
      }
      children {
        action {
          type    = "AUTHN_SOURCE"
          context = "No"
          authentication_source {
            type = "IDP_ADAPTER"
            source_ref {
              id = pingfederate_idp_adapter.connectid.id
            }
          }
        }
        children {
          action {
            type    = "DONE"
            context = "Fail"
          }
        }
        children {
          action {
            type    = "APC_MAPPING"
            context = "Success"
            authentication_policy_contract_ref {
              id = pingfederate_authentication_policy_contract.connectid.id
            }
            attribute_mapping {
              attribute_contract_fulfillment {
                key_name = "address"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "address.street_address"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "address.locality"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "address.country"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "address.postal_code"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "address.region"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "subject"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "birthdate"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "family_name"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "given_name"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "email"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
              attribute_contract_fulfillment {
                key_name = "phone_number"
                source {
                  type = "ADAPTER"
                  id   = "connectid"
                }
                value = "username"
              }
            }
          }
        }
      }
      children {
        action {
          type    = "AUTHN_SOURCE"
          context = "Yes"
          authentication_source {
            type = "IDP_ADAPTER"
            source_ref {
              id = pingfederate_idp_adapter.connectidconsent.id
            }
          }
        }
        children {
          action {
            type    = "DONE"
            context = "Fail"
          }
        }
        children {
          action {
            type    = "APC_MAPPING"
            context = "Success"
            authentication_policy_contract_ref {
              id = pingfederate_authentication_policy_contract.connectid.id
            }
            attribute_mapping {
              attribute_contract_fulfillment {
                key_name = "address"
                source {
                  type = "TEXT"
                }
                value = "address"
              }
              attribute_contract_fulfillment {
                key_name = "address.street_address"
                source {
                  type = "TEXT"
                }
                value = "address.street_address"
              }
              attribute_contract_fulfillment {
                key_name = "address.locality"
                source {
                  type = "TEXT"
                }
                value = "address.locality"
              }
              attribute_contract_fulfillment {
                key_name = "address.country"
                source {
                  type = "TEXT"
                }
                value = "address.country"
              }
              attribute_contract_fulfillment {
                key_name = "address.postal_code"
                source {
                  type = "TEXT"
                }
                value = "address.postal_code"
              }
              attribute_contract_fulfillment {
                key_name = "address.region"
                source {
                  type = "TEXT"
                }
                value = "address.region"
              }
              attribute_contract_fulfillment {
                key_name = "subject"
                source {
                  type = "TEXT"
                }
                value = "subject"
              }
              attribute_contract_fulfillment {
                key_name = "birthdate"
                source {
                  type = "TEXT"
                }
                value = "birthdate"
              }
              attribute_contract_fulfillment {
                key_name = "family_name"
                source {
                  type = "TEXT"
                }
                value = "family_name"
              }
              attribute_contract_fulfillment {
                key_name = "given_name"
                source {
                  type = "TEXT"
                }
                value = "given_name"
              }
              attribute_contract_fulfillment {
                key_name = "email"
                source {
                  type = "TEXT"
                }
                value = "email"
              }
              attribute_contract_fulfillment {
                key_name = "phone_number"
                source {
                  type = "TEXT"
                }
                value = "phone_number"
              }
            }
          }
        }
      }
    }
  }
}

resource "pingfederate_oauth_openid_connect_policy" "connectid" {
  policy_id                     = "connectid"
  name                          = "connectid"
  include_shash_in_id_token     = true
  include_user_info_in_id_token = true
  access_token_manager_ref {
    id = pingfederate_oauth_access_token_manager.connectid.id
  }
  attribute_contract {
    extended_attributes {
      name                 = "address.country"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "address.locality"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "address.postal_code"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "address.region"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "address.street_address"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "family_name"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "given_name"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "phone_number"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "birthdate"
      include_in_id_token  = true
      include_in_user_info = true
    }
    extended_attributes {
      name                 = "email"
      include_in_id_token  = true
      include_in_user_info = true
    }
  }
  attribute_mapping {
    attribute_contract_fulfillment {
      key_name = "sub"
      source {
        type = "TOKEN"
      }
      value = "subject"
    }
    attribute_contract_fulfillment {
      key_name = "given_name"
      source {
        type = "TOKEN"
      }
      value = "given_name"
    }
    attribute_contract_fulfillment {
      key_name = "family_name"
      source {
        type = "TOKEN"
      }
      value = "family_name"
    }
    attribute_contract_fulfillment {
      key_name = "birthdate"
      source {
        type = "TOKEN"
      }
      value = "birthdate"
    }
    attribute_contract_fulfillment {
      key_name = "phone_number"
      source {
        type = "TOKEN"
      }
      value = "phone_number"
    }
    attribute_contract_fulfillment {
      key_name = "email"
      source {
        type = "TOKEN"
      }
      value = "email"
    }
    attribute_contract_fulfillment {
      key_name = "address.country"
      source {
        type = "TOKEN"
      }
      value = "address.country"
    }
    attribute_contract_fulfillment {
      key_name = "address.locality"
      source {
        type = "TOKEN"
      }
      value = "address.locality"
    }
    attribute_contract_fulfillment {
      key_name = "address.postal_code"
      source {
        type = "TOKEN"
      }
      value = "address.postal_code"
    }
    attribute_contract_fulfillment {
      key_name = "address.street_address"
      source {
        type = "TOKEN"
      }
      value = "address.street_address"
    }
    attribute_contract_fulfillment {
      key_name = "address.region"
      source {
        type = "TOKEN"
      }
      value = "address.region"
    }
  }
  scope_attribute_mappings {
    key_name = "openid"
    values   = ["address.country", "address.locality", "address.postal_code", "address.region", "address.street_address", "birthdate", "email", "family_name", "given_name", "phone_number"]
  }
}

resource "pingfederate_oauth_auth_server_settings" "connectid" {
  scopes {
    name        = "openid"
    description = "openid"
  }
  default_scope_description  = ""
  authorization_code_timeout = 60
  refresh_rolling_interval   = 0
  authorization_code_entropy = 30
  refresh_token_length       = 42
}

resource "pingfederate_oauth_authentication_policy_contract_mapping" "connectid" {
  authentication_policy_contract_ref = pingfederate_authentication_policy_contract.connectid.id
  attribute_contract_fulfillment = {
    "USER_NAME" = {
      source = {
        type = "AUTHENTICATION_POLICY_CONTRACT"
      }
      value = "subject"
    },
    "USER_KEY" = {
      source = {
        type = "AUTHENTICATION_POLICY_CONTRACT"
      }
      value = "subject"
    }
  }
}

resource "pingfederate_oauth_access_token_mappings" "connectid" {
  access_token_manager_ref {
    id = pingfederate_oauth_access_token_manager.connectid.id
  }
  context {
    type = "AUTHENTICATION_POLICY_CONTRACT"
    context_ref {
      id = pingfederate_oauth_authentication_policy_contract_mapping.connectid.id
    }
  }
  attribute_contract_fulfillment {
    key_name = "birthdate"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "birthdate"
  }
  attribute_contract_fulfillment {
    key_name = "phone_number"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "phone_number"
  }
  attribute_contract_fulfillment {
    key_name = "given_name"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "given_name"
  }
  attribute_contract_fulfillment {
    key_name = "email"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "email"
  }
  attribute_contract_fulfillment {
    key_name = "family_name"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "family_name"
  }
  attribute_contract_fulfillment {
    key_name = "phone_number"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "phone_number"
  }
  attribute_contract_fulfillment {
    key_name = "birthdate"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "birthdate"
  }
  attribute_contract_fulfillment {
    key_name = "email"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "email"
  }
  attribute_contract_fulfillment {
    key_name = "address.country"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "address.country"
  }
  attribute_contract_fulfillment {
    key_name = "address.street_address"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "address.street_address"
  }
  attribute_contract_fulfillment {
    key_name = "address.locality"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "address.locality"
  }
  attribute_contract_fulfillment {
    key_name = "address.postal_code"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "address.postal_code"
  }
  attribute_contract_fulfillment {
    key_name = "address.region"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "address.region"
  }
  attribute_contract_fulfillment {
    key_name = "address"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "address"
  }
  attribute_contract_fulfillment {
    key_name = "subject"
    source {
      type = "AUTHENTICATION_POLICY_CONTRACT"
    }
    value = "subject"
  }
}

# Create an OAuth Access Token Manager
resource "pingfederate_oauth_access_token_manager" "connectid" {
  instance_id = "connectid"
  name        = "connectid"
  plugin_descriptor_ref {
    id = "org.sourceid.oauth20.token.plugin.impl.ReferenceBearerAccessTokenManagementPlugin"
  }
  configuration {
    fields {
      name  = "Token Length"
      value = "28"
    }
    fields {
      name  = "Token Lifetime"
      value = "120"
    }
    fields {
      name  = "Lifetime Extension Policy"
      value = "ALL"
    }
    fields {
      name  = "Maximum Token Lifetime"
      value = ""
    }
    fields {
      name  = "Lifetime Extension Threshold Percentage"
      value = "30"
    }
    fields {
      name  = "Mode for Synchronous RPC"
      value = "3"
    }
    fields {
      name  = "RPC Timeout"
      value = "500"
    }
    fields {
      name  = "Expand Scope Groups"
      value = "false"
    }
  }

  attribute_contract {
    extended_attributes = ["subject", "given_name", "family_name", "birthdate", "email", "phone_number", "address", "address.street_address", "address.locality", "address.region", "address.postal_code", "address.country"]
  }
}



# Create an OAuth Client
resource "pingfederate_oauth_client" "connectid" {
  client_id                        = "connectid"
  name                             = "connectid"
  grant_types                      = ["AUTHORIZATION_CODE", "IMPLICIT", "ACCESS_TOKEN_VALIDATION"]
  allow_authentication_api_init    = true
  default_access_token_manager_ref = pingfederate_oauth_access_token_manager.connectid.id
  client_auth = {
    type                      = "PRIVATE_KEY_JWT"
    enforce_replay_prevention = true
  }
  jwks_settings = {
    jwks = "{\"keys\": [{\"kty\" : \"EC\", \"use\" : \"sig\", \"crv\" : \"P-256\", \"x\" : \"5_uam25BXdfAyE6wWBppzXjqyqh57dZMdwV3roRBptk\", \"y\" : \"OE4PRP_3fHUOBtKQnSkdweV-W67G0a2ji2zNofsGJ6A\", \"alg\" : \"ES256\"}]}"
  }
  redirect_uris                         = ["https://localhost/oidc/callback"]
  require_pushed_authorization_requests = true
  require_signed_requests               = true
  require_proof_key_for_code_exchange   = true
  restricted_scopes                     = ["openid"]
  restrict_scopes                       = true
  bypass_approval_page                  = true
}
