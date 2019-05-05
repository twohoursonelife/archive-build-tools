#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;



GITHUB_USER="${1}";

if [[ -z "${GITHUB_USER}" ]]; then
    GITHUB_BASE="https://github.com/chardbury";
else
    GITHUB_BASE="git@github.com:${GITHUB_USER}";
fi;

if [[ ! -d repos/crucible-code ]]; then
    git clone "${GITHUB_BASE}/crucible-code.git" repos/crucible-code;
fi;

if [[ ! -e repos/OneLife ]]; then
    ln -s crucible-code repos/OneLife;
fi;

if [[ ! -d repos/crucible-data ]]; then
    git clone "${GITHUB_BASE}/crucible-data.git" repos/crucible-data;
fi;

if [[ ! -e repos/OneLifeData7 ]]; then
    ln -s crucible-data repos/OneLifeData7;
fi;

if [[ ! -e repos/crucible-gems ]]; then
    git clone "${GITHUB_BASE}/crucible-gems.git" repos/crucible-gems;
fi;

if [[ ! -e repos/minorGems ]]; then
    ln -s crucible-gems repos/minorGems;
fi;