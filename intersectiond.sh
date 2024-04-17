#!/bin/bash
# intersectiond
# Constantin Clerc - v0.1

# The redistribution of this code and any other in this repository isn't allowed if the author isn't credited.

# Initial Set-up (include variables)

getPhrase() {
    local prompt="$1"
    local default="$2"
    local input
    input=$(osascript -e "text returned of (display dialog \"$prompt\" default answer \"$default\")")
    echo "$input"
}

cd $HOME
cd Intersection

# Auto-self update
if [ "$(cat .version)" != "$(curl -s "https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version")" ]; then
    echo "You are running an outdated version of the main script."
    echo "Updating..."
    curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/intersectiond.sh > intersectiond.sh
    curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version > .version
    chmod a+x intersectiond.sh
    ./intersectiond.sh
    exit
fi

# Download/update required files
curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/sshBridge.sh > sshBridge.sh
chmod a+x sshBridge.sh

# Username managing
if [ -d ".storedUsernames" ] && [ "$(ls -A .storedUsernames)" ]; then
    username=$(basename .storedUsernames/*)
    password=security find-generic-password -w -s 'intersectionLogins' -a "$username"
    if [ -d ".storedServers" ] && [ "$(ls -A .storedServers)" ]; then
        server=$(basename .storedServers/*)
    else
        echo An error occured. Please delete .storedUsernames directory.
        exit
    fi
else
    username=$(getPhrase "Username" "")
    password=$(getPhrase "Password" "")
    server=$(getPhrase "Server" "")

    echo "Username: $username"
    echo "Password: $password"
    echo "Server: $server"

    choiceStore=$(osascript -e 'button returned of (display dialog "Do you want to keep this password in keychain?" buttons {"Yes", "No"} default button "Yes")')
    if [ "$choiceStore" = "Yes" ]; then
        security add-generic-password -s 'intersectionLogins'  -a "$username" -w "$password"
        rm -rf .storedUsernames
        mkdir .storedUsernames
        touch ".storedUsernames/$username"
        rm -rf .storedServers
        mkdir .storedServers
        touch ".storedServers/$server"
    fi
fi


killAnythingOnPort() {
    local pids=$(lsof -ti :8080)

    if [ -z "$pids" ]; then
        echo "No processes found running on port $port."
    else
        kill -9 $pids
    fi
}
killAnythingOnPort

./sshBridge.sh $username $password $server

check_proxy() {
    if curl -I --socks5-hostname localhost:8080 https://libmol.org/ --max-time 10 >/dev/null 2>&1; then
        echo "SOCKS5:OK"
    else
        echo "SOCKS5: No Response, relaunching..."
        killAnythingOnPort
        ./sshBridge.sh "$username" "$password" "$server"
    fi
}

while true; do
    sleep 5
    check_proxy
done