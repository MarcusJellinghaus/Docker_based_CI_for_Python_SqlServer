# Metabase
Metabase (https://www.metabase.com/) is another tool to display data.

## Docker installation
Regarding running it on docker, see the (doc)[https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html].
Start it with:

```
docker run -d -p 3000:3000 `
    -v ~/metabase-data:/metabase-data `
    -e "MB_DB_FILE=/metabase-data/metabase.db" `
    --network=container_net `
    -d `
    --name metabase metabase/metabase
```

Check the container on the network with `docker network inspect container_net`.

## Access and configure it
Access it at (http:\\localhost:3000)[http:\\localhost:3000].
Fill in the details in the initial setup wizard. Also enter the port.

## Use it
Enjoy :-)