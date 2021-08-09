#!/usr/bin/env bash

### Purpose: This script builds and publishes a container image for spring-cloud-contract-stub-runner-boot

### Build Image Configuration: change the following values as needed
# If updating the git tag, check/adjust line number settings (see script details below)
SCC_GIT_TAG=v3.0.3
DELETE_LINE_START=41
DELETE_LINE_END=47

### Publish Image Configuration: Set the following env vars in your terminal session to overwrite the default values
IMAGE_REG_HOSTNAME="${IMAGE_REG_HOSTNAME:-gcr.io}"
IMAGE_REG_REPONAME="${IMAGE_REG_REPONAME:-fe-ciberkleid/springone2021}"
IMAGE_REG_USERNAME="${IMAGE_REG_USERNAME:-_json_key}"
IMAGE_REG_PASSWORD="${IMAGE_REG_PASSWORD:-/Users/ciberkleid/Downloads/fe-ciberkleid-c2db4d4e8708.json}"

### DO NOT MAKE CHANGES BELOW THIS LINE

### Script details:
# This script performs the following actions:
# 1. Clone the spring-cloud-contracts project
# 2. Switch to the desired branch
# 3. Disable thin-jar configuration by removing the dependency from
#    the pom.xml for submodule 'spring-cloud-contract-stub-runner-boot':
#                <plugin>
#                  <groupId>org.springframework.boot</groupId>
#                  <artifactId>spring-boot-maven-plugin</artifactId>
#                  <configuration>
#                    <executable>true</executable>
#                  </configuration>
#                  <dependencies>       <-------------------- Set line number as env var DELETE_LINE_START
#                    <dependency>
#                      <groupId>org.springframework.boot.experimental</groupId>
#                      <artifactId>spring-boot-thin-layout</artifactId>
#                      <version>${thin-jar.version}</version>
#                    </dependency>
#                  </dependencies>        <-------------------- Set line number as env var DELETE_LINE_END
#                </plugin>
# 4. Add actuator dependency to pom.xml
# 5. Build image using Spring Boot maven plugin (spring-boot:build-image)
# 6. Publish image to image registry
###

## Capture this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Clone spring-cloud-contract and switch to proper tag
rm -rf temp/spring-cloud-contract &&
  git clone https://github.com/spring-cloud/spring-cloud-contract.git temp/spring-cloud-contract &&
  cd temp/spring-cloud-contract &&
  git checkout "${SCC_GIT_TAG}"

# Start editing module pom.xml
cd spring-cloud-contract-stub-runner-boot
cp pom.xml pom.xml.backup
# Remove thin-jar plugin dependency; add actuator dependency
ex pom.xml <<EOF
:${DELETE_LINE_START},${DELETE_LINE_END}d
/<dependencies>/ put ='        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>'
wq
EOF
# Get artifact id and version (used in image name)
ARTIFACT_ID=$(mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.artifactId -q -DforceStdout)
ARTIFACT_VERSION=$(mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.version -q -DforceStdout)
# Finished editing module pom.xml
cd ..

# Build image
# Image name will be auto-generated as "${ARTIFACT_ID}:${ARTIFACT_VERSION}"
./mvnw clean spring-boot:build-image -pl spring-cloud-contract-stub-runner-boot

# Delete repo clone
cd ../..
#rm -rf temp/spring-cloud-contract

## Publish image
SOURCE_IMAGE="${ARTIFACT_ID}:${ARTIFACT_VERSION}"

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

echo; echo "Successfully built and published image:"
docker images ${IMAGE_REG_HOSTNAME}/${IMAGE_REG_REPONAME}/${ARTIFACT_ID}
echo

# Log out of image registry
# docker logout https://"${IMAGE_REG_HOSTNAME}"
