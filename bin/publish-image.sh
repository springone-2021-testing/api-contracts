#!/usr/bin/env bash

### Purpose: This script publishes a container image to the registry specified below

### Configuration: change the following values as needed
IMAGE_REG_HOSTNAME=gcr.io
IMAGE_REG_REPONAME=fe-ciberkleid/springone2021
IMAGE_REG_USERNAME=_json_key
IMAGE_REG_PASSWORD=/Users/ciberkleid/Downloads/fe-ciberkleid-c2db4d4e8708.json

### DO NOT MAKE CHANGES BELOW THIS LINE

SOURCE_IMAGE="${1}"

RED='\033[0;31m'
NC='\033[0m' # No Color
USAGE="
USAGE:  publish-image.sh <image-name>
ARGS:   --> image-name: name of the image to be published
"

if [[ -z "${SOURCE_IMAGE}" ]]; then
  echo -e "${RED}ERROR: Image name not provided.${NC}"
  echo "${USAGE}"
  return
fi

# Log in to image registry
cat "${IMAGE_REG_PASSWORD}" | docker login -u "${IMAGE_REG_USERNAME}" --password-stdin https://"${IMAGE_REG_HOSTNAME}"

# Publish image
TARGET_IMAGE="${IMAGE_REG_HOSTNAME}/${IMAGE_REG_REPONAME}/${SOURCE_IMAGE}"
docker tag "${SOURCE_IMAGE}" "${TARGET_IMAGE}"
docker push "${TARGET_IMAGE}"

# Publish image as "latest"
TARGET_IMAGE_LATEST="${TARGET_IMAGE%:*}:latest"
if [[ "${TARGET_IMAGE_LATEST}" != "${TARGET_IMAGE}" ]]; then
  docker tag "${SOURCE_IMAGE}" "${TARGET_IMAGE_LATEST}"
  docker push "${TARGET_IMAGE_LATEST}"
fi

# Log out of image registry
# docker logout https://"${IMAGE_REG_HOSTNAME}"
