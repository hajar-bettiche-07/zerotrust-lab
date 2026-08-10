variable "my_ip" {
  description = "41.249.82.253/32"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Chemin vers ta clé SSH publique"
  type        = string
  default     = "C:/Users/Hajar Bettiche/.ssh/zerotrust-lab.pub"
}