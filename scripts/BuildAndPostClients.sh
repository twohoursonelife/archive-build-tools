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


# Collect arguments.

BUILD_MODE="${1-master}";


# Prepare the output directory.

if [[ -d ../output ]]; then

    rm -r ../output;

fi;

mkdir ../output;

mkdir -p ../output/clientBuilds;

mkdir -p ../output/diffBundles;


# Determine the current and previous versions.

PREVIOUS_VERSION="$(git -C "${REPO_CODE}" for-each-ref --sort=-creatordate \
    --format="%(refname:short)" --count=2 "refs/tags/${TAG_BASE}*" | \
    tail -n 1 | sed "s/^${TAG_BASE}//")";

PREVIOUS_VERSION_REF="${TAG_BASE}${PREVIOUS_VERSION}";

CURRENT_VERSION="$(git -C "${REPO_CODE}" for-each-ref --sort=-creatordate \
    --format="%(refname:short)" --count=1 "refs/tags/${TAG_BASE}*" | \
    sed "s/^${TAG_BASE}//")";

CURRENT_VERSION_REF="${TAG_BASE}${CURRENT_VERSION}";


# Override tagged versions when not building from tags.

if [[ "${BUILD_MODE}" = "master" ]]; then

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

cp "OneLife_v${CURRENT_VERSION}_Linux.tar.gz" ../../../../output/clientBuilds;

cd ../../..;


# Build the previous version distribution.

if [[ "${BUILD_MODE}" = "tag" ]]; then

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

