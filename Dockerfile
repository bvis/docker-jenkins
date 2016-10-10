FROM jenkinsci/jenkins:2.23

MAINTAINER Basilio Vera <basilio.vera@softonic.com>

ENV "DOCKER_COMPOSE_VERSION=1.8.1" \
    "JENKINS_HOME_BACKUP_DIR=/backup/jenkins_home"

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
COPY jenkins-restore-backup.sh /usr/local/bin/jenkins-restore-backup.sh
#RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt \
#    && echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

# Auto-health check to the root page. We add such high values because of a bug when Docker is starting the service, for Jenkins these could be acceptable.
#HEALTHCHECK --interval=60s --timeout=5s --retries=3 \
#  CMD curl -f -A "Docker-HealthCheck/v.x (https://docs.docker.com/engine/reference/builder/#healthcheck)" http://localhost:8080/ || exit 1

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins-restore-backup.sh"]
