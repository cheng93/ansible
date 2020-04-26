locals {
    cdn_name = "CDN-${var.resource_group_name}"
    cdn_location = "global"

    cdn_blog_name = "CDN-Blog-${var.resource_group_name}"
}

resource "azurerm_cdn_profile" "cdn_profile" {
    name                = local.cdn_name
    resource_group_name = var.resource_group_name
    location            = local.cdn_location
    sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdn_blog" {
    name                          = local.cdn_blog_name
    resource_group_name           = var.resource_group_name
    location                      = local.cdn_location
    profile_name                  = azurerm_cdn_profile.cdn_profile.name
    querystring_caching_behaviour = "UseQueryString"

    origin_host_header            = var.storage_blog_host_name
    origin {
        name      = "blog"
        host_name = var.storage_blog_host_name
    }
}