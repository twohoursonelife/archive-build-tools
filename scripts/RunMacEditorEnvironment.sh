#!/bin/bash

set -e;

cd "$(dirname ${0})"/..;

source ./scripts/CommonVariables.sh;

./scripts/BuildMacTestEnvironment.sh;

cd build/editor;

[[ ! -e ~/Library/Preferences/Crucible_prefs.txt ]] || cp ~/Library/Preferences/Crucible_prefs.txt ~/Library/Preferences/Crucible_prefs.bak;

pwd > ~/Library/Preferences/Crucible_prefs.txt;

./EditCrucible || echo "Exited with status code ${?}";

mv ~/Library/Preferences/Crucible_prefs.bak ~/Library/Preferences/Crucible_prefs.txt;