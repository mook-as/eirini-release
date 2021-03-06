#!/bin/bash

set -euo pipefail

RED='\033[38;2;0;0;0;48;2;255;0;0;1m'
NORMAL='\033[0m'

main() {
  while read -r _ _ remote_ref _; do
    if [[ "$remote_ref" =~ .*/master$ ]]; then
      echo -e "${RED}   Do not push to master. Never.   ${NORMAL}"
    fi
    if [[ "$remote_ref" =~ .*/develop$ ]]; then
      check-ci
    fi
  done
}

check-ci() {
  if check-pipeline "ci" || check-pipeline "eirini-release"; then
    echo -e "${RED}   Pipeline is red.   ${NORMAL}"
    prompt-push
  fi
  echo "CI is green"
}

prompt-push() {
  read -r -p "Do you want to push in eirini-release? [y/N]" yn </dev/tty
  case $yn in
    [Yy]) exit 0 ;;
    *)
      echo 'Bailing out'
      exit 1
      ;;
  esac
}

check-pipeline() {
  local pipeline_name failed_jobs
  pipeline_name="$1"
  curl -s "https://jetson.eirini.cf-app.com/api/v1/teams/main/pipelines/$pipeline_name/jobs" | grep -Eq "failed|error"
}

main
