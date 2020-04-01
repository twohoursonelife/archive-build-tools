#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;



GITHUB_USER="${1}";
GITHUB_BASE="https://github.com/twohoursonelife";

if [[ ! -d repos/2HOL-code ]]; then
    git clone "${GITHUB_BASE}/OneLife.git" repos/2HOL-code;
fi;

if [[ ! -e repos/OneLife ]]; then
    ln -s 2HOL-code repos/OneLife;
fi;

if [[ ! -d repos/2HOL-data ]]; then
    git clone "${GITHUB_BASE}/OneLifeData7.git" repos/2HOL-data;
fi;

if [[ ! -e repos/OneLifeData7 ]]; then
    ln -s 2HOL-data repos/OneLifeData7;
fi;

if [[ ! -e repos/2HOL-gems ]]; then
    git clone "${GITHUB_BASE}/minorGems.git" repos/2HOL-gems;
fi;

if [[ ! -e repos/minorGems ]]; then
    ln -s 2HOL-gems repos/minorGems;
fi;