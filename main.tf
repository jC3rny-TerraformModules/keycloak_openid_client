
locals {
  keycloak_openid_client_scope = {
    for k, v in var.keycloak_openid_client_scope : k => {
      name        = coalesce(v.name, k)
      description = try(v.description, null)
      #
      include_in_token_scope = coalesce(v.include_in_token_scope, true)
    }
  }
  #
  keycloak_generic_protocol_mapper = {
    for k, v in var.keycloak_generic_protocol_mapper : k => {
      client_scope_name = coalesce(v.name, k)
      #
      name     = coalesce(v.name, k)
      protocol = coalesce(v.protocol, "openid-connect")
      #
      protocol_mapper = v.protocol_mapper
      config          = v.config
    }
  }
  #
  keycloak_openid_client = {
    for k, v in var.keycloak_openid_client : k => {
      enabled = coalesce(v.enabled, true)
      #
      client_id = coalesce(v.client_id, k)
      name      = try(v.name, null)
      #
      root_url            = v.root_url
      base_url            = try(v.base_url, "")
      valid_redirect_uris = v.valid_redirect_uris
      web_origins         = flatten([coalesce(v.web_origins, []), [v.root_url]])
      admin_url           = coalesce(v.admin_url, v.root_url)
      #
      access_type                  = coalesce(v.access_type, "CONFIDENTIAL")
      standard_flow_enabled        = coalesce(v.standard_flow_enabled, true)
      direct_access_grants_enabled = coalesce(v.direct_access_grants_enabled, true)
    }
  }
  #
  keycloak_openid_client_default_scopes = { for k, v in var.keycloak_openid_client : k => distinct(flatten([var.keycloak_openid_client_default_scopes, [for obj in coalesce(v.default_scopes, []) : obj]])) if v.default_scopes != null }
}


data "keycloak_realm" "this" {
  realm = var.keycloak_realm_name
}


resource "keycloak_openid_client_scope" "scope" {
  for_each = local.keycloak_openid_client_scope
  #
  realm_id = data.keycloak_realm.this.id
  #
  name        = each.value.name
  description = each.value.description
  #
  include_in_token_scope = each.value.include_in_token_scope
  #
  depends_on = [
    data.keycloak_realm.this
  ]
}

resource "keycloak_generic_protocol_mapper" "mapper" {
  for_each = local.keycloak_generic_protocol_mapper
  #
  realm_id        = data.keycloak_realm.this.id
  client_scope_id = keycloak_openid_client_scope.scope[each.value.client_scope_name].id
  #
  name     = each.value.name
  protocol = each.value.protocol
  #
  protocol_mapper = each.value.protocol_mapper
  config          = each.value.config
  #
  depends_on = [
    keycloak_openid_client_scope.scope
  ]
}


resource "keycloak_openid_client" "client" {
  for_each = local.keycloak_openid_client
  #
  realm_id = data.keycloak_realm.this.id
  #
  enabled = each.value.enabled
  #
  client_id = each.value.client_id
  name      = each.value.name
  #
  root_url            = each.value.root_url
  base_url            = each.value.base_url
  valid_redirect_uris = each.value.valid_redirect_uris
  web_origins         = each.value.web_origins
  admin_url           = each.value.admin_url
  #
  access_type                  = each.value.access_type
  standard_flow_enabled        = each.value.standard_flow_enabled
  direct_access_grants_enabled = each.value.direct_access_grants_enabled
  #
  depends_on = [
    data.keycloak_realm.this
  ]
}

resource "keycloak_openid_client_default_scopes" "default_scopes" {
  for_each = local.keycloak_openid_client_default_scopes
  #
  realm_id  = data.keycloak_realm.this.id
  client_id = keycloak_openid_client.client[each.key].id
  #
  default_scopes = each.value
  #
  depends_on = [
    keycloak_openid_client.client
  ]
}
