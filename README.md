# Trusted Docker Image for PostgreSQL

This image contains a basic install of [PostgreSQL](http://www.postgresql.org/)
with [contrib](http://www.postgresql.org/docs/9.3/static/contrib.html),
[PostGIS](http://postgis.net/), & [pgRouting](http://pgrouting.org/).

_No roles/users or databases have been created._

## Setup

1. Create a directory on the __host__ to hold the `pgdata` files

    ```sh
    mkdir /path/to/pgdata
    ```

1. Start & stop the container to create the `pgdata` files

    ```sh
    docker run --name pg_setup -d -p :5432 -v /path/to/pgdata:/pgdata hopsoft/postgres
    docker stop pg_setup
    ```

1. Update the config files

   _This config setup is insecure & temporary. We only use it to create a superuser._

    ```sh
    vim /path/to/pgdata/postgresql.conf

    # set the following
    # listen_addresses = '*'
    ```

    ```sh
    vim /path/to/pgdata/pg_hba.conf

    # add the following line
    # TYPE    DATABASE        USER            ADDRESS                 METHOD
    # host    all             postgres        0.0.0.0/0               trust
    ```

1. Start the container & create a superuser

    ```sh
    docker start pg_setup
    container_ip="$(docker inspect pg_setup | grep IPAddress | cut -d '"' -f 4)"
    psql -h "$container_ip" -U postgres
    ```

    ```sql
    CREATE ROLE root SUPERUSER LOGIN PASSWORD 'secret';
    CREATE DATABASE root OWNER root;
    ```

   _Be sure to change the username/password to something more secure._

1. Stop & remove the setup container

    ```sh
    docker stop pg_setup
    docker rm -v pg_setup
    ```

## Production Use

1. Modify the configuration files for production use

    ```sh
    vim /path/to/pgdata/pg_hba.conf

    # delete this line
    # TYPE    DATABASE        USER            ADDRESS                 METHOD
    # host    all             postgres        0.0.0.0/0               trust
    #
    # add one of the following line(s)... the second is more secure
    # TYPE    DATABASE        USER            ADDRESS                 METHOD
    # host    all             root            0.0.0.0/0               md5
    # host    all             root            HOST_IP_ADDRESS/32      md5
    ```

   #### Optional

    ```sh
    vim /path/to/pgdata/postgresql.conf

    # optionally set the following
    # it will tighten security by only allowing the host to connect
    # listen_addresses = 'CONTAINER_IP_ADDRESS'
    ```

1. Start the container for production use

    ```sh
    docker run --name pg --restart=always -d -p 5432:5432 -v /path/to/pgdata:/pgdata hopsoft/postgres
    ```

1. Connect to postgres

    ```sh
    container_ip="$(docker inspect pg | grep IPAddress | cut -d '"' -f 4)"
    psql -h "$container_ip" -U root
    ```

## Configuration Changes

1. Modify the configuration files

    ```sh
    vim /path/to/pgdata/postgresql.conf
    vim /path/to/pgdata/pg_hba.conf
    ```

1. Restart the container

    ```sh
    docker restart pg
    ```

## Building the Image

For those who want to build the image manually.

## Linux

```sh
git clone https://github.com/hopsoft/docker-postgres.git
cd docker-postgres
docker build -t hopsoft/postgres /vagrant
```

### OSX

```sh
git clone https://github.com/hopsoft/docker-postgres.git
cd docker-postgres
vagrant up
vagrant ssh
sudo docker build -t hopsoft/postgres /vagrant
```
