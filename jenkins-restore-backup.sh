#!/bin/bash -e

JENKINS_HOME=/var/jenkins_home

if [ ! -d "$JENKINS_HOME" ]; then
    mkdir -p $JENKINS_HOME
fi

if [ -d "$JENKINS_HOME_BACKUP_DIR" ] && [ "$(ls -A $JENKINS_HOME_BACKUP_DIR)" ]; then
  echo "Backup dir found"
  if [ -z "$(ls -lsA1 $JENKINS_HOME | grep -v 'total 0')" ]; then
    JENKINS_LAST_BACKUP=$(ls -1v $JENKINS_HOME_BACKUP_DIR | tail -1)
    echo "Last backup is $JENKINS_LAST_BACKUP"
    if [ -f "${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}" ]; then
        echo "Uncompressing and copying '${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}' in $JENKINS_HOME..."
        set -x
        tar xzf ${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP} --directory /
        set +x
    else
        echo "It seems that the last backup is a dir, just copying!"
        cp -r ${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}/* $JENKINS_HOME
    fi
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
