# api-contracts

This repo contains API contracts for use with Spring Cloud Contract producers and consumers.

### Install stubs locally
A script is included for installing stubs into your local maven repository (~/.m2/repository).
The script will list all projects in this repo and prompt you to select the one for which you want to build and install stubs.
```shell
git clone git@github.com:springone-2021-testcontainers/api-contracts.git
cd api-contracts
source bin/install-stubs-to-local-maven-repo.sh
```

### Use stubs in artifact repository
This repo also contains GitHub Actions that automatically publish stubs to repsy.io. You can find the stubs here:

[https://repo.repsy.io/mvn/ciberkleid/public](https://repo.repsy.io/mvn/ciberkleid/public)
