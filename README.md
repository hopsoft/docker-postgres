# Trusted Docker Image for PostgreSQL

This image contains a vanilla install of the PostgreSQL database.
No users have been created for you.

## Starting the container for the first time

#### First, create the database instance & associated files

```sh
sudo mkdir /opt/pgdata
sudo docker run --name postgres_setup -d -p :5432 -v /opt/pgdata:/pgdata hopsoft/postgres
sudo docker stop postgres_setup
```

#### Second, modify the configuration files so you can create a superuser

```sh
sudo vim /opt/pgdata/postgresql.conf

# set the following
# listen_addresses = '*'
```

```sh
sudo vim /opt/pgdata/pg_hba.conf

# add the following line
# TYPE    DATABASE        USER            ADDRESS                 METHOD
# host    all             postgres        0.0.0.0/0               trust
```

__Warning__: The above configuration allows anyone to connect as the postgres super user.

#### Third, start the container & create a superuser

```sh
sudo docker start postgres_setup
host="$(sudo docker inspect postgres_setup | grep IPAddress | cut -d '"' -f 4)"
psql -h "$host" -U postgres
```

```sql
CREATE ROLE root SUPERUSER LOGIN PASSWORD 'secret';
CREATE DATABASE root OWNER root;
```

__Note__: Be sure to change the username/password to something more secure.

```sh
\q
sudo docker stop postgres_setup
sudo docker rm postgres_setup
```

#### Fourth, modify the configuration files for production use

```sh
sudo vim /opt/pgdata/postgresql.conf

# optionally set the following... it will tighten security
# listen_addresses = 'CONTAINER_IP_ADDRESS'
```

```sh
sudo vim /opt/pgdata/pg_hba.conf

# delete this line
# TYPE    DATABASE        USER            ADDRESS                 METHOD
# host    all             postgres        0.0.0.0/0               trust
#
# add the following line(s)
# TYPE    DATABASE        USER            ADDRESS                 METHOD
# host    all             root            HOST_IP_ADDRESS/32      md5
#
# TYPE    DATABASE        USER            ADDRESS                 METHOD
# host    all             root            OTHER_IP_ADDRESS/32     md5
```

#### Fifth, start the container for production use

```sh
sudo docker run --name postgres -d -p 5432:5432 -v /opt/pgdata:/pgdata hopsoft/postgres

# optionally run with a random host port (perhaps a little more secure)
sudo docker run --name postgres -d -p :5432 -v /opt/pgdata:/pgdata hopsoft/postgres
```

```sh
host="$(sudo docker inspect postgres | grep IPAddress | cut -d '"' -f 4)"
psql -h "$host" -U root template1
\q
```

## Restarting the container

Occassionally you may need to modify the configuration & restart.
Simply make the desired config changes & restart the container.

```sh
sudo vim /opt/pgdata/postgresql.conf
sudo vim /opt/pgdata/pg_hba.conf
sudo docker restart postgres
```

## Building the image

__Note__: This is only for those wanting to build the image themselves.

```sh
git clone ?
cd docker-postgres
vagrant up
sudo docker build -t hopsoft/postgres /vagrant
```

## TODO

- Add PostGIS support
