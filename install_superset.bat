REM superset is an open source product, a bit similar to Tableau ( https://superset.apache.org/ ).
REM while it loooks powerful, it does not seem to work well with SQL-Server.
REM see links to bug reports at the end.

pushd C:\Users\%USERNAME%\Documents\Development

REM get repo without windows crlf
git config --global core.autocrlf false
git clone https://github.com/apache/incubator-superset.git
git config --global core.autocrlf true

REM adjust network in docker-compose.yml file, add following paragraph, comment out network_mode: host
networks:
  default:
    external:
      name: container_net

cd incubator-superset

REM install additional odbc drivers drivers following https://superset.apache.org/docs/databases/dockeradddrivers
REM install inside containers superset_app, superset_worker

REM according to dockerfile
REM run this in container
exit
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& apt-get update \
	&& ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql17 \
	&& apt-get install -y --no-install-recommends unixodbc-dev \
	&& rm -rf /var/lib/apt/lists/*

REM run this in container
exit
pip install mysqlclient pymssql pyodbc

REM this would also work
echo mysqlclient >> ./docker/requirements-local.txt
echo pymssql >> ./docker/requirements-local.txt
echo pyodbc >> ./docker/requirements-local.txt installation of pyodbc does not work

REM start up different containers for superset
docker-compose up -d

@echo off
echo *
echo log in to http://localhost:8088
echo username: admin
echo password: admin
echo starting it the first time takes a while
echo see also https://superset.apache.org/docs/intro

popd



echo connection string: mssql+pymssql://sa:Password001*@sql1/DimensionFinder
echo see also https://superset.apache.org/docs/databases/sql-server

REM bug in superset with pymssql driver and sql server: https://github.com/apache/incubator-superset/issues/10993

REM bug in superset with pyodbc driver and sql server https://github.com/apache/incubator-superset/issues/236 


