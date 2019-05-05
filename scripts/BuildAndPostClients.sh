#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;

./scripts/EnsureClean.sh;

./scripts/EnsureMaster.sh;

cd repos;



###############################################################################
## Versions ###################################################################
###############################################################################

# Determine the current and previous versions.

PREVIOUS_VERSION="$(git -C "${REPO_CODE}" for-each-ref --sort=-creatordate \
    --format="%(refname:short)" --count=2 "refs/tags/${TAG_BASE}*" | \
    tail -n 1 | sed "s/^${TAG_BASE}//")";

CURRENT_VERSION="$(git -C "${REPO_CODE}" for-each-ref --sort=-creatordate \
    --format="%(refname:short)" --count=1 "refs/tags/${TAG_BASE}*" | \
    sed "s/^${TAG_BASE}//")";

    

###############################################################################
## Linux ######################################################################
###############################################################################

# Clean the repositories.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
done;

# Build the current version distribution.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" checkout "${TAG_BASE}${CURRENT_VERSION}";
done;

cd OneLife;

./configure 1;

cd gameSource;

make;

cd ../build/source;

./makeLinuxBuild "v${CURRENT_VERSION}";

cp "OneLife_v${CURRENT_VERSION}_Linux.tar.gz" ~;

cd ../../..;

# Build the previous version distribution.

if [[ "${CURRENT_VERSION}" -ge 3 ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
        git -C "${REPO}" checkout "${TAG_BASE}${PREVIOUS_VERSION}";
    done;

    cd OneLife;

    ./configure 1;

    cd gameSource;

    make;

    cd ../build/source;

    ./makeLinuxBuild "v${PREVIOUS_VERSION}";

    cd ../../..;

fi;

# Build the incremental bundle.

if [[ "${CURRENT_VERSION}" -ge 3 ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
        git -C "${REPO}" checkout "${TAG_BASE}${CURRENT_VERSION}";
    done;

    cd minorGems/game/diffBundle;

    ./diffBundleCompile;

    cd ../../../OneLife/build/source;

    ../../../minorGems/game/diffBundle/diffBundle \
        "OneLife_v${PREVIOUS_VERSION}" \
        "OneLife_v${CURRENT_VERSION}" \
        "${CURRENT_VERSION}_inc_linux.dbz";

    cp "${CURRENT_VERSION}_inc_linux.dbz" ~;

    cd ../../..;

fi;

# Clean everything up.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
    git -C "${REPO}" checkout "${TAG_BASE}${CURRENT_VERSION}";
done;



###############################################################################
## Windows ####################################################################
###############################################################################

# Clean the repositories.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
done;

# Prepare the foreign SDL library.

cd ..;

if [[ ! -f SDL-devel-1.2.15-mingw32.tar.gz ]]; then
    wget https://www.libsdl.org/release/SDL-devel-1.2.15-mingw32.tar.gz;
fi;

if [[ ! -d SDL-1.2.15 ]]; then
    tar -xzf SDL-devel-1.2.15-mingw32.tar.gz;
fi;

export CUSTOM_MINGW_LINK_FLAGS="-L$(realpath .)/SDL-1.2.15/lib";

cd repos;

ln -s ../SDL-1.2.15/include/SDL SDL;

# Build the current version distribution.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" checkout "${TAG_BASE}${CURRENT_VERSION}";
done;

cd OneLife;

./configure 3;

cd gameSource;

_OLD_PATH="${PATH}"; export PATH="/usr/i686-w64-mingw32/bin:${PATH}";

make;

export PATH="${_OLD_PATH}"; unset _OLD_PATH;

cp OneLife OneLife.exe;

cd ../build;

./makeDistributionWindows "v${CURRENT_VERSION}";

cd windows;

zip -r "OneLife_v${CURRENT_VERSION}_Windows.zip" "OneLife_v${CURRENT_VERSION}";

cp "OneLife_v${CURRENT_VERSION}_Windows.zip" ~;

cd ../../..;

# Build the previous version distribution.

if [[ "${CURRENT_VERSION}" -ge 3 ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
        git -C "${REPO}" checkout "${TAG_BASE}${PREVIOUS_VERSION}";
    done;

    cd OneLife;

    ./configure 3;

    cd gameSource;

    _OLD_PATH="${PATH}"; export PATH="/usr/i686-w64-mingw32/bin:${PATH}";

    make;

    export PATH="${_OLD_PATH}"; unset _OLD_PATH;

    cp OneLife OneLife.exe;

    cd ../build;

    ./makeDistributionWindows "v${PREVIOUS_VERSION}";

    cd windows;

    zip -r "OneLife_v${PREVIOUS_VERSION}_Windows.zip" "OneLife_v${PREVIOUS_VERSION}";

    cd ../../..;

fi;

# Build the incremental bundle.

if [[ "${CURRENT_VERSION}" -ge 3 ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
        git -C "${REPO}" checkout "${TAG_BASE}${CURRENT_VERSION}";
    done;

    cd minorGems/game/diffBundle;

    ./diffBundleCompile;

    cd ../../../OneLife/build/windows;

    ../../../minorGems/game/diffBundle/diffBundle \
        "OneLife_v${PREVIOUS_VERSION}" \
        "OneLife_v${CURRENT_VERSION}" \
        "${CURRENT_VERSION}_inc_win.dbz";

    cp "${CURRENT_VERSION}_inc_win.dbz" ~;

    cd ../../..;

fi;

# Clean everything up.

unset CUSTOM_MINGW_LINK_FLAGS;

rm SDL;

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
    git -C "${REPO}" checkout "${TAG_BASE}${CURRENT_VERSION}";
done;
