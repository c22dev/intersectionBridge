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

username=$(getPhrase "Username" "")
password=$(getPhrase "Password" "")
server=$(getPhrase "Server" "")

echo "Username: $username"
echo "Password: $password"
echo "Server: $server"

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