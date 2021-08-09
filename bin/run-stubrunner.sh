#!/usr/bin/env bash

### Purpose: This script starts a stubrunner container and loads the specified stubs on port 10000

## Capture this script's location and current dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
START_DIR="${PWD}"

## Prompt user to choose an available project
echo 'Please select a project'
n=0
for project in "${SCRIPT_DIR}"/../*; do
  if [[ -d "${project}" && ! ""${project}"" =~ ^(.*/bin|.*/temp|.*/wip)$ ]]; then
    n=$((n+1))
    printf "[%s] %s\n" "$n" "${project##*/}"
    eval "project${n}=\$project"
  fi
done

if [ "$n" -eq 0 ]; then
    echo >&2 No projects found.
    return
fi

printf 'Enter your choice (1 to %s): ' "$n"
read -r num
num=$(printf '%s\n' "$num" | tr -dc '[:digit:]')
if [[ "$num" == "" ]] || [ "$num" -le 0 ] || [ "$num" -gt "$n" ]; then
    echo >&2 Invalid selection
    return 1
fi


eval "project=\$project${num}"
echo "Selected project is ${project##*/}"
echo "Stubrunner will start as a container in the foreground"
echo "Tomcat will start on port 8750"
echo "Your stub(s) will be exposed on port 10000 (use http :10000/<api-endpoint> to test)"

## Extract stubrunner coordinates from project pom.xml
cd "${project}"
GROUP_ID=$(mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.groupId -q -DforceStdout)
ARTIFACT_ID=$(mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.artifactId -q -DforceStdout)
cd "${START_DIR}"
STUBRUNNER_IDS=${GROUP_ID}:${ARTIFACT_ID}
echo "STUBRUNNER_IDS=${STUBRUNNER_IDS}"

## Start stubrunner as docker container with stubs on port 10000

## Set any of these:
## https://cloud.spring.io/spring-cloud-contract/reference/html/project-features.html#features-stub-runner-common-properties-junit-spring

# Image name must be last otherwise args are not detected
docker run  --name stubrunner --rm --pull always \
            -e STUBRUNNER_MIN_PORT=10000 \
            -e STUBRUNNER_MAX_PORT=10000 \
            -e STUBRUNNER_STUBS_MODE=REMOTE \
            -e STUBRUNNER_IDS=${STUBRUNNER_IDS}:+:stubs:10000 \
            -e STUBRUNNER_REPOSITORY_ROOT=https://repo.repsy.io/mvn/ciberkleid/public \
            -e MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=* \
            -p "8750:8750" \
            -p "10000:10000" \
            gcr.io/fe-ciberkleid/springone2021/spring-cloud-contract-stub-runner-boot:latest

# Run test using:
# http :10000/<your-api-endpoints>

# Can also check:
# http :8750/actuator

#docker stop stubrunner
