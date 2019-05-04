#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

GITHUB_USER="${1}";

if [[ -z "${GITHUB_USER}" ]]; then
    GITHUB_BASE="https://github.com/chardbury";
else
    GITHUB_BASE="git@github.com:${GITHUB_USER}";
fi;

git clone "${GITHUB_BASE}/crucible-code.git" repos/crucible-code;
ln -s crucible-code repos/OneLife;

git clone "${GITHUB_BASE}/crucible-data.git" repos/crucible-data;
ln -s crucible-data repos/OneLifeData7;

git clone "${GITHUB_BASE}/crucible-gems.git" repos/crucible-gems;
ln -s crucible-gems repos/minorGems;