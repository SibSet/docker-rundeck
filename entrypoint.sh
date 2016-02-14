#!/bin/sh

set -e

INIT_FILE=/etc/rundeck.init

if [ ! -f "${INIT_FILE}" ]; then

  if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ''

    echo "Generate Rundeck public key:"
    cat /root/.ssh/id_rsa.pub
  fi

  RUNDECK_DB_URL="jdbc:mysql://$RUNDECK_DB_HOST:$RUNDECK_DB_PORT/$RUNDECK_DB_NAME?autoReconnect=true"

  sed -i 's,grails.serverURL\=.*,grails.serverURL\='${RUNDECK_SERVER_URL}',g' /rundeck/server/config/rundeck-custom.properties
  sed -i 's,dataSource.dbCreate.*,,g' /rundeck/server/config/rundeck-custom.properties
  sed -i 's,dataSource.url = .*,dataSource.url = '${RUNDECK_DB_URL}',g' /rundeck/server/config/rundeck-custom.properties

  echo "dataSource.username = ${RUNDECK_DB_USERNAME}" >> /rundeck/server/config/rundeck-custom.properties
  echo "dataSource.password = ${RUNDECK_DB_PASSWORD}" >> /rundeck/server/config/rundeck-custom.properties

  touch ${INIT_FILE}
fi

/usr/bin/java -XX:MaxPermSize=256m -Xmx1024m \
  -Dserver.http.port=4440 \
  -Dserver.http.host=0.0.0.0 \
  -Dserver.web.context=$RUNDECK_WEB_CONTEXT \
  -Drdeck.base=/rundeck \
  -Ddefault.user.name=$RUNDECK_USER_NAME \
  -Ddefault.user.password=$RUNDECK_USER_PASSWORD \
  -Drundeck.config.name=rundeck-custom.properties \
  -jar /rundeck/rundeck-launcher.jar
