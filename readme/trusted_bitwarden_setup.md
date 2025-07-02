# Bitwarden Server Setup

This Bitwarden server is exclusively for homelab VM credentials management.

## Install Docker on Fedora

1. Uninstall old versions.
```bash
sudo dnf remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine
```

2. Install the latest version.
```bash
sudo dnf -y install dnf-plugins-core

sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

3. Start Docker Service.
```bash
sudo systemctl enable --now docker
```

## References
https://docs.docker.com/engine/install/fedora/
