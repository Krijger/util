#!/usr/bin/env bash

set -eu

if [ $# -eq 0 ]; then
echo -e "Usage: $0 GITHUB_ORGANIZATION\n"
echo -e "A directory will be created for your organisation, in which the repositories will be cloned.";
echo -e "This fails silently in case the Github organisation contains so many repos that is answers with pagination.";
exit 1;
fi

GITHUB_ORGANIZATION="$1"

GIT_CLONE_CMD="git clone --recursive"

REPOLIST=`curl --silent https://api.github.com/orgs/${GITHUB_ORGANIZATION}/repos -q | grep "\"ssh_url\"" | awk -F': "' '{print $2}' | sed -e 's/",//g'`

if [[ -d "${GITHUB_ORGANIZATION}" ]]; then
  echo "Directory ${GITHUB_ORGANIZATION} already exists. Will check for new repositories though."
else
  echo "Creating directory $(pwd)/${GITHUB_ORGANIZATION}"
  mkdir ./${GITHUB_ORGANIZATION}
fi

cd ./${GITHUB_ORGANIZATION}

# loop over all repository urls and execute clone
for REPO in ${REPOLIST}; do
  ${GIT_CLONE_CMD} ${REPO} || echo "Failed to clone ${REPO} - does it already exist?"
done

cd -
