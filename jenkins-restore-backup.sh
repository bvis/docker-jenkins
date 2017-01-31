#!/bin/bash -e

JENKINS_HOME=/var/jenkins_home

if [ ! -d "$JENKINS_HOME" ]; then
    mkdir -p $JENKINS_HOME
fi

if [ -d "$JENKINS_HOME_BACKUP_DIR" ] && [ "$(ls -A $JENKINS_HOME_BACKUP_DIR)" ]; then
  if [ -z "$(ls -lsA --ignore='.*' $JENKINS_HOME | grep -v 'total 0')" ]; then
    JENKINS_LAST_BACKUP=$(ls -1v $JENKINS_HOME_BACKUP_DIR | tail -1)
    cp -r ${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}/* $JENKINS_HOME
    echo "Content in backup dir '${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}' copied to home dir '$JENKINS_HOME'"
  else
    echo "Backup found but existing data in jenkins home won't be overwritten"
    set -ex
    ls -lsA --ignore='.*' $JENKINS_HOME | grep -v 'total 0'
    set +ex
  fi
else
  echo "No jenkins_home backup found"
fi

exec "/usr/local/bin/jenkins.sh"
