#!/bin/bash
set -eu
SSH_PORT=${SSH_PORT:-}

echo "Port $SSH_PORT" > /etc/ssh/sshd_config.d/port.conf
systemctl restart sshd

apt-get -qq update
apt-get -qq install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common