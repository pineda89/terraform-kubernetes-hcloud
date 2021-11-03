resource "hcloud_server" "master" {
  depends_on = [hcloud_load_balancer.kube_load_balancer]
  count       = var.master_count
  name        = "${var.cluster_name}-master-${count.index + 1}"
  location   = var.location
  server_type = var.master_type
  image       = var.master_image
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]

  connection {
    host        = self.ipv4_address
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["SSH_PORT=${var.ssh_port} bash /root/bootstrap.sh"]
  }
}

resource "hcloud_server" "node" {
  count       = var.node_count
  name        = "${var.cluster_name}-node-${count.index + 1}"
  server_type = var.node_type
  image       = var.node_image
  location    = var.location
  labels      = ["k8smaster"]
  depends_on  = [hcloud_server.master]
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]

  connection {
    host        = self.ipv4_address
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["SSH_PORT=${var.ssh_port} bash /root/bootstrap.sh"]
  }
}

resource "hcloud_server_network" "master_network" {
  count       = var.master_count
  depends_on  = [hcloud_server.master]
  server_id = hcloud_server.master[count.index].id
  network_id = hcloud_network.kubenet.id
}

resource "hcloud_load_balancer_target" "load_balancer_target" {
  count       = var.master_count
  depends_on  = [hcloud_server.master]
  type = "label_selector"
  label_selector = "k8smaster"
  load_balancer_id = hcloud_load_balancer.kube_load_balancer.id
}

resource "hcloud_server_network" "node_network" {
  count       = var.node_count
  depends_on  = [hcloud_server.node]
  server_id = hcloud_server.node[count.index].id
  network_id = hcloud_network.kubenet.id
}
