#!/usr/bin/env bash

### Purpose: This script builds a container image for spring-cloud-contract-stub-runner-boot

### Configuration: change the following values as needed
# If updating the git tag, check/adjust line number settings (see script details below)
SCC_GIT_TAG=v3.0.3
DELETE_LINE_START=41
DELETE_LINE_END=47

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
# 4. Build image using Spring Boot maven plugin (spring-boot:build-image)
# 5. Publish image to image registry
###

## Capture this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Clone spring-cloud-contract and switch to proper tag
rm -rf tmp-spring-cloud-contract &&
  git clone https://github.com/spring-cloud/spring-cloud-contract.git tmp-spring-cloud-contract &&
  cd tmp-spring-cloud-contract &&
  git checkout "${SCC_GIT_TAG}"

# Disable thin-jar (remove dependency from pom.xml)
cd spring-cloud-contract-stub-runner-boot
mv pom.xml pom.xml.backup
sed "${DELETE_LINE_START},${DELETE_LINE_END}d" pom.xml.backup >pom.xml
ARTIFACT_ID=$(mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.artifactId -q -DforceStdout)
ARTIFACT_VERSION=$(mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.version -q -DforceStdout)
cd ..

# Build image
# Image name will be auto-generated as "${ARTIFACT_ID}:${ARTIFACT_VERSION}"
./mvnw clean spring-boot:build-image -pl spring-cloud-contract-stub-runner-boot

# Delete repo clone
cd ..
rm -rf tmp-spring-cloud-contract

## Publish image
source "${SCRIPT_DIR}"/publish-image.sh "${ARTIFACT_ID}:${ARTIFACT_VERSION}"
