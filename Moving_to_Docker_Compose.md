# Moving to Docker Compose

## Introduction

Docker Compose allows to create containers from a config file. Ie instead of executing a shell script that includes all details for the different containers, the details can be defined in a docker-compose.yml file.
Docker Compose has a good [documentation](https://docs.docker.com/compose/).
Within Docker compose, it is possible to have several instances of a container. These scaled containers are called services.

## Installing Docker Compose

Docker Compose comes with Docker Desktop for Windows. So it should be already there.

## docker-compose API

- `docker-compose up`       - start services
  - `-d`/`--detached`       - in detached mode
  - `--build`               - Build images before starting services
- `docker-compose ps`         - get list of services
- `docker-compose run [services] env` - see environment variables
- `docker-compose stop`     - stop the services
- `docker-compose down`     - stop and remove services
- `docker-compose down --volumes` - also deletes the volumes
- `docker-compose exec [options] [service] {commands}` - allows to execute commands on a container/service, similar to `docker exec`. Options include `-u, --user [USER]`. Commands like `sh` or `bash` are by default allocated to a TTY.

- Further information: [Full list of docker compose commands](https://docs.docker.com/compose/reference/)
- Example script to start the containers:

```cmd
REM Start in the same folder as the docker-compose.yml file.
docker-compose up -d --build
docker-compose ps
```

## A first compose file

*The Compose file is a YAML file defining services, networks and volumes. The default path for a Compose file is ./docker-compose.yml.*
[...]
*A service definition contains configuration that is applied to each container started for that service, much like passing command-line parameters to docker run. Likewise, network and volume definitions are analogous to docker network create and docker volume create.*

See `docker-compose.yml` for an example of a compose file, its content corresponds to the `First_setup.cmd` script. `setup_compose.cmd` starts the services using the yml file.
Documentation of compose files is available [online](https://docs.docker.com/compose/compose-file/).

The main structure of a compose file consists of three parts:
- services
- volumes
- networks

### Services
Most of the properties are probably self-explanatory, including the `container_name`, `hostname`, `ports`, `volumes`, `networks`.

One option is to define the `image`. Alternatively, the dockerfile can be defined with:

```cmd
    build:
      context: .
      dockerfile: [filename.extension]
```

Environment variables can be defined with

```cmd
    environment:
      - "Variable1=Value1"
      - "Variable2=Value2"
```

The environment variable `TZ` allows to define the time zone, eg `- "TZ=Europe/Zurich"`. Different options for the time zone can be found with linux command `tzselect`.

The attribute `depends_on` allows to define dependencies between containers
The option `restart: always` allows to restart a container in case it crashes. This is also useful if a related container is not available at the first start. 
The option `init: true` corresponds to `--init` option of `docker run`.

Not all parameters of `docker run` are available in a `docker-compose.yml` file. Eg the memory limitation (`docker run --memory`) is only available with the *[...] resources key under deploy. deploy configuration only takes effect when using docker stack deploy, and is ignored by docker-compose.* [(Source](https://docs.docker.com/compose/compose-file/compose-versioning/#upgrading)).

### Networks
All networks referenced by services need to be listed in this section.
A simple example:

```
networks:
  container_net:
```

### Volumes
All volumes referenced by services need to be listed in this section.

Usually, docker compose creates new volumes called [projectname]_[volumename].
The option `external: true` allows to use existing volumes that follow different naming convention. In case the volumes do not yet exist, `docker compose up` raises an error.

## Further concepts

Docker Compose uses a **project** name to isolate environments from each other ([Source](https://docs.docker.com/compose/#multiple-isolated-environments-on-a-single-host)).

Docker offers Docker Swarm:

- [Docker Swarm](https://docs.docker.com/get-started/swarm-deploy/) *provides many tools for scaling, networking, securing and maintaining your containerized applications, above and beyond the abilities of containers themselves.*
- **Services**: Docker Swarm does not create individual containers. Instead, it creates *services*, which are scalable groups of containers. They are configured in *Stack YAML files*.

Docker Desktop also works with a second orchestrator: [Kubernetes](https://docs.docker.com/get-started/kube-deploy/).
