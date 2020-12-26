# CI with docker containers using Jenkins, Jenkins-Agent, Python, SQL-Server

[[TOC]]

## Introduction
Image a software development project based on Python and an external GIT server like GitHub. For continouos integration, you might run a CI server like Jenkins. An additional worker node might be used to execute the Jenkins projects.
To store data in a database, eg Microsoft SQL-Server might be used. Last but not least, you might be interested in inserting files into SQL-Server from a file share.
Instead of replicating such an infrastructure with servers, docker allows to spin up a few contain containers on a developer machine. Below find the details of such a mini-project.

## Getting started with Docker

### Install Docker Desktop

[Download](https://docs.docker.com/docker-for-windows/install/) and install Docker Desktop. If you use winget, just type `winget install docker` to install docker. Ensure that your PC works which Docker. ( Turn on WSL, check Hyper-V, turn on virtualisation in system BIOS).

### Basic docker concepts

Docker allows for the simple installation of standardized "mini-servers" on a machine. This "mini-servers" are called **containers**. A container follows a certain blueprint, called **image**. There is a central web page to find images - [https://hub.docker.com/](https://hub.docker.com/).

Data should be stored in **volumes**. These allow for persistent storage of information, while data inside a **container** would disappear with the next update of a container from a newer image. Containers can be linked to volumes. **volumes** can also be shared between docker **containers**.

### Docker API examples

Docker has a powerful API. Just type ```docker command [parameters]```. Commands include:

- `search [searchterm]`       - to search images on hub.docker.com and display the results in the console.
- `pull [imagename]`          - to download images
- `run [imagename]`           - creates a container from an imagine and runs it. Additional parameters include:
  - `--memory="4m"/"1g"`      - sets the memory limit
  - `-p 1234:1234`            - expose a port externally, parameter can be used several times to export several ports
  - `-v [volumename]:[/unix_folder_in_container]`         - bind a volume to the container
  - `--name [containername]`  - defines the container name
  - `--hostname [hostname]`   - defines the host name, visible on the container with the hostname command
  - `-d`                      - runs a container in detached mode, i.e. console is ready for next command
  - `-e "variablename=value"` - set any environment variable
  - `--network=[networkname]`- to assign the container to a certain network
- `stop [containername]`      - to stop a container
- `rm [containername]`        - to delete a container (careful - manual configuration needs to be done again if not stored in a named volume)
- `ps -a`                     - gives an overview of currently running containers
- `logs [containername]`      - shows the log of a server
- `exec -it [containername] [interactiveshell] {commands}` - executes commands on an interactive shell
- `exec -u root -it [containername] [interactiveshell] {commands}` - executes commands on an interactive shell as root
- `inspect [containername]`    - get info on a container, including the ip address
- `volume`                   - allows to manage volumes
  - `create [volume_name]`    - creates a docker volume
  - `rm [volume_name]`       - deletes a docker volume
  - `ls`                      - lists all docker volumes
  - `prune`                   - remove all unused volumes
  - `inspect [volume_name]`   - lists all details of the specified volume

### First ideas on best practices

If container, their host names, the volumes etc. are not specified, it is not an issue. Docker will generate these by itself.

#### Container / service name

To better understand what is going on, it is useful to assign container names. Using the same name as hostname allows to see this name also from inside the container. When using a network, these names can be also used (instead of IP addresses).

- The name of the service is used over the network.
- The hostname is used on the container by the hostname command.
- The name/containername is used by the docker GUI.

In a dockerfile, it looks like this.

```YML
services:
  sql1:
    container_name: sql1
    hostname: sql1
```

#### Volume names

Named volumes allow to reuse volumes and their data when recreating / updating a container.

Explicit names also allow for easier analysis of unexpected behaviour.

### Windows Subsystem for Linux (WSL)
Docker uses the Windows Subsystem for Linux (WSL). This allows to run Linux on Windows.
The file system is available in Windows explorer under `\\wsl$`.
Docker installs 2 folders there: `docker-desktop` and `\\wsl$\docker-desktop-data`.
The location of volumes is there: `\\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes`.

### Install a docker network

The different docker containers get an IP address and one or several ports.
By default, they are on a standard [bridge network](https://docs.docker.com/network/bridge/).
Ports are exposed when with parameter "-p" when executing "docker run".
IP addresses can be seen with `docker network inspect [network_name]`

A separate network can be created with

```PS
docker network create [network_name]
```

e.g. `docker network create container_net`

A container can be assigned to a network with `docker run --network [networkname]`. Then, the hostname can be used for accessing the machine.

By using the `run` command with the option `-p`, port(s) of the relevant docker container(s) get exposed externally, so that they are visible to other containers on the same network, to the host machine and also to other machines. With the expose command, it is possible to control whether ports should be visible to other machines, see also [there](https://www.whitesourcesoftware.com/free-developer-tools/blog/docker-expose-port/).


### Getting information from a docker container

- To connect to the container console, type `docker exec -it [containername] bash`
  - To run as root, use `docker exec -it --user root [containername] bash`
  - To execute a command on a container, type `docker exec [containername] [command]`
- On the container console, some information is available:
  - On the system: `uname -a`
  - On the linux distribution: `cat /etc/*-release | grep "PRETTY_NAME="`

### Scripts to read docker details

```ps
# to get the `container id` from the `containername`
docker ps -aqf "name=^containername$"
# or alternatively
docker inspect --format="{{.Id}}" container_name

# to get the IP address of a container on the bridge network
docker inspect -f "{{ .NetworkSettings.Networks.bridge.IPAddress }}" containername 

```

## Install SQL Server in docker

### Basic installation of SQL Server

#### Get the docker image

```ps
# get image
# docker pull mcr.microsoft.com/mssql/server:2017-latest ( # issues with bulk insert and special characters, see https://github.com/Microsoft/mssql-docker/issues/289 )
docker pull mcr.microsoft.com/mssql/server:2019-latest
```

#### Installation
```ps
# create volume
docker volume create mssql_db_volume
docker volume create shared_bulk_volume

# delete volume
# docker volume rm mssql_db_volume
# docker volume rm shared_bulk_volume

# create container
docker stop sql1
docker rm sql1
docker run `
 -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Password001*" `
 -p 1433:1433 `
 --name sql1 `
 --hostname sql1 `
 --network=container_net `
 -v mssql_db_volume:/var/opt/mssql `
 -v shared_bulk_volume:/var/opt/bulk `
 -d mcr.microsoft.com/mssql/server:2019-latest

# check container
docker ps -a
docker logs sql1
```

- write down secret, this might be used later

#### Script for Password change

```ps
docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd `
    -S localhost -U SA -P "Password001*" `
    -Q "ALTER LOGIN SA WITH PASSWORD='New12Pw!'"
```

#### SQL Script to see the SQL server version

```SQL
Select @@Version
```


## Install Jenkins in docker

- install classical jenkins. See [Jenkins in docker](https://www.jenkins.io/doc/book/installing/docker/)
- Jenkins can also run docker images, see [Jenkins running docker](https://www.jenkins.io/doc/book/pipeline/docker/). This is not covered in this mini-project.

### Commands

- get the [image](https://hub.docker.com/_/jenkins) with command `docker pull jenkins/jenkins`
- create a volume with command `docker volume create jenkins_server_volume`
- if a previous version already exists:

```cmd
docker stop myjenkins
docker rm myjenkins
```

- create a new container

```cmd
docker run --hostname myjenkins --name myjenkins --network=container_net -d -p 8080:8080 -p 50000:50000 -v jenkins_server_volume:/var/jenkins_home --memory=1G jenkins/jenkins
```

- write down the secret of the container for first manual configuration
- connect to jenkins on [http://localhost:8080](http://localhost:8080)
- Create an admin account and note password, admin/Jenkins12

### Required manual installation

- Install add-ins (see below)
- Define admin account (see above) + enter email adress
- Adjust language ([source](https://superuser.com/questions/879392/how-force-jenkins-to-show-ui-always-in-english)):
  - Under Manage Jenkins > Configure System - there should be a "Locale" section.
  - Enter the default language_LOCALE code for English: en_US
  - Click on Ignore browser preference and force this language to all users checkbox.
- Set up an agent:
  - Node Name: python_0 (as per section "Install and use Jenkins agent")
  - Remote root directory: "/home/jenkins/agent"
  - copy secret from node as use for the installation of the Jenkins agent.
- Create a first project
  - restrict it to the agent
  - commands for visual testing may include:

```sh
hostname
whoami
uname -a
cat /etc/*-release | grep "PRETTY_NAME="
pwd
ls
cat /home/jenkins/image_build
python --version
git --version
pip list
```

## Installing a generic Jenkins agent

### Docker commands

```ps
docker pull jenkins/inbound-agent
# docker stop jenkins_agent_python_1
# docker rm jenkins_agent_python_1
# docker run --init jenkins/inbound-agent -url http://jenkins-server:port <secret> <agent name>
docker run --hostname python_1 --name jenkins_agent_python_1 -d --init jenkins_agent_python -workDir=/home/jenkins/agent -url http://172.17.0.3:8080 a6c70db272f6e7272a145dccf180afdcbab96bc45979e14b86a00027e1c796a9 python_1
```

Optional environment variables:
- JENKINS_URL: url for the Jenkins server, can be used as a replacement to -url option, or to set alternate jenkins URL
 - JENKINS_TUNNEL: (HOST:PORT) connect to this agent host and port instead of Jenkins server, assuming this one do route TCP traffic to Jenkins master. Useful when when Jenkins runs behind a load balancer, reverse proxy, etc.
- JENKINS_SECRET: agent secret, if not set as an argument
- JENKINS_AGENT_NAME: agent name, if not set as an argument
- JENKINS_AGENT_WORKDIR: agent work directory, if not set by optional parameter -workDir
- JENKINS_WEB_SOCKET: true if the connection should be made via WebSocket rather than TCP

### Testing the generic agent

#### Connecting to an agent via command line

```cmd
docker exec -it jenkins_agent_python_1 bash
```

#### Create a test project

- Create a free-style project
- Choose "Restrict where this project can be run" and add the agent name ('python_1').
- Enter some shell script.
- Run it and review the console output.

## Custom CI container: Jenkins agent together with Python and GIT

A custom dockerfile image has been created that includes the Jenkins agent as well as Python and GIT - see the file `jenkins_agent_python.dockerfile`.
Since it is should "merge" several dockerfiles, it is based on one docker file. THe commands of the other dockerfiles have been copied in.
Since one dockerfile can be based on another dockerfile, which can be based on another dockerfile, the content of several dockerfiles has been copied into that file.

The image can be created eg from VSCode command palette: VSCode > View > Command Palette > "Docker images: Build image..." > (Enter eg "jenkins_agent_python:1.1").

### Docker commands to create the container

```ps
# docker volume rm jenkins_agent_python_1_vol_agent
docker volume create jenkins_agent_python_1_vol_agent

# docker stop jenkins_agent_python_1
# docker rm jenkins_agent_python_1

docker run `
    --hostname jenkins_agent_python_1 `
    --name jenkins_agent_python_1 `
    --network=container_net `
    -d `
    --volume jenkins_agent_python_1_vol_agent:/home/jenkins/agent `
    --volume shared_bulk_volume:/var/opt/bulk `
    --init jenkins_agent_python:latest `
    -workDir=/home/jenkins/agent `
    -url http://myjenkins:8080 a6c70db272f6e7272a145dccf180afdcbab96bc45979e14b86a00027e1c796a9 python_1

docker exec --user root jenkins_agent_python_1 chmod 777 /var/opt/bulk  
```

The image actually uses two volumes. See also the [dockerfile](https://hub.docker.com/r/jenkins/agent/dockerfile).
However, if `/home/${user}/.jenkins` gets mapped, it gets mapped twice.

## Accessing GitHub from Jenkins

Github and Jenkins need to be configured so that Jenkins can read from GitHub from private or protected repositories.

- [create a personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)
- Create credentials with random name and personal access token as password. See also [there](https://stackoverflow.com/questions/61105368/how-to-use-github-personal-access-token-in-jenkins).

## Running a Jenkins agent on Windows
So far, my Python projects have been developed mostly on Windows. While Python works in general on Windows and Linux, some issues may occur. Obvious differences include the folder\filename logic (or folder/filename logic) :-).

To control for that, it might be useful to run a Jenkins agent on docker/linux (as described above).
On top, it might still be useful to run a Jenkins agent on Windows. If no other infrastructure than the developers PC should be used, it could even be run there. In the long term, this might not be required any more.

## Further information

### Links

- [Using Docker with Pipeline](https://www.jenkins.io/doc/book/pipeline/docker/)
- [Docker image for inbound Jenkins agents](https://hub.docker.com/r/jenkins/inbound-agent/)

### Annex: Jenkins Add-Ins

#### Recommended & used

- Dashboard view
- Folders
- Configuration as Code
- OWASP
- Build Name and Description Setter
- Build Timeout
- Rebuilder
- Throttle Concurrent Builds
- Timestamper
- Workspace Cleanup

- Cobertura
- HTML Publisher
- JUnit
- Warnings Next Generation
- xUnit

- Pipeline
- Pipeline: Stage View ?)
- Conditional Buildstep
- MultiJob
- Parametrized Trigger
- Git
- Git Parameter
- GitHub
- GitLab
- SSH Build Agents
- Email extension
- Mailer
- Locale
- Further Pipeline addins
  - Pipeline: Basic steps' ?
  - Pipeline Job ?
  - Pipeline: Node and Processes ?
  - Jenkins GIT

#### Used

- Code Coverage API
- ShiningPanda
- Text Finder

#### Further useful addins

- Active Choices
-  Build Name and Description setter
 - Groovy
 - Hidden Parameter
 - Jenkins Cobertura
 - Jenkins Job Configuration History
 - Parametrized Trigger
 - Workspace Cleanup
 - Lockable Resources
 - Matrix Authorization Strategy
 - Node and Label parameter
 - Parametrized Scheduler
 - Warnings Next Generation
