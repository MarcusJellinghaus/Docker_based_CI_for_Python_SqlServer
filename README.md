# CI with docker containers using Jenkins, Jenkins-Agent, Python, SQL-Server

A small project to demonstrate how to use **Docker** to set up a CI infrastructure providing Jenkins, SQL-Server and a Jenkins agent with Python, ODBC etc.
The SQL-Server will be available on `127.0.0.1` with username `SA`.
The Jenkins Server will be available on `localhost:8080`.
To benefit from the Jenkins agent with Python, the agent needs to be configured in the Jenkins server. 

## First step: Building an infrastructure with docker
How to set up such a docker based CI infrastructure is explained in `Docker_based_CI_infrastructure.md`.
`jenkins_agent_python.Dockerfile` allows to build an image containing a jenkins agent with python, ODBC client, GIT client.

`First_setup.cmd` is the complete script that needs to be run to create/update the three containers.

## Second step: Using docker-compose and yml config files.
Docker Compose allows to create containers based on a a config file. How to do it is explained in `Moving_to_Docker_Compose.md`. The docker compose config file is available under `docker-compose.yml`.

`setup_compose.cmd` allows to create/update the whole stack.
