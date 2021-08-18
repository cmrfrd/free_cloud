
# resource "ibm_resource_instance" "cos_instance" {
#   name              = "cos-instance"
#   service           = "cloud-object-storage"
#   plan              = "lite"
#   location          = "global"
#   parameters        = { HMAC = true }
# }


##################

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "~> 1.12.0"
    }
  }
}

provider "ibm" {}

locals {
  role        = "Writer"
  name_prefix = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name        = var.name != "" ? var.name : "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${var.label}"
  bucket_name = var.bucket_name
  key_name    = "${local.name}-key"
  service     = "cloud-object-storage"
}

// COS Cloud Object Storage
resource ibm_resource_instance cos_instance {

  name              = local.name
  service           = local.service
  plan              = var.plan
  location          = var.resource_location

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

resource ibm_cos_bucket cos_instance {
  bucket_name          = local.bucket_name
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.bucket_location
  storage_class        = "smart"
}

data ibm_resource_instance cos_instance {
  depends_on        = [ibm_resource_instance.cos_instance]

  name              = local.name
  service           = local.service
  location          = var.resource_location
}

resource "ibm_resource_key" "cos_credentials" {

  name                 = local.key_name
  resource_instance_id = ibm_resource_instance.cos_instance.id
  role                 = local.role
  parameters           = { "HMAC" = true }

  //User can increase timeouts
  timeouts {
    create = "15m"
    delete = "15m"
  }
}
