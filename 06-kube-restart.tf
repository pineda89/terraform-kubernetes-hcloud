resource "null_resource" "post_restart_masters" {
  depends_on = [null_resource.kube-cni]
  count       = var.master_count
  connection {
    host        = hcloud_server.master[count.index].ipv4_address
    type        = "ssh"
    port        = var.ssh_port
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = ["systemctl restart kubelet"]
  }
}

resource "null_resource" "post_restart_nodes" {
  depends_on = [null_resource.kube-cni]
  count       = var.node_count
  connection {
    host        = hcloud_server.node[count.index].ipv4_address
    type        = "ssh"
    port        = var.ssh_port
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = ["systemctl restart kubelet"]
  }
}

