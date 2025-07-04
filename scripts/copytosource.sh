#!/bin/bash

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
        (sleep 5; wl-copy "") &
    else
        read -p "No entry found. Create new? [Y/n]: " CREATE
        CREATE=${CREATE,,} # to lowercase

        if [[ "$CREATE" == "n" ]]; then
            echo "Aborted."
            exit 1
        fi

        PASSWORD=$(bw generate -l 20 -u -l -s -n --session "$BW_SESSION")

        ENCODED=$(echo "{\"name\":\"$MACHINE_NAME\",\"type\":1,\"login\":{\"username\":\"user\",\"password\":\"$PASSWORD\"}}" | bw encode)

        bw create item "$ENCODED" --session "$BW_SESSION" >/dev/null

        echo "$PASSWORD" | wl-copy
        echo "Password created and copied to clipboard."
        (sleep 5; wl-copy "") &
    fi
}

SESSION_FILE="$HOME/vaultwarden/vw-data/.bw_session"

if [[ ! -s "$SESSION_FILE" ]]; then
    # File is empty or does not exist
    BW_SESSION='""'
else
    BW_SESSION=$(cat "$SESSION_FILE")
fi


RAW_OUTPUT=$(bw list items --session "$BW_SESSION" --nointeraction  2>&1)

# Determine if the output contains the master password prompt
if echo "$RAW_OUTPUT" | grep -q "Vault is locked" || echo "$RAW_OUTPUT" | grep -q "You are not logged in."; then
    AUTHENTICATION_STATUS="unauthorized"
else
    AUTHENTICATION_STATUS="authorized"
fi



echo Status: "$AUTHENTICATION_STATUS"

if [[ "$AUTHENTICATION_STATUS" == "unauthorized" ]]; then
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

            #save token
            echo 'saving token to: $SESSION_FILE'
            echo "$GET_TOKEN_AGAIN" > "$SESSION_FILE"

            BW_SESSION=$GET_TOKEN_AGAIN
            get_credentials
            break
        else
            # Parse session line

            SESSION_LINE=$(echo "$LOGIN_OUTPUT" | grep 'export BW_SESSION=')
            SESSION_VALUE="${SESSION_LINE#*=}"
            SESSION_VALUE="${SESSION_VALUE%\"}"
            SESSION_VALUE="${SESSION_VALUE#\"}"

            #update token
            echo 'updating token: $SESSION_FILE'
            echo "$GET_TOKEN_AGAIN" > "$SESSION_FILE"

            BW_SESSION=$SESSION_VALUE
            get_credentials
            break
        fi
    done
else
    get_credentials
fi
