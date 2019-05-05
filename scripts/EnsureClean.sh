#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;

cd repos;

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    
    if [[ -n "$(git -C "${REPO}" status --porcelain)" ]]; then
        echo "${REPO} contains modified or untracked files";
        exit 1;
    fi;

done;

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    
    git -C "${REPO}" clean -f -x -d;

done;