if [[ "${BUILD_MODE}" = "tag" ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do

        git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";

    done;

    cd minorGems/game/diffBundle;

    ./diffBundleCompile;

    cd ../../../OneLife/build/source;

    ../../../minorGems/game/diffBundle/diffBundle \
        "OneLife_v${PREVIOUS_VERSION}" \
        "OneLife_v${CURRENT_VERSION}" \
        "${CURRENT_VERSION}_inc_linux.dbz" \
        "${CURRENT_VERSION}_full_linux.dbz";

    cp "${CURRENT_VERSION}_inc_linux.dbz" ../../../../output/diffBundles;

    cp "${CURRENT_VERSION}_full_linux.dbz" ../../../../output/diffBundles;

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


# Prepare the foreign ZLIB library.

cd ..;

if [[ ! -d windows_deps ]]; then

    mkdir windows_deps;

fi;

cd windows_deps;

if [[ ! -f zlib-1.2.11.tar.gz ]]; then

    wget https://www.zlib.net/zlib-1.2.11.tar.gz;

fi;

[[ "$(sha256sum -b zlib-1.2.11.tar.gz | cut "-d " -f1)" = \
   "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1" ]];

if [[ ! -d zlib-1.2.11 ]]; then

    tar -xzf zlib-1.2.11.tar.gz;

fi;

cd zlib-1.2.11;

_OLD_PATH="${PATH}"; export PATH="/usr/i686-w64-mingw32/bin:${PATH}";

./configure --static;

make;

gcc -shared -o zlib1.dll $(ls *.o | grep -v example | grep -v minigzip);

export PATH="${_OLD_PATH}"; unset _OLD_PATH;

export CUSTOM_MINGW_COMPILE_FLAGS="-I$(realpath .) ${CUSTOM_MINGW_COMPILE_FLAGS}";

export CUSTOM_MINGW_LINK_FLAGS="-L$(realpath .) ${CUSTOM_MINGW_LINK_FLAGS}";

cd ../../repos;


# Prepare the foreign PNG library.

cd ..;

if [[ ! -d windows_deps ]]; then

    mkdir windows_deps;

fi;

cd windows_deps;

if [[ ! -f libpng-1.6.37.tar.gz ]]; then

    wget https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz;

fi;

[[ "$(sha256sum -b libpng-1.6.37.tar.gz | cut "-d " -f1)" = \
   "daeb2620d829575513e35fecc83f0d3791a620b9b93d800b763542ece9390fb4" ]];

if [[ ! -d libpng-1.6.37 ]]; then

    tar -xzf libpng-1.6.37.tar.gz;

fi;

cd libpng-1.6.37;

_OLD_PATH="${PATH}"; export PATH="/usr/i686-w64-mingw32/bin:${PATH}";

./configure --host mingw32;

make;

export PATH="${_OLD_PATH}"; unset _OLD_PATH;

export CUSTOM_MINGW_COMPILE_FLAGS="-I$(realpath .) ${CUSTOM_MINGW_COMPILE_FLAGS}";

export CUSTOM_MINGW_LINK_FLAGS="-L$(realpath .)/.libs ${CUSTOM_MINGW_LINK_FLAGS}";

cd ../../repos;


# Prepare the foreign SDL library.

cd ..;

if [[ ! -d windows_deps ]]; then

    mkdir windows_deps;

fi;

cd windows_deps;

if [[ ! -f SDL-devel-1.2.15-mingw32.tar.gz ]]; then

    wget https://www.libsdl.org/release/SDL-devel-1.2.15-mingw32.tar.gz;

fi;

[[ "$(sha256sum -b SDL-devel-1.2.15-mingw32.tar.gz | cut "-d " -f1)" = \
   "d51eedfe7e07893d6c93a2d761c6ccc91d04b5f68a2ecabdbef83b7a1fef9cde" ]];

if [[ ! -d SDL-1.2.15 ]]; then

    tar -xzf SDL-devel-1.2.15-mingw32.tar.gz;

fi;

cd SDL-1.2.15;

export CUSTOM_MINGW_COMPILE_FLAGS="-I$(realpath .)/include ${CUSTOM_MINGW_COMPILE_FLAGS}";

export CUSTOM_MINGW_LINK_FLAGS="-L$(realpath .)/lib ${CUSTOM_MINGW_LINK_FLAGS}";

cd ../../repos;


# Build the current version distribution.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do

    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";

done;

cd OneLife;

./configure 3;

cd gameSource;

_OLD_PATH="${PATH}"; export PATH="/usr/i686-w64-mingw32/bin:${PATH}";

cp Makefile Makefile.bak;

sed -i -r '/PLATFORM_COMPILE_FLAGS =/aPLATFORM_COMPILE_FLAGS += ${CUSTOM_MINGW_COMPILE_FLAGS}' Makefile;

sed -i -r '/^PLATFORM_LIBPNG_FLAG =/aPLATFORM_LIBPNG_FLAG = -lz -lpng16' Makefile;

make;

./makeEditor.sh;

mv Makefile.bak Makefile;

export PATH="${_OLD_PATH}"; unset _OLD_PATH;

cp OneLife OneLife.exe;

cp EditOneLife EditOneLife.exe;

cd ../build;

./makeDistributionWindows "v${CURRENT_VERSION}";

cd windows;

zip -r "OneLife_v${CURRENT_VERSION}_Windows.zip" "OneLife_v${CURRENT_VERSION}";

cp "OneLife_v${CURRENT_VERSION}_Windows.zip" ../../../../output/clientBuilds;

cd ../../..;


# Build the editor bundle.

mkdir ../output/editorFiles;

cp crucible-code/gameSource/EditOneLife.exe ../output/editorFiles;

cp ../windows_deps/SDL-1.2.15/bin/SDL.dll ../output/editorFiles;

cp ../windows_deps/libpng-1.6.37/.libs/libpng16-16.dll ../output/editorFiles;

cp ../windows_deps/zlib-1.2.11/zlib1.dll ../output/editorFiles;

cp "$(find /usr -name libgcc_s_sjlj-1.dll | head -1)" ../output/editorFiles;

cp -R crucible-code/gameSource/graphics ../output/editorFiles;

cp -R crucible-code/gameSource/languages ../output/editorFiles;

cp -R crucible-code/gameSource/settings ../output/editorFiles;

echo 0 > ../output/editorFiles/settings/fullscreen.ini;

if [[ -f "../output/EditOneLife_v${CURRENT_VERSION}_Windows.zip" ]]; then
    
    rm "../output/EditOneLife_v${CURRENT_VERSION}_Windows.zip";

fi;

zip -r "../output/EditOneLife_v${CURRENT_VERSION}_Windows.zip" ../output/editorFiles/*;


# Build the previous version distribution.

if [[ "${BUILD_MODE}" = "tag" ]]; then

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

    cd ../..;

fi;


# Build the incremental bundle.

if [[ "${BUILD_MODE}" = "tag" ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do

        git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";

    done;

    cd minorGems/game/diffBundle;

    ./diffBundleCompile;

    cd ../../../OneLife/build/windows;

    ../../../minorGems/game/diffBundle/diffBundle \
        "OneLife_v${PREVIOUS_VERSION}" \
        "OneLife_v${CURRENT_VERSION}" \
        "${CURRENT_VERSION}_inc_win.dbz" \
        "${CURRENT_VERSION}_full_win.dbz";

    cp "${CURRENT_VERSION}_inc_win.dbz" ../../../../output/diffBundles;

    cp "${CURRENT_VERSION}_full_win.dbz" ../../../../output/diffBundles;

    cd ../../..;

fi;


# Clean everything up.

unset CUSTOM_MINGW_COMPILE_FLAGS;

unset CUSTOM_MINGW_LINK_FLAGS;

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do

    git -C "${REPO}" clean -f -x -d;

    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";
    
done;



###############################################################################
## MacOS ######################################################################
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

[[ "$(sha256sum -b SDL-1.2.15.dmg | cut "-d " -f1)" = \
   "49e228446599b1f77af812a6276dd7a3f230f8d7a02d1b7b62bb99a874262834" ]];

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

export CUSTOM_MACOSX_LINK_FLAGS="-F$(realpath .) ${CUSTOM_MACOSX_LINK_FLAGS}";

export CUSTOM_MACOSX_COMPILE_FLAGS="-F$(realpath .) ${CUSTOM_MACOSX_COMPILE_FLAGS}";

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

sed -i -r '/PLATFORM_COMPILE_FLAGS =/aPLATFORM_COMPILE_FLAGS += ${CUSTOM_MACOSX_LINK_FLAGS}' Makefile;

sed -i -r '/^GXX =/aGXX = o32-g++' Makefile;

make;

mv Makefile.bak Makefile;

export PATH="${_OLD_PATH}"; unset _OLD_PATH;

cd ../build;

./makeDistributionMacOSX "v${CURRENT_VERSION}" IntelMacOSX ../../../macos_deps/SDL.framework;

cd mac;

cp "OneLife_v${CURRENT_VERSION}_IntelMacOSX.tar.gz" ../../../../output/clientBuilds;

cd ../../..;


# Build the previous version distribution.

if [[ "${BUILD_MODE}" = "tag" ]]; then

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

    cd ../..;

fi;


# Build the incremental bundle.

if [[ "${BUILD_MODE}" = "tag" ]]; then

    for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do

        git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";

    done;

    cd minorGems/game/diffBundle;

    ./diffBundleCompile;

    cd ../../../OneLife/build/mac;

    ../../../minorGems/game/diffBundle/diffBundle \
        "OneLife_v${PREVIOUS_VERSION}" \
        "OneLife_v${CURRENT_VERSION}" \
        "${CURRENT_VERSION}_inc_mac.dbz" \
        "${CURRENT_VERSION}_full_mac.dbz";

    cp "${CURRENT_VERSION}_inc_mac.dbz" ../../../../output/diffBundles;

    cp "${CURRENT_VERSION}_full_mac.dbz" ../../../../output/diffBundles;

    cd ../../..;

fi;


# Clean everything up.

for REPO in ${REPO_CODE} ${REPO_DATA} ${REPO_GEMS}; do
    
    git -C "${REPO}" clean -f -x -d;
    
    git -C "${REPO}" checkout "${CURRENT_VERSION_REF}";

done;



###############################################################################
## Post #######################################################################
###############################################################################


cd ..;

if [[ "${BUILD_MODE}" = "tag" ]]; then

    sudo cp output/clientBuilds/* /var/www/html/download/clientBuilds;

    sudo cp output/diffBundles/* /var/www/html/download/diffBundles;

else

    sudo rm /var/www/html/download/latestBuilds/* || true;

    sudo cp output/clientBuilds/* /var/www/html/download/latestBuilds;

    sudo cp output/EditOneLife_v*.zip /var/www/html/download/latestBuilds;

fi;

cd repos;