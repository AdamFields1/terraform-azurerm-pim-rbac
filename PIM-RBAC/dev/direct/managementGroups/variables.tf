variable "application" {
  type    = string
  default = "PIM MG"
}

variable "role_definition_name" {
  type = string
}

variable "location" {
  default = "westus"
  type    = string
}


variable "mg_names" {
  type = string
}

//variable "AD_Group_Display_Name" {
//type = string
//}

variable "deployment_name" {
  type    = string
  default = null
}