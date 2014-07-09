# Trusted Docker Image for PostgreSQL

This image contains a vanilla install of the PostgreSQL database.
No users have been created for you.

## Starting the container for the first time

#### First, create the database instance & associated files

```sh
sudo mkdir /opt/pgdata
sudo docker run --name postgres_setup -d -p :5432 -v /opt/pgdata:/pgdata hopsoft/postgres:9.3
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

```
sudo docker start postgres_setup
container_ip="$(sudo docker inspect postgres_setup | grep IPAddress | cut -d '"' -f 4)"
psql -h "$container_ip" -U postgres
```

```sql
CREATE ROLE root SUPERUSER LOGIN PASSWORD 'secret';
CREATE DATABASE root OWNER root;
```

__Note__: Be sure to change the username/password to something more secure.

```
\q
sudo docker stop postgres_setup
sudo docker rm postgres_setup
```

#### Fourth, start the container for production use

```sh
sudo docker run --name postgres -d -p 5432:5432 -v /opt/pgdata:/pgdata hopsoft/postgres:9.3

# optionally run with a random host port (perhaps a little more secure)
sudo docker run --name postgres -d -p :5432 -v /opt/pgdata:/pgdata hopsoft/postgres:9.3
```

#### Fifth, modify the configuration files for production use

```sh
sudo vim /opt/pgdata/postgresql.conf

# optionally set the following
# it will tighten security by only allowing the host to connect
# listen_addresses = 'CONTAINER_IP_ADDRESS'
```

```sh
sudo vim /opt/pgdata/pg_hba.conf

# delete this line
# TYPE    DATABASE        USER            ADDRESS                 METHOD
# host    all             postgres        0.0.0.0/0               trust
#
# add one of the following line(s)... the second is more secure
# TYPE    DATABASE        USER            ADDRESS                 METHOD
# host    all             root            0.0.0.0/0               md5
# host    all             root            HOST_IP_ADDRESS/32      md5
```

```
docker restart postgres
```

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
