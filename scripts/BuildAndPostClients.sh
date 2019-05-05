#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;

./scripts/EnsureClean.sh;

./scripts/EnsureMaster.sh;

cd repos;



###############################################################################
## Preparation ################################################################
###############################################################################


# Determine the current and previous versions.

PREVIOUS_VERSION="$(git -C "${REPO_CODE}" for-each-ref --sort=-creatordate \
    --format="%(refname:short)" --count=2 "refs/tags/${TAG_BASE}*" | \
    tail -n 1 | sed "s/^${TAG_BASE}//")";

PREVIOUS_VERSION_REF="${TAG_BASE}${PREVIOUS_VERSION}";

CURRENT_VERSION="$(git -C "${REPO_CODE}" for-each-ref --sort=-creatordate \
    --format="%(refname:short)" --count=1 "refs/tags/${TAG_BASE}*" | \
    sed "s/^${TAG_BASE}//")";

CURRENT_VERSION_REF="${TAG_BASE}${CURRENT_VERSION}";


# Override versions when asked to build from master.

if [[ -n "${CRUCIBLE_BUILD_MASTER}" ]]; then

    PREVIOUS_VERSION="${CURRENT_VERSION}";

    PREVIOUS_VERSION_REF="${CURRENT_VERSION_REF}";

    CURRENT_VERSION="${CURRENT_VERSION}+$(date "+%Y%m%dT%H%M%S")";

    CURRENT_VERSION_REF="master";

fi;

    

###############################################################################
## Linux ######################################################################
###############################################################################


# Clean the repositories.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
done;


# Build the current version distribution.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
done;

cd OneLife;

./configure 1;

cd gameSource;

make;

cd ../build/source;

./makeLinuxBuild "v${CURRENT_VERSION}";

cp "OneLife_v${CURRENT_VERSION}_Linux.tar.gz" ~/client_builds;

cd ../../..;


# Build the previous version distribution.

