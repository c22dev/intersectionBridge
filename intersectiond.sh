#!/bin/bash
# intersectiond
# Constantin Clerc - v0.2

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

function check_wifi_connection {
    local wifi_status=$(networksetup -getairportnetwork en0)
    if [[ "$wifi_status" == *"You are not associated with an AirPort network"* ]]; then
        return 1
    else
        return 0
    fi
}
while true; do
    if check_wifi_connection; then
        sleep 1
        break
    fi
    sleep 2
done

cd Intersection

# Username managing
# Here, we ask user for it's creditentials on first launch
# We also propose them to save the pass in Keychain; we save the username and the server in folders so it's easier to check
# This might not work on restricted Macs.

if [ -d ".storedUsernames" ] && [ "$(ls -A .storedUsernames)" ]; then
    username=$(basename .storedUsernames/*)
    password=$(security find-generic-password -w -s "intersectionLogins" -a "$username")
    if [ -d ".storedServers" ] && [ "$(ls -A .storedServers)" ]; then
        server=$(basename .storedServers/*)
    else
        echo An error occured. Please delete .storedUsernames directory.
        osascript -e 'display alert "IntersectionBridge - Error" message "An error occured while retrieving server name. Please delete .storedUsernames directory.\nError Code: NOFILEINSRVDIR"'
        exit
    fi
    if [ -d ".storedPorts" ] && [ "$(ls -A .storedPorts)" ]; then
        port=$(basename .storedPorts/*)
    else
        echo An error occured. Please delete .storedUsernames directory.
        osascript -e 'display alert "IntersectionBridge - Error" message "An error occured while retrieving port. Please delete .storedUsernames directory.\nError Code: NOFILEINPRTDIR"'
        exit
    fi
fi

if [ -f "unblock.sh" ]; then
    cd $HOME
    oldpassword=$(grep -oP 'send "\K[^\\]+' "unblock.sh")
    olduser_server=$(grep -oP 'ssh -D \d+ -C -N \K[^@]+' "unblock.sh")
    oldserver=$(grep -oP '@\K[^ ]+' "unblock.sh")
    olduser="${user_server%%-*}"
    echo "Detected a previous install."
    echo "Password: $oldpassword"
    echo "User: $olduser"
    echo "Server: $oldserver"
    choiceOld=$(osascript -e 'button returned of (display dialog "Detected an old configuration. Do you want to use the following creditentials?" buttons {"Yes", "No"} default button "Yes")')
    if [ "$choiceOld" = "Yes" ]; then
        username=olduser
        password=oldpassword
        server=oldserver
        port=22
    fi
    cd Intersection
else
    username=$(getPhrase "Username" "")
    password=$(getPhrase "Password" "")
    server=$(getPhrase "Server" "")
    port=$(getPhrase "Port" "")
    echo "Username: $username"
    echo "Password: $password"
    echo "Server: $server"
    echo "Server: $port"

    choiceStore=$(osascript -e 'button returned of (display dialog "Do you want to keep this password in keychain?" buttons {"Yes", "No"} default button "Yes")')
    if [ "$choiceStore" = "Yes" ]; then
        security delete-generic-password -s 'intersectionLogins' -a "$username"
        security add-generic-password -s 'intersectionLogins' -a "$username" -w "$password"
        rm -rf .storedUsernames
        mkdir .storedUsernames
        touch ".storedUsernames/$username"
        rm -rf .storedServers
        mkdir .storedServers
        touch ".storedServers/$server"
        mkdir .storedPorts
        touch ".storedPorts/$port"
    fi
fi

# If a process is "taking our reservation" on port 8080, we kill it
killAnythingOnPort() {
    local pids=$(lsof -ti :8080)

    if [ -z "$pids" ]; then
        echo "No processes found running on port $port."
    else
        kill -9 $pids
    fi
}
killAnythingOnPort

./sshBridge.sh $username $password $server $port
attempts=0
untilUpdTime=0
networksetup -setsocksfirewallproxy "Wi-Fi" 127.0.0.1 8080
check_proxy() {
    # Don't ask me why libmol haha
    # Here, we check if proxying a request through the proxy works. If not, we kill the existing process, then launch a new one.
    if curl -I --socks5-hostname localhost:8080 https://libmol.org/ --max-time 10 >/dev/null 2>&1; then
        echo "SOCKS5:OK"
    else
        echo "SOCKS5: No Response, relaunching..."
        killAnythingOnPort
        ((attempts++))
        if [ "$attempts" -ge "10" ]; then
            if networksetup -getairportnetwork en0 | grep -q "Current"; then
                echo "max attempt reached"
                osascript -e 'display alert "IntersectionBridge - Connection Error" message "It looks like you are encountering issues with your network. Please ensure you are connected to the internet and that your login has not expired/is valid.\nIf you were provided a 7 day SSH access, make sure to renew it.\nError Code: MAXATTEMPTREACHEDNW"'
            fi
            attempts=0
        fi
        ./sshBridge.sh "$username" "$password" "$server" "$port"
    fi
    ((untilUpdTime++))
    if [ "$untilUpdTime" -ge "360" ]; then
        ./updater.sh
        untilUpdTime=0
    fi
}

while true; do
    sleep 5
    check_proxy
done
