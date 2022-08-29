#!/bin/bash
#
# Provide the Docker environment for ASUS IoT.

declare -r ASUS_DOCKER_ENV_DEFAULT_WORKDIR="/source"

export ASUS_DOCKER_ENV_BRANCH="linux4.4-rk3399pro"
export ASUS_DOCKER_ENV_SOURCE="$(dirname ${ASUS_DOCKER_ENV_DIR})"
export ASUS_DOCKER_ENV_DOCKERFILE="${ASUS_DOCKER_ENV_DIR}/Dockerfile"
export ASUS_DOCKER_ENV_IMAGE="asus-iot/asus-docker-env-${ASUS_DOCKER_ENV_BRANCH}:latest"
export ASUS_DOCKER_ENV_WORKDIR=${ASUS_DOCKER_ENV_DEFAULT_WORKDIR}
export ASUS_DOCKER_EVN_OPTIONS="--interactive --privileged --rm --tty --hostname asus-docker-env-${ASUS_DOCKER_ENV_BRANCH} --volume ${ASUS_DOCKER_ENV_SOURCE}:${ASUS_DOCKER_ENV_WORKDIR} --workdir ${ASUS_DOCKER_ENV_WORKDIR}"

#if [ $# -eq 0 ]; then
#    echo "There is no directory path to the source provided."
#    echo "Use the default directory path to the source [$DIRECTORY_PATH_TO_SOURCE]."
#else
#    DIRECTORY_PATH_TO_SOURCE=$1
#    if [ ! -d $DIRECTORY_PATH_TO_SOURCE ]; then
#        echo "The source directory [$DIRECTORY_PATH_TO_SOURCE] is not found."
#        exit
#    fi
#fi

#function asus_docker_env_set_source() {
#  if [ $# -eq 0 ]; then
#    echo "Please provide the source path."
#  else
#    export ASUS_DOCKER_ENV_SOURCE="$(readlink -f ${1})"
#    export ASUS_DOCKER_ENV_WORKDIR=${ASUS_DOCKER_ENV_DEFAULT_WORKDIR}
#    asus_docker_env_show_variables
#  fi
#}

function asus_docker_env_show_variables() {
  echo "====================================================================="
  echo "ASUS_DOCKER_ENV_DIR:        ${ASUS_DOCKER_ENV_DIR}"
  echo "ASUS_DOCKER_ENV_SOURCE:     ${ASUS_DOCKER_ENV_SOURCE}"
  echo "ASUS_DOCKER_ENV_DOCKERFILE: ${ASUS_DOCKER_ENV_DOCKERFILE}"
  echo "ASUS_DOCKER_ENV_IMAGE:      ${ASUS_DOCKER_ENV_IMAGE}"
  echo "ASUS_DOCKER_ENV_WORKDIR:    ${ASUS_DOCKER_ENV_WORKDIR}"
  echo "ASUS_DOCKER_ENV_OPTIONS:    ${ASUS_DOCKER_EVN_OPTIONS}"
  echo "====================================================================="
}

function asus_docker_env_check_docker() {
  if [[ -x "$(command -v docker)" ]]; then
    echo "Docker is installed and the permission to execute Docker is granted."
    if getent group docker | grep &>/dev/null "\b$(id -un)\b"; then
      echo "The user $(id -un) is in the group docker."
      return 0
    else
      echo "Docker is not managed as a non-root user."
      echo "Please refer to the following URL to manage Docker as a non-root user."
      echo "https://docs.docker.com/install/linux/linux-postinstall/"
    fi
  else
    echo "Docker is not installed or the permission to execute is not granted."
    echo "Please install Docker first and make sure you are able to run it."
  fi
  return 1
}

function asus_docker_env_check_required_packages {
  if dpkg-query -s qemu-user-static 1>/dev/null 2>&1; then
    echo "The package qemu-user-static is installed."
  else
    echo "The package qemu-user-static is not installed yet. Please install it first."
    return 1
  fi

  if dpkg-query -s binfmt-support 1>/dev/null 2>&1; then
    echo "The package binfmt-support is installed."
  else
    echo "The package binfmt-support is not installed yet. Please install it first."
    return 1
  fi
  return 0
}

