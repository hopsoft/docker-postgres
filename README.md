# Trusted Docker Image for PostgreSQL

This image contains a vanilla install of the PostgreSQL database.
No users have been created for you.

## Starting the container for the first time

1. Create a directory on the __host__ to hold the `pgdata` files

    ```sh
    sudo mkdir /path/to/pgdata
    ```

1. Start & stop the container to create the `pgdata` files

    ```sh
    sudo docker run --name postgres_setup -d -p :5432 -v /path/to/pgdata:/pgdata hopsoft/postgres:9.3
    sudo docker stop postgres_setup
    ```

1. Update the config files

   Note: This config setup is insecure & temporary. We only use it to create a superuser.

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

1. Start the container & create a superuser

    ```sh
    sudo docker start postgres_setup
    container_ip="$(sudo docker inspect postgres_setup | grep IPAddress | cut -d '"' -f 4)"
    psql -h "$container_ip" -U postgres
    ```

    ```sql
    CREATE ROLE root SUPERUSER LOGIN PASSWORD 'secret';
    CREATE DATABASE root OWNER root;
    \q
    ```

   Note: Be sure to change the username/password to something more secure.

1. Stop & remove the setup container

    ```sh
    sudo docker stop postgres_setup
    sudo docker rm -v postgres_setup
    ```

1. Modify the configuration files for production use

    ```sh
    sudo vim /path/to/pgdata/postgresql.conf

    # optionally set the following
    # it will tighten security by only allowing the host to connect
    # listen_addresses = 'CONTAINER_IP_ADDRESS'
    ```

    ```sh
    sudo vim /path/to/pgdata/pg_hba.conf

    # delete this line
    # TYPE    DATABASE        USER            ADDRESS                 METHOD
    # host    all             postgres        0.0.0.0/0               trust
    #
    # add one of the following line(s)... the second is more secure
    # TYPE    DATABASE        USER            ADDRESS                 METHOD
    # host    all             root            0.0.0.0/0               md5
    # host    all             root            HOST_IP_ADDRESS/32      md5
    ```

1. Start the container for production use

    ```sh
    sudo docker run --name postgres -d -p 5432:5432 -v /opt/pgdata:/pgdata hopsoft/postgres:9.3
    ```

1. Connect to postgres

    ```
    container_ip="$(sudo docker inspect postgres | grep IPAddress | cut -d '"' -f 4)"
    psql -h "$container_ip" -U root
    \q
    ```

## Building the image

__Note__: This is only for those wanting to build the image themselves.

```
git clone https://github.com/hopsoft/docker-postgres.git
cd docker-postgres
vagrant up
sudo docker build -t hopsoft/postgres /vagrant
```

## TODO

- Add PostGIS support
