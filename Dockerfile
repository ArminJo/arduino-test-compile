# Container image that runs your code
FROM ubuntu:latest

# Install wget
RUN apt-get update --quiet=2 > /dev/null && apt-get install --quiet=2 --assume-yes wget > /dev/null
CMD /bin/bash

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
