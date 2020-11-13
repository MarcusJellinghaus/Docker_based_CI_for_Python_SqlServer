# CI with docker containers using Jenkins, Jenkins-Agent, Python, SQL-Server

A small project to set up a CI infrastructure based on docker providing Jenkins, SQL-Server and a Jenkins agent with Python, ODBC etc.

How to set up such a docker based CI infrastructure is explained in `Docker_based_CI_infrastructure.md`.
`jenkins_agent_python.Dockerfile` allows to build an image containing a jenkins agent with python, ODBC client, GIT client.

`First_setup.cmd` is the complete script that needs to be run to create/update the three containers.
