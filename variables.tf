variable "profile" {
  type    = string
  default = "default"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "websrvs-count" {
  type    = number
  default = 2
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}