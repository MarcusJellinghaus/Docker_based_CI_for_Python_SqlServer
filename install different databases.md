# install different databases

## mariadb

Basic call to run maria db:
```
docker run --name some-mariadb -e MYSQL_ROOT_PASSWORD=my-secret-pw12$ -d mariadb:latest
```

Also with port and volume:
```
docker run --name some-mariadb -h some-mariadb -p 3306:3306 --volume maria_db_volume:/var/lib/mysql --network=container_net -e MYSQL_ROOT_PASSWORD=my-secret-pw12$ -d mariadb:latest
```

## Postgres

Basic call to run Postgres db:

```PS
docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword-13 -d postgres
```

See also at [https://hub.docker.com/_/postgres](https://hub.docker.com/_/postgres).

Also with port and volume:

```PS
docker volume create postgres_volume

docker run --name some-postgres -h some-postgres -p 5432:5432 --volume postgres_volume:/var/lib/postgresql/data --network=container_net -e POSTGRES_PASSWORD=mysecretpassword-13 -d postgres:latest
```

## sqllite

sqlite is a file based database available with python. A database can be created with the python script `sqlite.py`.

## Cockroach DB

[Cockroach DB](https://hub.docker.com/r/cockroachdb/cockroach) is a scalable database.

### First setup

This setup creates three containers, each with its own volume, also see [there](https://www.cockroachlabs.com/docs/stable/start-a-local-cluster-in-docker-mac.html)

Get the latest image:

```PS
docker pull cockroachdb/cockroach:latest
```

Create three volumes:

```PS
docker volume create cockroach_db_volume_1
docker volume create cockroach_db_volume_2
docker volume create cockroach_db_volume_3
```

Define three containers:

```PS
docker run -d `
--name=roach1 `
--hostname=roach1 `
--net=container_net `
-p 26257:26257 -p 8099:8080  `
-v cockroach_db_volume_1:/cockroach/cockroach-data  `
cockroachdb/cockroach:latest start `
--insecure `
--join=roach1,roach2,roach3

docker run -d `
--name=roach2 `
--hostname=roach2 `
--net=container_net `
-v cockroach_db_volume_2:/cockroach/cockroach-data  `
cockroachdb/cockroach:latest start `
--insecure `
--join=roach1,roach2,roach3

docker run -d `
--name=roach3 `
--hostname=roach3 `
--net=container_net `
-v cockroach_db_volume_3:/cockroach/cockroach-data  `
cockroachdb/cockroach:latest start `
--insecure `
--join=roach1,roach2,roach3
```

Start all three containers:

```PS
docker exec -it roach1 ./cockroach init --insecure
```

TODO: Password

### Using from Python

Also see https://www.cockroachlabs.com/docs/v20.2/build-a-python-app-with-cockroachdb.html

## Accessing the databases

The different databases can be accessed with DBeaver, a database client.