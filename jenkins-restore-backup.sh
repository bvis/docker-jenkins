#!/bin/bash -e

JENKINS_HOME=/var/jenkins_home

if [ -d "$JENKINS_HOME_BACKUP_DIR" ] && [ "$(ls -A $JENKINS_HOME_BACKUP_DIR)" ]; then
  if [ ! -d "$JENKINS_HOME" ] || [ ! "$(ls -lsA --ignore='.*' $JENKINS_HOME | grep -v 'total 0')" ]; then
    cp -r $JENKINS_HOME_BACKUP_DIR/* $JENKINS_HOME
    echo "Content in backup dir '$JENKINS_HOME_BACKUP_DIR' copied to home dir '$JENKINS_HOME'"
  else
    echo "Backup found but existing data in jenkins home won't be overwritten"
    set -ex
    ls -lsA --ignore='.*' $JENKINS_HOME
    set +ex
  fi
else
  echo "No jenkins_home backup found"
fi

exec "/usr/local/bin/jenkins.sh"
