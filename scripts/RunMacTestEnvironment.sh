#!/bin/bash

set -e;

cd "$(dirname ${0})"/..;

source ./scripts/CommonVariables.sh;

./scripts/BuildMacTestEnvironment.sh;

# Terminate any previous server process and window.
pgrep -f OneLifeServer && pkill -f OneLifeServer;

# Switch to the server directory.
cd build/server;

# Execute the server in a split terminal window.
osascript <<EOF
tell application "iTerm2"
    tell current session of current window
        split vertically with default profile command "sh -c 'cd $(pwd); ./OneLifeServer; read'"
    end tell
end tell
EOF

# Switch to the client directory.
cd ../client;

# Run the client ignorning any errors.
./OneLife || echo "Exited with status code ${?}";

# Terminate the server process.
pkill -TSTP OneLifeServer;