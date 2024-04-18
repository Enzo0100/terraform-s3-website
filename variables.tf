# Define variables for reusability and easy configuration
variable "bucket_name" {
  default = ""
}

variable "website_index_document" {
  default = "index.html"
}

variable "website_error_document" {
  default = "error.html"
}