cd $HOME
mkdir Intersection
cd Intersection
curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/version > .version
curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/intersectiond.sh > intersectiond.sh
chmod a+x intersectiond.sh

cd "$HOME/Library/LaunchAgents/"
curl https://raw.githubusercontent.com/c22dev/intersectionBridge/main/ch.cclerc.intersection.plist > ch.cclerc.intersection.plist
# Taken from one of my previous code, idk how I wrote that
awk -v home="$HOME" '{gsub("/Users/REPLACEUSERHERE", home)} 1' "$HOME/Library/LaunchAgents/ch.cclerc.intersection.plist" > tmpfile && mv tmpfile "$HOME/Library/LaunchAgents/ch.cclerc.intersection.plist"
launchctl load ~/Library/LaunchAgents/ch.cclerc.intersection.plist

touch "$HOME/.intersectionHasBeenRan"

rm -- "$0"