variable "hcloud_token" {
}

variable "location" {
  default = "hel1"
}

variable "cluster_name" {
}

variable "master_count" {
}

variable "master_image" {
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-20.04"
}

variable "master_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cpx21"
}

variable "node_count" {
}

variable "node_image" {
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-20.04"
}

variable "node_type" {
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cpx21"
}

variable "ssh_private_key" {
  description = "Private Key to access the machines"
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_port" {
  description = "SSH default port"
  default     = "666"
}

variable "ssh_public_key" {
  description = "Public Key to authorized the access for the machines"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "docker_version" {
  default = "20.10"
}

variable "kubernetes_version" {
  default = "1.20.0"
}

variable "feature_gates" {
  description = "Add Feature Gates e.g. 'DynamicKubeletConfig=true'"
  default     = ""
}

variable "ip_whitelist" {
  default = ["0.0.0.0"]
}