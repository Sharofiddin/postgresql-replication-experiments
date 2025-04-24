#!/bin/bash
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "First time running. Init configuration."
    until ping -c 1 -W 1 primary
    do
      echo "Waiting for leader to ping..."
      sleep 1s
    done
    cd $PGDATA
    su postgres
    until pg_basebackup  -h primary -p 5432 -D . -U replicator -P -v -R -X stream -S ${SLOT_NAME}
    do
      echo "Waiting for pg_basebackup..."
      sleep 1s
    done
    chmod -R 0700 $PGDATA
    chown -R postgres:postgres $PGDATA
fi
su postgres -c "postgres"
