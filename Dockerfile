FROM jenkinsci/jenkins:2.11

MAINTAINER Basilio Vera <basilio.vera@softonic.com>

ENV DOCKER_COMPOSE_VERSION 1.8.0-rc1

# if we want to install via apt
USER root

# Install dependencies
RUN apt-get update \
      && apt-get install -y sudo \
      && rm -rf /var/lib/apt/lists/* \
      && curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
      && chmod +x /usr/local/bin/docker-compose \
# Jenkins user can execute Docker
      && echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
