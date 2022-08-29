#!/bin/bash
#
# Provide the Docker environment for ASUS IoT.

export ASUS_DOCKER_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source ${ASUS_DOCKER_ENV_DIR}/docker-builder-base.sh

start_time=$SECONDS

asus_docker_env_main "$@"

elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M mins %S secs')"
