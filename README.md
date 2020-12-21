# CI with docker containers using Jenkins, Jenkins-Agent, Python, SQL-Server

A small project to demonstrate how to use **Docker** to set up a CI infrastructure providing Jenkins, SQL-Server and a Jenkins agent with Python, ODBC etc.
The SQL-Server will be available on `127.0.0.1` with username `SA`.
The Jenkins Server will be available on [http://localhost:8080/](http://localhost:8080/)`.
To benefit from the Jenkins agent with Python, the agent needs to be configured in the Jenkins server. 

## First step: Building an infrastructure with docker

How to set up such a docker based CI infrastructure is explained in `Docker_based_CI_infrastructure.md`.
`jenkins_agent_python.Dockerfile` allows to build an image containing a jenkins agent with python, ODBC client, GIT client.

`First_setup.cmd` is the complete script that needs to be run to create/update the three containers.

## Second step: Using docker-compose and yml config files

Docker Compose allows to create containers based on a a config file. How to do it is explained in `Moving_to_Docker_Compose.md`. The docker compose config file is available under `docker-compose.yml`.
`setup_compose.cmd` allows to create/update the whole stack.

## Third step: Installing further containers

### Analyse data with metabase

[Metabase](https://www.metabase.com/) is a tool to analyse data. It can be easily installed with docker, see `install_metabase.md`. The metabase installation is than locally available on [http://localhost:3000/](http://localhoSst:3000/).

### Installing other databases

Other databases can also be installed on docker, see `install different databases.md`.

### Fusion Metadata Registry

See `metadata_registry.md` how to install the Fusion Metadata Registry (FMR).
