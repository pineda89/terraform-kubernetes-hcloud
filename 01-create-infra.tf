provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "k8s_admin" {
  name       = "k8s_admin"
  public_key = file(var.ssh_public_key)
}

resource "hcloud_network" "kubenet" {
  name = "kubenet"
  ip_range = "10.88.0.0/16"
}

resource "hcloud_network_subnet" "kubenet" {
  network_id = hcloud_network.kubenet.id
  type = "server"
  network_zone = "eu-central"
  ip_range   = "10.88.0.0/16"
}

resource "hcloud_load_balancer" "kube_load_balancer" {
  name       = "kube-lb"
  load_balancer_type = "lb11"
  location   = var.location
}

resource "hcloud_load_balancer_service" "kube_load_balancer_service" {
  load_balancer_id = hcloud_load_balancer.kube_load_balancer.id
  protocol = "tcp"
  listen_port = 6443
  destination_port = 6443
}

resource "hcloud_firewall" "kube_firewall" {
  name       = "kube_firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "any"
    source_ips = var.ip_whitelist
  }
}