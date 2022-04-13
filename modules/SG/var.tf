variable "sg_ingress_rules" {
  description = "Ingress security group rules"
  type        = map
}
variable "availability-zone1" {
  default = "us-east-2a"
}

variable "availability-zone2" {
  default = "us-east-2b"
}
variable "a_vpc_id" {
  description = "new vpc"
  }