# Check to see if all the prerequisites are fullfilled.
function asus_docker_env_check_prerequisites() {
  if [[ ! -d ${ASUS_DOCKER_ENV_DIR} ]]; then
    echo "The directory [${ASUS_DOCKER_ENV_DIR}] for the ASUS IoT Docker environment is not found."
    return 1
  fi

  if [[ ! -d ${ASUS_DOCKER_ENV_SOURCE} ]]; then
    echo "The source directory [${ASUS_DOCKER_ENV_SOURCE}] for the ASUS IoT Docker environment is not found."
    return 1
  fi

  if [[ ! -f ${ASUS_DOCKER_ENV_DOCKERFILE} ]]; then
    echo "Dockerfile [${ASUS_DOCKER_ENV_DOCKERFILE}] for the ASUS IoT Docker environment is not found."
    return 1
  fi

  if ! asus_docker_env_check_docker; then
    return 1
  fi

  if ! asus_docker_env_check_required_packages; then
    return 1
  fi

  # The module loop is not loaded by default for some Linux distributions sucn as Debain.
  # We need this for command mount inside the container"
  if [[ ! -d /sys/module/loop ]]; then
    echo "The module loop is not loaded yet."
    echo "Please load the module loop using the following command first."
    echo "sudo modprobe loop"
    return 1
  fi

  return 0
}

function asus_docker_env_build_docker_image() {
  #if asus_docker_env_check_prerequisites; then
    docker build --tag ${ASUS_DOCKER_ENV_IMAGE} --file ${ASUS_DOCKER_ENV_DOCKERFILE} ${ASUS_DOCKER_ENV_DIR}
  #fi
}

function asus_docker_env_run() {
  echo "Entering the ASUS IoT Docker environment......."
  asus_docker_env_show_variables
#  if [[ "$ASUS_DOCKER_ENV_WORKDIR" != "$ASUS_DOCKER_ENV_DEFAULT_WORKDIR" ]]; then
#    echo "Create the symbolic link $ASUS_DOCKER_ENV_WORKDIR to $ASUS_DOCKER_ENV_SOURCE......."
#    ln -s $ASUS_DOCKER_ENV_SOURCE $ASUS_DOCKER_ENV_WORKDIR
#  fi
  if asus_docker_env_check_prerequisites; then
    asus_docker_env_build_docker_image
#    if [ $# -eq 0 ]; then
      docker run ${ASUS_DOCKER_EVN_OPTIONS} ${ASUS_DOCKER_ENV_IMAGE} /bin/bash -c \
        "groupadd --gid $(id -g) $(id -g -n); \
        useradd -m -e \"\" -s /bin/bash --gid $(id -g) --uid $(id -u) $(id -u -n); \
        passwd -d $(id -u -n); \
        echo \"$(id -u -n) ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers; \
        sudo -E -u $(id -u -n) --set-home /bin/bash -i"
#    else
#      docker run --interactive --privileged --rm --tty \
#        --hostname asus-docker-env \
#        --volume $ASUS_DOCKER_ENV_SOURCE:$ASUS_DOCKER_ENV_WORKDIR \
#        --workdir $ASUS_DOCKER_ENV_WORKDIR \
#        --volume /var/run/docker.sock:/var/run/docker.sock \
#        --volume /var/lib/docker:/var/lib/docker \
#        $ASUS_DOCKER_ENV_IMAGE /bin/bash -c \
#        "groupadd --gid $(id -g) $(id -g -n); \
#        useradd -m -e \"\" -s /bin/bash --gid $(id -g) --uid $(id -u) $(id -u -n); \
#        passwd -d $(id -u -n); \
#        echo \"$(id -u -n) ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers; \
#        sudo groupmod -g $(awk -F\: '/docker/ {print $3}' /etc/group) docker; \
#        sudo usermod -aG docker $(id -u -n); \
#        sudo -E -u $(id -u -n) --set-home ${1}"
#    fi
  fi
#  if [[ "$ASUS_DOCKER_ENV_WORKDIR" != "$ASUS_DOCKER_ENV_DEFAULT_WORKDIR" ]]; then
#    echo "Remove the symbolic link $ASUS_DOCKER_ENV_WORKDIR......."
#    unlink $ASUS_DOCKER_ENV_WORKDIR
#  fi
#
  echo "Leaving the ASUS IoT Docker environment......."
}

#function asus_docker_env_set_source_with_symbolic_link() {
#  if [ $# -eq 0 ]; then
#    echo "Please provide the source path."
#  else
#    export ASUS_DOCKER_ENV_SOURCE="$(readlink -f ${1})"
#    export ASUS_DOCKER_ENV_WORKDIR=`echo ${ASUS_DOCKER_ENV_SOURCE} | md5sum | cut -f1 -d" "`
#    export ASUS_DOCKER_ENV_WORKDIR="/tmp/${ASUS_DOCKER_ENV_WORKDIR}"
#    asus_docker_env_show_variables
#  fi
#}

#if [ $BUILD_NUMBER ]; then
#	docker run $OPTIONS $DOCKER_IMAGE chroot --userspec=$USER:$USER / /bin/bash -c "cd /source; ./build.sh -n $BUILD_NUMBER"
#fi

function asus_docker_env_main() {
  asus_docker_env_run
}
