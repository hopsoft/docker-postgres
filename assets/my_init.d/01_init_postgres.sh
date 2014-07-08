#!/bin/bash

datadir=/pgdata

if [[ ! -d /pgdata ]]; then
  mkdir /pgdata
fi

if [[ -z "$(ls -A /pgdata)" ]]; then
  chown -R postgres:postgres /pgdata
  su postgres -c "/usr/lib/postgresql/9.3/bin/initdb --encoding=UTF-8 --local=en_US.UTF-8 -D /pgdata"
fi

chown -R postgres:postgres /pgdata
