
# keycloak_realm
variable "keycloak_realm_name" {
  type = string
  #
  default = ""
}

# keycloak_openid_client_scope
variable "keycloak_openid_client_scope" {
  type = map(object({
    name        = optional(string)
    description = optional(string)
    #
    include_in_token_scope = optional(bool)
  }))
  #
  default = {}
}

# keycloak_generic_protocol_mapper
variable "keycloak_generic_protocol_mapper" {
  type = map(object({
    client_scope_name = optional(string)
    #
    name     = optional(string)
    protocol = optional(string)
    #
    protocol_mapper = string
    config          = map(any)
  }))
  #
  default = {}
}

# keycloak_openid_client
variable "keycloak_openid_client" {
  type = map(object({
    enabled = optional(bool)
    #
    client_id = optional(string)
    name      = optional(string)
    #
    root_url            = string
    base_url            = optional(string)
    valid_redirect_uris = list(string)
    web_origins         = optional(list(string))
    admin_url           = optional(string)
    #
    access_type                  = optional(string)
    standard_flow_enabled        = optional(bool)
    direct_access_grants_enabled = optional(bool)
    #
    default_scopes = optional(list(string))
  }))
  #
  default = {}
}

# keycloak_openid_client_default_scopes
variable "keycloak_openid_client_default_scopes" {
  type = list(string)
  #
  default = [
    "acr",
    "email",
    "profile",
    "roles",
    "web-origins"
  ]
}
