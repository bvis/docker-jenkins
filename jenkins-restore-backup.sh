#!/bin/bash -e

: ${JENKINS_HOME:=/var/jenkins_home}

create_jenkins_home() {
  mkdir -p ${JENKINS_HOME}
}

is_backup_newer_than_current_home() {
  if [ ! -f "${JENKINS_HOME}/config.xml" ]; then
    echo "Config file in jenkins home not found, the directory ${JENKINS_HOME} is probably empty";
    return 0;
  fi

  last_backup=${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}

  date_jenkins_home=$(stat -c %Y ${JENKINS_HOME}/config.xml)
  date_jenkins_home_human=$(stat -c %y ${JENKINS_HOME}/config.xml)
  date_jenkins_backup=$(stat -c %Y $last_backup)
  date_jenkins_backup_human=$(stat -c %y $last_backup)

  if [ $date_jenkins_backup -gt $date_jenkins_home ]; then
    echo "Last backup (${JENKINS_LAST_BACKUP} [${date_jenkins_backup_human}]) is newer than the current home [${date_jenkins_home_human}], restore it!"
    return 0;
  else
    echo "Last backup (${JENKINS_LAST_BACKUP}) [${date_jenkins_backup_human}]) is older than the current home [${date_jenkins_home_human}], don't restore it!"
    return 1;
  fi
}

restore_backup() {
  if [ -f "${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}" ]; then
    echo "Uncompressing and copying '${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}' in ${JENKINS_HOME}..."
    set -x
    tar xzf ${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP} --directory /
    set +x
    echo "Content in backup dir '${JENKINS_HOME_BACKUP_DIR}/${JENKINS_LAST_BACKUP}' copied to home dir '${JENKINS_HOME}'"
  else
    echo "Something wrong has happened, the backup wasn't a file"
  fi
}

if [ -d "${JENKINS_HOME_BACKUP_DIR}" ] && [ "$(ls -A ${JENKINS_HOME_BACKUP_DIR})" ]; then
  echo "Backup dir found"
  JENKINS_LAST_BACKUP=$(ls -rt ${JENKINS_HOME_BACKUP_DIR} | tail -1)
  if [ ! -d "${JENKINS_HOME}" ]; then
    create_jenkins_home
    restore_backup
  else
    if [ -z "$(ls -lsA1 ${JENKINS_HOME} | grep 'total 0')" ] || is_backup_newer_than_current_home; then
      restore_backup
    fi
  fi
else
  echo "No jenkins_home backup found"
fi

ls -la ${JENKINS_HOME}
exec "/usr/local/bin/jenkins.sh"
