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

#Temp solution, as it blanks the file?
# Auto-self update
#if [ "$(cat .version)" != "$(curl -s "https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version")" ]; then
#    echo "You are running an outdated version of the main script."
#    echo "Updating..."
#    curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/c22dev/intersectionBridge/main/intersectiond.sh > intersectiond.sh
#    curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version > .version
#    chmod a+x intersectiond.sh
#    ./intersectiond.sh
#    exit
#fi

# Download/update required files
curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/sshBridge.sh > sshBridge.sh
chmod a+x sshBridge.sh

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

./sshBridge.sh $username $password $server
attempts=0
check_proxy() {
    # Don't ask me why libmol haha
    # Here, we check if proxying a request through the proxy works. If not, we kill the existing process, then launch a new one.
    if curl -I --socks5-hostname localhost:8080 https://libmol.org/ --max-time 10 >/dev/null 2>&1; then
        echo "SOCKS5:OK"
        attempts=0
    else
        echo "SOCKS5: No Response, relaunching..."
        killAnythingOnPort
        ((attempts++))
        if [ "$attempts" -ge "75" ]; then
            if networksetup -getairportnetwork en0 | grep -q "Current"; then
                echo "max attempt reached"
                osascript -e 'display alert "IntersectionBridge - Connection Error" message "It looks like you are encountering issues with your network. Please ensure you are connected to the internet and that your login has not expired/is valid.\nIf you were provided a 7 day SSH access, make sure to renew it.\nError Code: MAXATTEMPTREACHEDNW"'
            fi
            attempts=0
        fi
        ./sshBridge.sh "$username" "$password" "$server"
    fi
}

while true; do
    sleep 5
    check_proxy
done
