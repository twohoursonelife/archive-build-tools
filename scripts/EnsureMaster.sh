#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;

cd repos;

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do

    git -C "${REPO}" checkout master;
    
    git -C "${REPO}" pull origin master --tags;

done;