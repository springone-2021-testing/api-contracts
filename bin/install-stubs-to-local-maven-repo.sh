#!/usr/bin/env bash

## Purpose: This script installs stub jar files to the local maven repository:

## Capture this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

START_DIR=$PWD
API_CONTRACTS_HOME="${SCRIPT_DIR}/.."

function build-and-install {

  mvn clean spring-cloud-contract:convert spring-cloud-contract:generateStubs

  APP_GROUP_ID=$(mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout)
  APP_ARTIFACT_ID=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout)
  APP_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
  APP_COMMIT_TIME=$(git show -s --format=%ct)
  APP_COMMIT_SHA_SHORT=$(git rev-parse --short HEAD)
  if [[ "${APP_VERSION}" == *-SNAPSHOT ]]; then
    APP_NEW_VERSION="${APP_VERSION}-${APP_COMMIT_TIME}-${APP_COMMIT_SHA_SHORT}"
  else
    APP_NEW_VERSION="${APP_VERSION}"
  fi

  mvn install:install-file \
          -DartifactId="${APP_ARTIFACT_ID}" \
          -Dclassifier=stubs \
          -Dfile=target/"${APP_ARTIFACT_ID}-${APP_VERSION}"-stubs.jar \
          -DgeneratePom=true \
          -DgroupId="${APP_GROUP_ID}" \
          -Dpackaging=jar \
          -Dversion="${APP_NEW_VERSION}"

  echo -e "\n##### Installed local stubs #####"
  # Print directory name
  repoPath=$(echo ${APP_GROUP_ID} | sed -r 's/(\s?\.){1}/\//g')
  ls -d ~/.m2/repository/${repoPath}/${APP_ARTIFACT_ID}/${APP_NEW_VERSION}
  # Print file names
  ls -goth ~/.m2/repository/${repoPath}/${APP_ARTIFACT_ID}/${APP_NEW_VERSION}
  echo

}

## Get list of directories that contain a pom.xml file
projectArray=()
while IFS= read -rd '' pomFile; do
  projectArray+=( $(dirname "$pomFile") )
done < <(find "${API_CONTRACTS_HOME}" -type f -name pom.xml -not -path "${API_CONTRACTS_HOME}/.github/*" -not -path "${API_CONTRACTS_HOME}/bin/*" -not -path "${API_CONTRACTS_HOME}/*/target/*" -print0)
printf 'Found %s pom.xml files\n' "${#projectArray[@]}"

if [ "${#projectArray[@]}" -gt 0 ]; then
  ## Prompt user to choose an available project
  echo 'Please select a project:'
  for i in "${!projectArray[@]}"; do
    # Get path relative to api-contracts repo home
    projectDir=$(realpath --relative-to="${API_CONTRACTS_HOME}" "${projectArray[$i]}")
    printf "[%s] %s\n" "${i}" "${projectDir}"
  done

  printf 'Enter your choice (0 to %s): ' "$i"
  read -r choice
  choice=$(printf '%s\n' "$choice" | tr -dc '[:digit:]')
  if [[ "$choice" != "" ]] && [[ "$choice" -ge 0 ]] && [[ "$choice" -le "$i" ]]; then
    ## Print confirmation of choice using relative path
    choiceProjectRelDir=$(realpath --relative-to="${API_CONTRACTS_HOME}" "${projectArray[$choice]}")
    echo "Selected project is ${choiceProjectRelDir}"

    ## Build and install stubs to local maven repo
    echo -e "\n##### Generate and install stubs [${choiceProjectRelDir}] #####"
    cd "${projectArray[$choice]}"
    build-and-install
    cd "${START_DIR}"
  else
    # User selected an invalid option
    echo >&2 'ERROR: Invalid selection'
  fi
else
  # No pom.xml files found
  echo >&2 'ERROR: No projects found'
fi
