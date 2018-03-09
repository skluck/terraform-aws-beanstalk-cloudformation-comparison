variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "zone_name" {
  description = "Hosted zone name"
}

variable "name" {
  default = "dns"
}

variable "records" {
  type = "list"
}


# lookups

variable "available_tiers" {
  default = {
    web    = "WebServer"
    worker = "Worker"
  }
}
