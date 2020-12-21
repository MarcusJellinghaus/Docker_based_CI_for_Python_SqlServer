REM Start in the same folder as the docker-compose.yml file.

REM use external volumes 
REM for easier reuse of previous results - probably, they exist already.
docker volume create mssql_db_volume
docker volume create shared_bulk_volume
docker volume create jenkins_server_volume
docker volume create jenkins_agent_python_1_vol_agent

docker-compose up -d --build
docker-compose ps
docker-compose exec --user root jenkins_agent_python_1 chmod 777 /var/opt/bulk
