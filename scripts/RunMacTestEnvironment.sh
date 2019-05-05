#!/bin/bash

set -e;

cd "$(dirname ${0})"/..;

source ./scripts/CommonVariables.sh;

./scripts/BuildMacTestEnvironment.sh;

pgrep -f OneLifeServer && pkill -f OneLifeServer;

cd build/server;

osascript <<EOF
tell application "iTerm2"
    tell current session of current window
        split vertically with default profile command "sh -c 'cd $(pwd); ./OneLifeServer; read'"
    end tell
end tell
EOF

cd ../client;

./OneLife || echo "Exited with status code ${?}";

pkill -TSTP OneLifeServer;