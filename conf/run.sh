#!/bin/bash

chown -R postgres:postgres /pgdata
rm /pgdata/postmaster.pid
su postgres -c "/usr/lib/postgresql/9.3/bin/postgres -D /pgdata"
