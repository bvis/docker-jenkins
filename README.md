# Softonic Jenkins

[![](https://images.microbadger.com/badges/version/basi/jenkins.svg)](https://microbadger.com/images/basi/jenkins "basi/jenkins")

This image is designed to allow the execution of any job that contains a _dockerized_ environment.

## Container execution

If you launch it with this command you'll get a working Jenkins server with the host docker injected.

```
docker run --name softonic-jenkins \
    -u root \
    -d -p 8080:8080 -p 50000:50000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(which docker):/usr/bin/docker \
    -v /var/jenkins_home:/var/jenkins_home basi/jenkins \
    --restart unless-stopped
```


```
docker run --rm --name softonic-jenkins \
    -u root \
    -p 8080:8080 -p 50000:50000 \
    -v jenkins-backup:/backup/jenkins_home \
    basi/jenkins

```

This image can restore a jenkins home backup if you mount a valid directory under the `$JENKINS_HOME_BACKUP_DIR` variable.
Internally it will search for this directory, if it exists in the container and the `/var/jenkins_home` is empty it will copy the content of the last subdirectory found of `$JENKINS_HOME_BACKUP_DIR` in `/var/jenkins_home`.

When can this be useful? When you want not to affect performance to the jenkins process mounting a remote volume but you want to ensure that your content will have a backup.
Of course this works restoring a backup but for update the backup content you need to do something else, for example you can create a silly job that just copies the content from $JENKINS_HOME to $JENKINS_HOME_BACKUP_DIR.

## Usage

As this image contains *docker-compose* you can execute complex tests with easy commands.

For example, imagine that your project is PHP based and you are using Composer (nowadays almost all PHP projects use it).
And you define a target to execute your unit tests named "tests-build".
This target executes your PHPUnit tests and generate a JUnit compatible output in the "build/logs" directory
of your workspace.

It would allow to the Jenkins server to get these results and use them to check if the build is successful if you define this directory as a volume. This can be achieved if the *docker-compose.build.yml* file has this definition:

```
version: "2"

services:
  web:
    volumes:
      - ./build/logs:/var/www/project/build/logs
```

When you execute these commands:

```
COMPOSER_COMMAND="/usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.build.yml"
$COMPOSER_COMMAND build
$COMPOSER_COMMAND up -d
$COMPOSER_COMMAND exec -T web composer install
$COMPOSER_COMMAND exec -T web composer tests-build
$COMPOSER_COMMAND exec -T web composer tests-int-build
$COMPOSER_COMMAND down
```

The docker client will build your project, make it run with the definitions provided in the merged compose definition and execute the targets defined in the composer file.

In this example I finally execute integration tests based on behat that are generating JUnit output as well, once it's finished the projects is removed.

After this you need to use the JUnit generated files in the project workspace as usual.
