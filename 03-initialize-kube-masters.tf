resource "null_resource" "init_masters" {
  count = var.master_count
  connection {
    host = hcloud_server.master[count.index].ipv4_address
    type = "ssh"
    port = var.ssh_port
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source = "files/10-kubeadm.conf"
    destination = "/root/10-kubeadm.conf"
  }

  provisioner "file" {
    source = "scripts/kube-bootstrap.sh"
    destination = "/root/kube-bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "DOCKER_VERSION=${var.docker_version} KUBERNETES_VERSION=${var.kubernetes_version} MASTER_INDEX=${count.index} bash /root/kube-bootstrap.sh"]
  }

  provisioner "file" {
    source = "scripts/kube-master.sh"
    destination = "/root/kube-master.sh"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/secrets && touch ${path.module}/secrets/kubeadm_control_plane_join"
  }

  provisioner "file" {
    source = "${path.module}/secrets/kubeadm_control_plane_join"
    destination = "/tmp/kubeadm_control_plane_join"
  }

  provisioner "remote-exec" {
    inline = [
      "FEATURE_GATES=${var.feature_gates} LB_IP=${hcloud_load_balancer.kube_load_balancer.ipv4} MASTER_INDEX=${count.index} bash /root/kube-master.sh"]
  }

  provisioner "local-exec" {
    command = "bash scripts/copy-kubeadm-token.sh"

    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key
      SSH_USERNAME = "root"
      SSH_PORT = var.ssh_port
      SSH_HOST = hcloud_server.master[0].ipv4_address
      TARGET = "${path.module}/secrets/"
      MASTER_INDEX = count.index
    }
  }

}