# Fusion Metadata Registry for SDMX

Image URL: https://hub.docker.com/r/metadatatechnology/fmr-mysql

docker pull metadatatechnology/fmr-mysql:10.5.7-withexamples
docker container create --name fmr --publish 8081:8080 metadatatechnology/fmr-mysql:10.5.7-withexamples
docker start fmr

Point your browser at http://localhost:8081/FusionRegistry