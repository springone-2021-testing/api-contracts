#!/usr/bin/env bash

## Purpose: Local install of SpringOne Message Board Stub Jars:

## Capture this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

START_DIR=$PWD
API_CONTRACTS_HOME="${SCRIPT_DIR}/.."

function build-and-install {

  mvn clean
  mvn spring-cloud-contract:convert
  mvn spring-cloud-contract:generateStubs

  APP_GROUP_ID=$(mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout)
  APP_ARTIFACT_ID=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout)
  APP_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
  APP_COMMIT_TIME=$(git show -s --format=%ct)
  APP_COMMIT_SHA_SHORT=$(git rev-parse --short HEAD)
  APP_NEW_VERSION="${APP_VERSION}-${APP_COMMIT_TIME}-${APP_COMMIT_SHA_SHORT}"

  mvn install:install-file \
          -DartifactId="${APP_ARTIFACT_ID}" \
          -Dclassifier=stubs \
          -Dfile=target/"${APP_ARTIFACT_ID}-${APP_VERSION}"-stubs.jar \
          -DgeneratePom=true \
          -DgroupId="${APP_GROUP_ID}" \
          -Dpackaging=jar \
          -Dversion="${APP_NEW_VERSION}"

}

## Client:
echo -e "\n\n ##### Generate and install client stubs #####"
cd "${API_CONTRACTS_HOME}"/springone-message-board-service/springone-message-board-client
build-and-install

## Admin:
echo -e "\n\n ##### Generate and install admin stubs #####"
cd "${API_CONTRACTS_HOME}"/springone-message-board-service/springone-message-board-admin
build-and-install

cd "${START_DIR}"

## Results:
echo -e "\n\n ##### Local stubs #####"
tree ~/.m2/repository/springone/message-board-*-contracts
