# Vaultwarden Server Setup

This Vaultwarden server is exclusively for homelab VM credentials management and is bound to `localhost` only.

## Hardware Requirements

1. Fedora Daily Driver sitting in trusted LAN with at least 1GB of RAM and 2 CPU cores.
2. Yubikey

## Install Yubikey Manager on Fedora and Set a Static Password for Long Press

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
#
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

5. Create a helper scripts to be used in VMs, leveraging `wl-clipboard`.
```bash
sudo dnf install wl-clipboard
```

```bash
#!/bin/bash

# Check if already logged in
BW_STATUS=$(bw status 2>/dev/null)

AUTHENTICATION_STATUS=$(bw status | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"')

function get_credentials {
    read -s -p "Challenge phrase: " CHALLENGE_PHRASE
    echo ""

    # Generate response using YubiKey challenge-response
    RESPONSE=$(ykman otp calculate 2 $(echo -n "$CHALLENGE_PHRASE" | xxd -p))

    # Split response: first 5 chars for email, rest for password
    EMAIL_PREFIX=${RESPONSE:0:5}
    MASTER_PASSWORD=${RESPONSE:5}
    EMAIL="${EMAIL_PREFIX}@mail.xyz"
}

echo status: "$AUTHENTICATION_STATUS"

if [[ "$AUTHENTICATION_STATUS" == "unauthenticated" || "$AUTHENTICATION_STATUS" == "locked" ]]; then
    while true; do
        # Get credentials using challenge
        get_credentials

        # Try logging in and capture all output
        LOGIN_OUTPUT=$(bw login "$EMAIL" "$MASTER_PASSWORD" --method 1 2>&1)

        # Check if login failed due to bad password
        if echo "$LOGIN_OUTPUT" | grep -q "incorrect"; then
            echo "Login failed: incorrect username or password."
            echo "Please try again."
            echo ""
        elif echo "$LOGIN_OUTPUT" | grep -q "already logged in"; then
            GET_TOKEN_AGAIN=$(bw unlock "$MASTER_PASSWORD" --raw)
	   echo "export BW_SESSION=$GET_TOKEN_AGAIN"
            exit 0
        else
            # Successful login
            break
        fi
    done


    # Parse session line

    SESSION_LINE=$(echo "$LOGIN_OUTPUT" | grep 'export BW_SESSION=')
    SESSION_VALUE="${SESSION_LINE#*=}"
    SESSION_VALUE="${SESSION_VALUE%\"}"
    SESSION_VALUE="${SESSION_VALUE#\"}"

    echo "for extended session, run: "
    echo "export BW_SESSION=$SESSION_VALUE"
else
    echo "Already authenticated with Bitwarden CLI."
fi

```


## Create a password rotation script for VMs




## References

https://docs.docker.com/engine/install/fedora/

https://github.com/rsmsctr/vaultwardenGuide

https://Vaultwarden.com/help/install-on-premise-linux/

https://Vaultwarden.com/blog/how-to-install-and-use-the-Vaultwarden-command-line-tool/
