# Fusion Metadata Registry for SDMX

The Fusion Metadata Registry (FMR) supports SDMX data. It can be installed from a [docker image](https://hub.docker.com/r/metadatatechnology/fmr-mysql).

It can be installed with the following scipt:

```PS
docker pull metadatatechnology/fmr-mysql:10.5.7-withexamples
docker container create --name fmr --publish 8083:8080 metadatatechnology/fmr-mysql:10.5.7-withexamples
docker start fmr
```

The FMR is accessible at [http://localhost:8083/FusionRegistry](http://localhost:8083/FusionRegistry.)