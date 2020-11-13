REM set up sql server
docker pull mcr.microsoft.com/mssql/server:2019-latest

docker volume create mssql_db_volume
docker volume create shared_bulk_volume

docker stop sql1
docker rm sql1
docker run ^
 -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Password001*" ^
 -p 1433:1433 ^
 --name sql1 ^
 --hostname sql1 ^
 --network=container_net ^
 -v mssql_db_volume:/var/opt/mssql ^
 -v shared_bulk_volume:/var/opt/bulk ^
 -d mcr.microsoft.com/mssql/server:2019-latest

REM install Jenkins
docker pull jenkins/jenkins
 
docker volume create jenkins_server_volume
 
docker stop myjenkins
docker rm myjenkins
docker run ^
 --hostname myjenkins ^
 --name myjenkins ^
 --network=container_net ^
 -d -p 8080:8080 ^
 -p 50000:50000 ^
-v jenkins_server_volume:/var/jenkins_home ^
--memory=1G jenkins/jenkins

REM wait for Jenkins to be started, eg 10 seconds
timeout /T 10

REM install Jenkins agent with Python and GIT
REM based on own dockerfile, no need to pull

docker volume create jenkins_agent_python_1_vol_agent

docker stop jenkins_agent_python_1
docker rm jenkins_agent_python_1

docker run ^
    --hostname jenkins_agent_python_1 ^
    --name jenkins_agent_python_1 ^
    --network=container_net ^
    -d ^
    --volume jenkins_agent_python_1_vol_agent:/home/jenkins/agent ^
    --volume shared_bulk_volume:/var/opt/bulk ^
    --init jenkins_agent_python:latest ^
    -workDir=/home/jenkins/agent ^
    -url http://myjenkins:8080 a6c70db272f6e7272a145dccf180afdcbab96bc45979e14b86a00027e1c796a9 python_1

docker exec --user root jenkins_agent_python_1 chmod 777 /var/opt/bulk  