if [[ "${CURRENT_VERSION}" -ge 3 ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
        git -C "${REPO}" checkout "${PREVIOUS_VERSION_REF}";
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
        git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
    done;

    cd minorGems/game/diffBundle;

    ./diffBundleCompile;

    cd ../../../OneLife/build/source;

    ../../../minorGems/game/diffBundle/diffBundle \
        "OneLife_v${PREVIOUS_VERSION}" \
        "OneLife_v${CURRENT_VERSION}" \
        "${CURRENT_VERSION}_inc_linux.dbz";

    cp "${CURRENT_VERSION}_inc_linux.dbz" ~/diff_bundles;

    cd ../../..;

fi;


# Clean everything up.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
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

if [[ ! -d windows_deps ]]; then
    mkdir windows_deps;
fi;

cd windows_deps;

if [[ ! -f SDL-devel-1.2.15-mingw32.tar.gz ]]; then
    wget https://www.libsdl.org/release/SDL-devel-1.2.15-mingw32.tar.gz;
fi;

if [[ ! -d SDL-1.2.15 ]]; then
    tar -xzf SDL-devel-1.2.15-mingw32.tar.gz;
fi;

ln -s "$(realpath .)/SDL-1.2.15/include/SDL" ../repos/SDL;

export CUSTOM_MINGW_LINK_FLAGS="-L$(realpath .)/SDL-1.2.15/lib";

cd ../repos;


# Build the current version distribution.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
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

cp "OneLife_v${CURRENT_VERSION}_Windows.zip" ~/client_builds;

cd ../../..;


# Build the previous version distribution.

if [[ "${CURRENT_VERSION}" -ge 3 ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
        git -C "${REPO}" checkout "${PREVIOUS_VERSION_REF}";
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
        git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
    done;

    cd minorGems/game/diffBundle;

    ./diffBundleCompile;

    cd ../../../OneLife/build/windows;

    ../../../minorGems/game/diffBundle/diffBundle \
        "OneLife_v${PREVIOUS_VERSION}" \
        "OneLife_v${CURRENT_VERSION}" \
        "${CURRENT_VERSION}_inc_win.dbz";

    cp "${CURRENT_VERSION}_inc_win.dbz" ~/diff_bundles;

    cd ../../..;

fi;


# Clean everything up.

unset CUSTOM_MINGW_LINK_FLAGS;

rm SDL;

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
done;



###############################################################################
## macOS ######################################################################
###############################################################################


# Clean the repositories.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
done;


# Prepare the foreign SDL library.

cd ..;

if [[ ! -d macos_deps ]]; then
    mkdir macos_deps;
fi;

cd macos_deps;

if [[ ! -f SDL-1.2.15.dmg ]]; then
    wget https://www.libsdl.org/release/SDL-1.2.15.dmg;
fi;

if [[ ! -f SDL-1.2.15.img ]]; then
    dmg2img SDL-1.2.15.dmg;
fi;

if [[ ! -d SDL.framework ]]; then

    mkdir sdl_mount;

    sudo mount -o loop -t hfsplus SDL-1.2.15.img sdl_mount;

    cp -R sdl_mount/SDL.framework .;

    sudo umount sdl_mount;

    rm -r sdl_mount;

fi;

export CUSTOM_MACOSX_LINK_FLAGS="-F$(realpath .)";

cd ../repos;


# Build the current version distribution.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
done;

cd OneLife;

./configure 2;

cd gameSource;

_OLD_PATH="${PATH}"; export PATH="/home/richard/osxcross/target/bin:${PATH}";

cp Makefile Makefile.bak;

sed -i -r '/^GXX =/aGXX = o32-g++' Makefile;

sed -i -r '/PLATFORM_COMPILE_FLAGS =/aPLATFORM_COMPILE_FLAGS += ${CUSTOM_MACOSX_LINK_FLAGS}' Makefile;

make;

mv Makefile.bak Makefile;

export PATH="${_OLD_PATH}"; unset _OLD_PATH;

cd ../build;

./makeDistributionMacOSX "v${CURRENT_VERSION}" IntelMacOSX ../../../macos_deps/SDL.framework;

cd mac;

cp "OneLife_v${CURRENT_VERSION}_IntelMacOSX.tar.gz" ~/client_builds;

cd ../../..;


# Build the previous version distribution.

if [[ "${CURRENT_VERSION}" -ge 3 ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
        git -C "${REPO}" checkout "${PREVIOUS_VERSION_REF}";
    done;

    cd OneLife;

    ./configure 2;

    cd gameSource;

    _OLD_PATH="${PATH}"; export PATH="/home/richard/osxcross/target/bin:${PATH}";

    cp Makefile Makefile.bak;

    sed -i -r '/^GXX =/aGXX = o32-g++' Makefile;

    sed -i -r '/PLATFORM_COMPILE_FLAGS =/aPLATFORM_COMPILE_FLAGS += ${CUSTOM_MACOSX_LINK_FLAGS}' Makefile;

    make;

    mv Makefile.bak Makefile;

    export PATH="${_OLD_PATH}"; unset _OLD_PATH;

    cd ../build;

    ./makeDistributionMacOSX "v${PREVIOUS_VERSION}" IntelMacOSX ../../../macos_deps/SDL.framework;

    cd mac;

    cp "OneLife_v${PREVIOUS_VERSION}_IntelMacOSX.tar.gz" ~/diff_bundles;

    cd ../../..;

fi;


# Build the incremental bundle.

if [[ "${CURRENT_VERSION}" -ge 3 ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
        git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
    done;

    cd minorGems/game/diffBundle;

    ./diffBundleCompile;

    cd ../../../OneLife/build/mac;

    ../../../minorGems/game/diffBundle/diffBundle \
        "OneLife_v${PREVIOUS_VERSION}" \
        "OneLife_v${CURRENT_VERSION}" \
        "${CURRENT_VERSION}_inc_mac.dbz";

    cp "${CURRENT_VERSION}_inc_mac.dbz" ~;

    cd ../../..;

fi;


# Clean everything up.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    git -C "${REPO}" clean -f -x -d;
    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
done;
