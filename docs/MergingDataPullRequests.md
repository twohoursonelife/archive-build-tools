# Merging Data Pull Requests

Merging data pull requests requires a few extra steps to ensure consistency and generates a bunch of extra commits. The methodology here is that the next object, sprite and sound numbers are always 20000 on all incoming changes. When we merge we also renumber these files down to just above the otherwise highest number. There are scripts that handle this that will require a nodejs installation.

## Process

Suppose we have received a pull request from REMOTE/BRANCH, here are the steps we follow:

1. Check if the remote exists already: `git remote`
2. Add the new remote if needed: `git remote add REMOTE https://github.com/REMOTE/crucible-data.git`
3. Fetch the incoming branch: `git fetch REMOTE BRANCH`
4. Switch to the local master: `git checkout master`
5. Merge the incoming branch: `git merge REMOTE/BRANCH`
6. If necessary then solve any merge conflicts and commit.
7. Renumber the objects: `node ../../scripts/RenumberObjects.js 20000`
8. Commit if necessary: `git add . && git commit -m 'Renumber objects for REMOTE/BRANCH'`
9. Renumber the sprites: `node ../../scripts/RenumberSprites.js 20000`
10. Commit if necessary: `git add . && git commit -m 'Renumber sprites for REMOTE/BRANCH'`
11. Renumber the sounds: `node ../../scripts/RenumberSounds.js 20000`
12. Commit if necessary: `git add . && git commit -m 'Renumber sounds for REMOTE/BRANCH'`
13. Build and run the client and server.
14. Push the changes: `git push`


```bash

set -e;

REMOTE="${1}"
BRANCH="${2}"

if ! git remote | grep -q "${REMOTE}"; then
    git remote add "${REMOTE}" "https://github.com/${REMOTE}/crucible-data.git";
fi;
git fetch "${REMOTE}" "${BRANCH}";
git checkout master;
git merge "${REMOTE}/${BRANCH}";
node ../../scripts/RenumberObjects.js 20000;
if ! git diff-index --quiet HEAD --; then
    git add .;
    git commit -m "Renumber objects for ${REMOTE}/${BRANCH}";
fi;
node ../../scripts/RenumberSprites.js 20000;
if ! git diff-index --quiet HEAD --; then
    git add .;
    git commit -m "Renumber sprites for ${REMOTE}/${BRANCH}";
fi;
node ../../scripts/RenumberSounds.js 20000;
if ! git diff-index --quiet HEAD --; then
    git add .;
    git commit -m "Renumber sounds for ${REMOTE}/${BRANCH}";
fi;
git push;

```