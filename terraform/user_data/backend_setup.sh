#!/bin/bash
# 1. Update system packages
dnf update -y

# 2. Install Docker using native DNF (replaces amazon-linux-extras)
dnf install docker -y

# 3. Start and enable Docker daemon
systemctl start docker
systemctl enable docker

# 4. Add the deployment user to the docker group
usermod -aG docker ec2-user

# 5. Install the latest stable Docker Compose V2 plugin cleanly
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.26.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# 6. Create the system symlink cleanly
ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose