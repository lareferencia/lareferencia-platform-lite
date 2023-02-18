#!/bin/bash

set -eou pipefail

# load configuration from enviroment.sh
source enviroment.sh

# print configuration
echo "LAREFERENCIA_PLATFORM_PATH: $LAREFERENCIA_PLATFORM_PATH"
echo "LAREFERENCIA_HOME: $LAREFERENCIA_HOME"
echo "LAREFERENCIA_GITHUB_REPO: $LAREFERENCIA_GITHUB_REPO"

# load modules from modules.txt
read -r -a modules <<< $(cat modules.txt)

# print modules
echo "Modules: ${modules[@]}"


LAREFERENCIA_PROJECTS=("${modules[@]}")

msg() {
  echo -e "\x1B[32m[LAREFERENCIA]\x1B[0m $1"
}

msg_scoped() {
  echo -e "\x1B[32m[LAREFERENCIA]\x1B[0m\x1B[33m[$1]\x1B[0m $2"
}

msg_error() {
  echo -e "\x1B[32m[LAREFERENCIA]\x1B[0m\x1B[31m[Error]\x1B[0m $1"
  exit 1
}

_show_config() {
  msg "LAREFERENCIA_PLATFORM_PATH: $LAREFERENCIA_PLATFORM_PATH"
  msg "LAREFERENCIA_HOME: $LAREFERENCIA_HOME"
  msg "LAREFERENCIA_GITHUB_REPO: $LAREFERENCIA_GITHUB_REPO"
  msg "LAREFERENCIA_PROJECTS: $(printf '%s ' ${LAREFERENCIA_PROJECTS[@]})"
}

_last_commit() {
  project=$1
  project_path="$LAREFERENCIA_HOME/$project"
  msg_scoped $project "\x1B[32m$(git branch --show-current)\x1B[0m last commit: $(cd $project_path && git log --oneline -1)"
}

_clone_or_pull_project() {
  project=$1
  project_repo=$(echo $LAREFERENCIA_GITHUB_REPO | sed -e 's/{PROJECT}/'$project'/g')
  project_path="$LAREFERENCIA_HOME/$project"
  if [ -d $project_path ]; then
    (msg_scoped $project "Pulling in $project_path" && cd $project_path && git pull || msg_error "Failed to pull $project") || exit 255
  else
    (msg_scoped $project "Cloning to $project_path" && git clone $project_repo $project_path || msg_error "Failed to clone $project") || exit 255
  fi
  
  # if [ ! -L $project ]; then
  #   (msg_scoped $project "Creating symlink for $project_path" && ln -s $LAREFERENCIA_HOME/$project $project || msg_error "Failed create symlink $project") || exit 255
  # fis
}

_clone_or_pull() {
  projects="$@"
  printf "%s\0" ${projects[@]} | xargs -0 -I% -n 1 -P1 bash -c '_clone_or_pull_project %'
  printf "%s\0" ${projects[@]} | xargs -0 -I% -n 1 -P8 bash -c '_last_commit %'
}

_configure() {
  # exports for xargs/parallel runs
  export -f msg
  export -f msg_scoped
  export -f msg_error
  export -f _clone_or_pull_project
  export -f _last_commit
  export -p LAREFERENCIA_PLATFORM_PATH
  export -p LAREFERENCIA_HOME
  export -p LAREFERENCIA_GITHUB_REPO
  export -p PROFILE
}

help() {
  echo "Pull all or clone selected projects:"
  echo ""
  echo "  $0 [project...]"
  echo ""
  echo "Show help:"
  echo ""
  echo "  $0 help"
  echo ""
}

pull() {
  _configure
  _show_config
  _clone_or_pull ${LAREFERENCIA_PROJECTS[@]}
  
  msg "Done."
}

[ "${1:-}" == "help" ] && help && exit 0

pull
