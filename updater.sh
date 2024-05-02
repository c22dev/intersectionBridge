#!/bin/bash
# Updater
# Constantin Clerc - v0.1
# The updater should work no matter the version and won't self update

if curl -I --socks5-hostname localhost:8080 github.com --max-time 10 >/dev/null 2>&1; then
    echo "SOCKS5 proxy : OK - The Mac is connected to the internet"
    echo "Ready to update"
    sleep 2
    cd $HOME/Intersection
    if [ "$(cat .version)" != "$(curl -s "https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version")" ]; then
        echo "You are running an outdated version of the main script."
        echo "Updating..."
        choiceUpd=$(osascript -e 'button returned of (display dialog "An update is available. Do you want to update ?" buttons {"Yes", "No"} default button "Yes")')
        if [ "$choiceUpd" = "Yes" ]; then
            curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/intersectiond.sh > intersectiond.sh
            curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version > .version
            chmod a+x intersectiond.sh
            doTheSizeChecks() {
                sizeOfMain = $(wc -c intersectiond.sh | awk '{print $1}')
                sizeOfVersion = $(wc -c .version | awk '{print $1}')
                if [ "$sizeOfMain" -ge "1000" ]; then
                    echo Size seems correct
                else
                    curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/intersectiond.sh > intersectiond.sh
                    chmod a+x intersectiond.sh
                    doTheSizeChecks()
                fi
                if [ "$sizeOfVersion" -ge "1" ]; then
                    print("Size seems correct")
                else
                    curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version > .version
                    doTheSizeChecks()
                fi
            }
            doTheSizeChecks()
            osascript -e 'tell app "loginwindow" to «event aevtrrst»'
        fi
    fi
fi
