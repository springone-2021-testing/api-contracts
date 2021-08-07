#!/usr/bin/env bash

# If updating the git tag, check the pom.xml to adjust line numbers (see script details below)
SCC_GIT_TAG=v3.0.3
DELETE_LINE_START=41
DELETE_LINE_END=47
IMAGE_REG_HOSTNAME=gcr.io
IMAGE_REG_REPONAME=fe-ciberkleid/springone2021
IMAGE_REG_USERNAME=_json_key
IMAGE_REG_PASSWORD=/Users/ciberkleid/Downloads/fe-ciberkleid-c2db4d4e8708.json

#####
# This script builds a container image for spring-cloud-contract-stub-runner-boot
#####
# This script performs the following actions:
# 1. Clone the spring-cloud-contracts project
# 2. Switch to the desired branch
# 3. Disable thin-jar configuration by removing the dependency from
#    the pom.xml for the submodule 'spring-cloud-contract-stub-runner-boot':
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

# Publish image
cat "${IMAGE_REG_PASSWORD}" | docker login -u "${IMAGE_REG_USERNAME}" --password-stdin https://"${IMAGE_REG_HOSTNAME}"
SOURCE_IMAGE="${ARTIFACT_ID}:${ARTIFACT_VERSION}"
DEST_IMAGE="${IMAGE_REG_HOSTNAME}/${IMAGE_REG_REPONAME}/${SOURCE_IMAGE}"
docker tag "${SOURCE_IMAGE}" "${DEST_IMAGE}"
docker push "${DEST_IMAGE}"
# docker logout https://"${IMAGE_REG_HOSTNAME}"

# Delete repo clone
cd ..
rm -rf tmp-spring-cloud-contract
