# Centralized Credentials Management

Self hosted Vaultwarden server is used exclusively for homelab VM credentials management and is bound to `localhost` only.

# Demonstrations

## Getting credentials for RHEL host in an ssh session

...

## Getting credentials for VM10001 (kali) in an ssh session

...

## Getting credentials for VM20001 (windows) in an ssh session

...


## Hardware and Software Requirements

1. Fedora Daily Driver sitting in trusted LAN with at least 1GB of RAM and 2 CPU cores.
2. Yubikey (HMAC-1 challenge response)
3. Tiling window manager (hyprland)


## Install Yubikey Manager on Fedora
1. Install yubikey manager.

```bash
sudo dnf install yubikey-manager
```

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

sudo usermod -aG docker $USER

sudo systemctl enable --now docker

#test docker if it runs without sudo
docker run hello-world

#try this if it doesnt work
newgrp docker
```

# Vaultwarden setup

1. Setup directory and `docker-compose.yml`.
```bash
mkdir -p ~/vaultwarden/vw-data
cd ~/vaultwarden

nano docker-compose.yml
```

3. Create `docker-compose.yml`.
```bash
version: '3'

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    ports:
      - 127.0.0.1:8080:80  # Bind only to localhost
    volumes:
      - ./vw-data:/data
```

4. Run docker.

```bash
docker compose up -d

#for shutdown
docker compose down
```

5. Access the web interface.

`http://localhost:8080`

6. Create a new account and set masterpassword to the yubikey challenge response.
```bash
ykpersonalize -2 -ochal-resp -ochal-hmac -o-chal-btn-trig -y #to disable touch

ykman otp calculate 2 $(echo -n "test123!@#" | xxd -p) #should output a deterministic value

# set a part of this output as the email and the rest as the master password
# for example, response output is 123456..... set email as 1234@mail.com and the rest as the password
# see script for example usage
```

## Install Bitwarden cli

1. Download the zipped file from the [Bitwarden download page](https://bitwarden.com/download/?app=cli&platform=linux).

2. Unzip.
```bash
unzip bw-linux-2025.6.1.zip
```

3. Make `bw` executable if needed and move to a directory in your path.
```bash
chmod +x bw
mv bw ~/.local/bin
which bw #confirm
```

4. Change Server to localhost and login.
```bash
bw config server http://localhost:8080
bw login
```

5. Install `wl-clipboard`.
```bash
sudo dnf install wl-clipboard
```

6. Update hyprland user scripts to include the kitty wrapper script running the copytosource or copytodestination script
```bash
#e.g. bind = $mainMod, T, exec, ~/Projects/homelab/scripts/kittyScriptWrapper.sh ~/Projects/homelab/scripts/copytosource.sh
```

## Create a password rotation script for VMs




## References

https://docs.docker.com/engine/install/fedora/

https://github.com/rsmsctr/vaultwardenGuide

https://bitwarden.com/help/install-on-premise-linux/

https://bitwarden.com/blog/how-to-install-and-use-the-bitwarden-command-line-tool/
