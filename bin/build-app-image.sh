#!/bin/bash

### Purpose: This script builds an image using "pack." For Java Maven applications, it enables
###          tests during the build (sets mvn command to "package") and provides buildpacks
###          access to the host Docker daemon, enabling the use of testcontainers.
###          Testcontainers can be used to instantiate any image as a separate container
###          (e.g. databases, stubrunner, etc...)

SOURCE_PATH="${1}"
IMAGE_NAME="${2}"

RED='\033[0;31m'
NC='\033[0m' # No Color
USAGE="
USAGE:  build-app-image.sh <source-path> <image-name>
ARGS:   --> source-path: path to the source code/artifact
        --> image-name: name for the image to be built
EXAMPLES:
        build-app-image.sh . my-app
        build-app-image.sh ~/workspace/my-app my-app:1.0.0
        build-app-image.sh target/my-app-1.0.0.jar my-app:1.0.0
"

if [[ -z "${SOURCE_PATH}" || -z "${IMAGE_NAME}" ]]; then
  echo -e "${RED}ERROR: Source code path and/or image name not provided.${NC}"
  echo "${USAGE}"
  return
fi

if [[ ! -d "${SOURCE_PATH}" || ! -f "${SOURCE_PATH}" ]]; then
  echo -e "${RED}ERROR: Source path is not a valid file or directory. [path=${SOURCE_PATH}]${NC}"
  echo "${USAGE}"
  return
fi

## Capture this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

## Enable access from buildpacks to host Docker daemon
if [[ -z ${DOCKER_HOST_IP} ]]; then
  read -p "Enter Docker host IP: " DOCKER_HOST_IP
fi

#brew install socat
socat TCP-LISTEN:2375,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock &
## verify with:
#telnet ${DOCKER_HOST_IP} 2375

## Build image, with testing enabled
pack build "${IMAGE_NAME}" \
  -e BP_MAVEN_BUILD_ARGUMENTS='package' \
  -e DOCKER_HOST=tcp://${DOCKER_HOST_IP}:2375

pkill socat

## Publish image
## COMMENT OUT - App images will be published to ghcr.io by GitHub Actions
#source "${SCRIPT_DIR}"/publish-image.sh "${IMAGE_NAME}"
