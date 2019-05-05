#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;

./scripts/EnsureClean.sh;

./scripts/EnsureMaster.sh;

cd repos;



# Determine the current and previous versions.

PREVIOUS_VERSION="$(git -C "${REPO_CODE}" for-each-ref --sort=-creatordate \
    --format="%(refname:short)" --count=1 "refs/tags/${TAG_BASE}*" | \
    sed "s/^${TAG_BASE}//")";

CURRENT_VERSION=$((${PREVIOUS_VERSION} + 1));

# Bump the code version.

sed -i "0,/versionNumber/{s/[0-9]\+/${CURRENT_VERSION}/}" "${REPO_CODE}/gameSource/game.cpp";

git -C "${REPO_CODE}" add gameSource/game.cpp;

git -C "${REPO_CODE}" commit -m "Bump code version to ${CURRENT_VERSION}";

# Bump the data version.

echo "${CURRENT_VERSION}" > "${REPO_DATA}/dataVersionNumber.txt";

git -C "${REPO_DATA}" add dataVersionNumber.txt;

git -C "${REPO_DATA}" commit -m "Bump data version to ${CURRENT_VERSION}";

# Create the new tags.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do

    git -C "${REPO}" tag -a -m "Version ${CURRENT_VERSION}" "${TAG_BASE}${CURRENT_VERSION}";

done;