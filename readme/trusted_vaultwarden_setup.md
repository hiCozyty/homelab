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
AUTHENTICATION_STATUS=$(bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"')

function get_challenge_response {
    read -s -p "Challenge phrase: " CHALLENGE_PHRASE
    echo ""

    # Generate response using YubiKey challenge-response
    RESPONSE=$(ykman otp calculate 2 $(echo -n "$CHALLENGE_PHRASE" | xxd -p))

    # Split response: first 5 chars for email, rest for password
    EMAIL_PREFIX=${RESPONSE:0:5}
    MASTER_PASSWORD=${RESPONSE:5}
    EMAIL="${EMAIL_PREFIX}@mail.xyz"
}
function get_credentials {
    #ask for machine name.
    read -p "Machine Name: " MACHINE_NAME
    #get pw
    ITEM=$(bw get password "$MACHINE_NAME" --session "$BW_SESSION" )

    if [[ -n "$ITEM" ]]; then
        echo "$ITEM" | wl-copy
        echo "Password copied to clipboard."
        sleep 5; wl-copy ""&
    else
        read -p "No entry found. Create new? [Y/n]: " CREATE
        CREATE=${CREATE,,} # to lowercase

        if [[ "$CREATE" == "n" ]]; then
            echo "Aborted."
            exit 1
        fi

        PASSWORD=$(bw generate --length 20 --uppercase --lowercase --numbers --special --session "$BW_SESSION")
        bw create item login "{\"name\":\"$MACHINE_NAME\",\"login\":{\"username\":\"user\",\"password\":\"$PASSWORD\"}}" --session "$BW_SESSION" >/dev/null
        echo "$PASSWORD" | wl-copy
        echo "Password created and copied to clipboard."
        sleep 5; wl-copy ""&
    fi
}

echo Status: "$AUTHENTICATION_STATUS"

if [[ "$AUTHENTICATION_STATUS" == "unauthenticated" || "$AUTHENTICATION_STATUS" == "locked" ]]; then
    while true; do
        # Get credentials using challenge
        get_challenge_response

        # Try logging in and capture all output
        LOGIN_OUTPUT=$(bw login "$EMAIL" "$MASTER_PASSWORD" --method 1 2>&1)

        # Check if login failed due to bad password
        if echo "$LOGIN_OUTPUT" | grep -q "incorrect"; then
            echo "Login failed: incorrect username or password."
            echo "Please try again."
            echo ""
        elif echo "$LOGIN_OUTPUT" | grep -q "already logged in"; then
            GET_TOKEN_AGAIN=$(bw unlock "$MASTER_PASSWORD" --raw)
            echo "for extended session, run: "
            echo "export BW_SESSION=$GET_TOKEN_AGAIN"
            BW_SESSION=$GET_TOKEN_AGAIN
            break
        else
            # Parse session line

            SESSION_LINE=$(echo "$LOGIN_OUTPUT" | grep 'export BW_SESSION=')
            SESSION_VALUE="${SESSION_LINE#*=}"
            SESSION_VALUE="${SESSION_VALUE%\"}"
            SESSION_VALUE="${SESSION_VALUE#\"}"

            echo "for extended session, run: "
            echo "export BW_SESSION=$SESSION_VALUE"
            BW_SESSION=$SESSION_VALUE
            break
        fi
    done
else
    get_credentials
fi
```


## Create a password rotation script for VMs




## References

https://docs.docker.com/engine/install/fedora/

https://github.com/rsmsctr/vaultwardenGuide

https://Vaultwarden.com/help/install-on-premise-linux/

https://Vaultwarden.com/blog/how-to-install-and-use-the-Vaultwarden-command-line-tool/
