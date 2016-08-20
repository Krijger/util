#!/usr/bin/env bash

set -eu

if [ $# -eq 0 ]; then
echo -e "Usage: $0 GITHUB_USER\n"
echo -e "A directory will be created for your user, in which the repositories will be cloned.";
echo -e "This fails silently in case the Github user contains so many repos that is answers with pagination.";
exit 1;
fi

GITHUB_USER="$1"

GIT_CLONE_CMD="git clone --recursive"

REPOLIST=`curl --silent https://api.github.com/users/${GITHUB_USER}/repos -q | grep "\"ssh_url\"" | awk -F': "' '{print $2}' | sed -e 's/",//g'`

if [[ -d "${GITHUB_USER}" ]]; then
  echo "Directory ${GITHUB_USER} already exists. Will check for new repositories though."
else
  echo "Creating directory $(pwd)/${GITHUB_USER}"
  mkdir ./${GITHUB_USER}
fi

cd ./${GITHUB_USER}

# loop over all repository urls and execute clone
for REPO in ${REPOLIST}; do
  ${GIT_CLONE_CMD} ${REPO} || echo "Failed to clone ${REPO} - does it already exist?"
done

cd -
