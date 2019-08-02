#!/bin/bash

set -e;

cd "$(dirname "${0}")/..";

source ./scripts/CommonVariables.sh;

./scripts/BuildMacBinaries.sh;

[[ -d build ]] || mkdir build;

[[ -d build/client ]] || mkdir build/client;

[[ -d build/editor ]] || mkdir build/editor;

for TARGET in animations categories ground music objects scenes sounds soundsRaw sprites transitions dataVersionNumber.txt; do

    [[ -e "build/client/${TARGET}" ]] || ln -s "../../repos/OneLifeData7/${TARGET}" "build/client/${TARGET}";

    [[ -e "build/editor/${TARGET}" ]] || ln -s "../../repos/OneLifeData7/${TARGET}" "build/editor/${TARGET}";

done;

for TARGET in graphics languages otherSounds eqImpulseResponse.aiff reverbImpulseResponse.aiff; do

    [[ -e "build/client/${TARGET}" ]] || ln -s "../../repos/OneLife/gameSource/${TARGET}" "build/client/${TARGET}";

    [[ -e "build/editor/${TARGET}" ]] || ln -s "../../repos/OneLife/gameSource/${TARGET}" "build/editor/${TARGET}";

done;

[[ -e "build/client/Crucible" ]] || ln -s "../../repos/OneLife/gameSource/Crucible" "build/client/Crucible";

[[ -e "build/editor/EditCrucible" ]] || ln -s "../../repos/OneLife/gameSource/EditCrucible" "build/editor/EditCrucible";

[[ -d build/client/settings ]] || mkdir build/client/settings;

[[ -d build/editor/settings ]] || mkdir build/editor/settings;

for SETTING in $(ls repos/OneLife/gameSource/settings); do

    [[ -f "build/client/settings/${SETTING}" ]] || cp "repos/OneLife/gameSource/settings/${SETTING}" "build/client/settings/${SETTING}";

    [[ -f "build/editor/settings/${SETTING}" ]] || cp "repos/OneLife/gameSource/settings/${SETTING}" "build/editor/settings/${SETTING}";

done;

echo 'AAAAA-BBBBB-CCCCC-DDDDD' > build/client/settings/accountKey.ini;

echo 'example@example.com' > build/client/settings/email.ini;

echo 0 > build/client/settings/fullscreen.ini

echo 1 > build/client/settings/tutorialDone.ini;

echo 1 > build/client/settings/useCustomServer.ini;

echo 1 > build/editor/settings/fullscreen.ini

[[ -d build/server ]] || mkdir build/server;

for TARGET in categories objects transitions tutorialMaps dataVersionNumber.txt; do

    [[ -e "build/server/${TARGET}" ]] || ln -s "../../repos/OneLifeData7/${TARGET}" "build/server/${TARGET}";

done;

[[ -e "build/server/serverCodeVersionNumber.txt" ]] || ln -s dataVersionNumber.txt build/server/serverCodeVersionNumber.txt;

for TARGET in firstNames.txt lastNames.txt CrucibleServer; do

    [[ -e "build/server/${TARGET}" ]] || ln -s "../../repos/OneLife/server/${TARGET}" "build/server/${TARGET}";

done;

[[ -d build/server/settings ]] || mkdir build/server/settings;

for SETTING in $(ls repos/OneLife/server/settings); do

    [[ -f "build/server/settings/${SETTING}" ]] || cp "repos/OneLife/server/settings/${SETTING}" "build/server/settings/${SETTING}";

done;

echo 0 > build/server/settings/apocalypsePossible.ini;

echo 1 > build/server/settings/forceEveLocation.ini;

echo 0 > build/server/settings/requireTicketServerCheck.ini;

echo 0 > build/server/settings/useCurseServer.ini;

echo 0 > build/server/settings/useLineageServer.ini;

echo 0 > build/server/settings/useStatsServer.ini;
