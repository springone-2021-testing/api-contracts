## Set any of these:
#### https://cloud.spring.io/spring-cloud-contract/reference/html/project-features.html#features-stub-runner-common-properties-junit-spring

## https://cloud.spring.io/spring-cloud-contract/reference/html/docker-project.html

##### PRODUCER
## Example of usage for producer written in nodejs:
#### https://cloud.spring.io/spring-cloud-contract/reference/html/docker-project.html#docker-example-of-usage

##### CONSUMER
## Example of usage for consumer to the above nodejs service
#### https://cloud.spring.io/spring-cloud-contract/reference/html/docker-project.html#docker-stubrunner-example

mkdir -p temp
cat << EOF > temp/cat-client.env
## Change these values in the shell script, not in this .env file
STUBRUNNER_MIN_PORT=10000
STUBRUNNER_MAX_PORT=10000
STUBRUNNER_CLASSIFIER=stubs
#STUBRUNNER_STUBS_MODE=CLASSPATH
STUBRUNNER_STUBS_MODE=REMOTE
#STUBRUNNER_IDS=booternetes:cat-service
STUBRUNNER_IDS=booternetes:cat-service:+:stubs:10000
#STUBRUNNER_IDS=booternetes:cat-service:1.0.1-b38-cf97e11:stubs:10000
STUBRUNNER_REPOSITORY_ROOT=https://maven.pkg.github.com/springone-2021-testcontainers/cat-service
STUBRUNNER_USERNAME=ciberkleid
# GitHub personal access token with "read packages" permission:
STUBRUNNER_PASSWORD=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
STUBRUNNER_STUBS_PER_CONSUMER=false
#STUBRUNNER_CONSUMER_NAME=""
#SERVER_PORT=8081
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=*
EOF

# Image name must be last otherwise args are not detected
docker run  --name stubrunner --rm --pull always \
            --env-file temp/cat-client.env \
            -p "8750:8750" \
            -p "10000:10000" \
            gcr.io/fe-ciberkleid/springone2021/spring-cloud-contract-stub-runner-boot:3.0.3

# Run test using:
# http :10000/cats/Toby

# Can also check:
# http :8750/actuator

#docker stop stubrunner
#rm temp/cat-client.env