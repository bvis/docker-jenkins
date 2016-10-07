#!/bin/bash -e

JENKINS_HOME=/var/jenkins_home

if [ -d "$JENKINS_HOME_BACKUP_DIR" ] && [ "$(ls -A $JENKINS_HOME_BACKUP_DIR)" ]; then
    if [ ! -d "$JENKINS_HOME" ] || [ ! "$(ls -A $JENKINS_HOME)" ]; then
      cp -r $JENKINS_HOME_BACKUP_DIR/* $JENKINS_HOME
      echo "Content in backup dir '$JENKINS_HOME_BACKUP_DIR' copied to home dir '$JENKINS_HOME'"
    fi
fi

exec "/usr/local/bin/jenkins.sh"
