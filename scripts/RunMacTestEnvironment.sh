#!/bin/bash

set -e;

cd "$(dirname ${0})"/..;

source ./scripts/CommonVariables.sh;

./scripts/BuildMacTestEnvironment.sh;

pgrep -f CrucibleServer && pkill -f CrucibleServer;

cd build/server;

osascript <<EOF
tell application "iTerm2"
    tell current session of current window
        split vertically with default profile command "sh -c 'cd $(pwd); ./CrucibleServer; read'"
    end tell
end tell
EOF

cd ../client;

[[ ! -e ~/Library/Preferences/Crucible_prefs.txt ]] || cp ~/Library/Preferences/Crucible_prefs.txt ~/Library/Preferences/Crucible_prefs.bak;

pwd > ~/Library/Preferences/Crucible_prefs.txt;

./Crucible || echo "Exited with status code ${?}";

mv ~/Library/Preferences/Crucible_prefs.bak ~/Library/Preferences/Crucible_prefs.txt;

pkill -TSTP CrucibleServer;