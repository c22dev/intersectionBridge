#!/bin/bash
# installer
# Constantin Clerc - v0.1


self=$(realpath "${BASH_SOURCE[0]}")
echo "intersectionBridge"
echo "installer v0.1"
echo "made by c22dev/Constantin Clerc"
echo "Warning : This was tested on macOS Sonoma and macOS Ventura. Earlier versions might not work."
echo "By using this software and other scripts in the repo, you agree to credit the original developer if you republish or make an edit."
echo "This software and other scripts in the reposhouldn't be sold."
cd $HOME
mkdir Intersection
cd Intersection
curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version > .version
curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/c22dev/intersectionBridge/main/intersectiond.sh > intersectiond.sh
chmod a+x intersectiond.sh

curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/sshBridge.sh > sshBridge.sh
chmod a+x sshBridge.sh

curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/updater.sh > updater.sh
chmod a+x updater.sh
rm -rf ~/Library/LaunchAgents/ch.cclerc.intersection.plist
mkdir "$HOME/Library/LaunchAgents/"
cd "$HOME/Library/LaunchAgents/"
curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/ch.cclerc.intersection.plist > ch.cclerc.intersection.plist
# Taken from one of my previous code, idk how I wrote that
awk -v home="$HOME" '{gsub("/Users/REPLACEUSERHERE", home)} 1' "$HOME/Library/LaunchAgents/ch.cclerc.intersection.plist" > tmpfile && mv tmpfile "$HOME/Library/LaunchAgents/ch.cclerc.intersection.plist"
launchctl load ~/Library/LaunchAgents/ch.cclerc.intersection.plist

touch "$HOME/.intersectionHasBeenRan"

echo "You might want to use a shortcut to quickly launch an instance of MS Edge with the proxy settings using this link:"
echo "https://www.icloud.com/shortcuts/56135d37e9de493091315d9757e03570"
echo "If you prefer using your settings for this proxy, it's opened on 127.0.0.1 port 8080 by default."
echo "If the installer file wasn't deleted, feel free to do it."
rm -f "$self"
