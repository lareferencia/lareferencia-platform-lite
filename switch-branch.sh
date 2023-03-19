#!/bin/bash

set -eou pipefail

# load configuration from enviroment.sh
source enviroment.sh

# print configuration
echo "LAREFERENCIA_PLATFORM_PATH: $LAREFERENCIA_PLATFORM_PATH"
echo "LAREFERENCIA_HOME: $LAREFERENCIA_HOME"
echo "LAREFERENCIA_GITHUB_REPO: $LAREFERENCIA_GITHUB_REPO"

# check parameters passed to script and print usage
if [ $# -lt 1 ]; then
  echo "Usage: $0 <branch>"
  echo "  branch: branch to switch to"
  exit 1
fi

# obtain branch name from command line
if [ $# -gt 0 ]; then
  branch="$1"
else
  branch="main"
fi


# load modules from modules.txt
read -r -a modules <<< $(cat modules.txt)

# print modules
echo "Modules: ${modules[@]}"

# iterate over modules and switch to change  branch
for module in "${modules[@]}"; do

    echo "Module: $module"
    cd $LAREFERENCIA_HOME/$module

    git fetch --all
    git checkout $branch
    git pull

done
