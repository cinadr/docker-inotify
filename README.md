# Inotify Docker Image

## Description

This docker image runs a [inotify](https://github.com/rvoicilas/inotify-tools/wiki) service based on [Alpine Linux](https://hub.docker.com/_/alpine/).

## Usage

* Link docker socket into container `-v /var/run/docker.sock:/var/run/docker.sock:ro`
* Link one or more directories, which you would like to monitor with inotifywait into the docker container. As example: `-v /var/lib/docker/data/bind/config:/config`.
* Set docker endpoint `API_ENDPOINT=<container|image|network|etc>` and name 'ENDPOINT_NAME' which will receive the `DOCKER_COMMAND=<restart|kill|create|etc>` with parameters `DOCKER_PARAMS=<all|name=...|etc>`. DOCKER_PARAMS does not require question mark it will be added if required.
* Define the volume variable to define the container internal paths to the monitored directories.


### Docker Run

```
docker run -d --name inotify -v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /var/lib/docker/data/bind/config:/config \
-e "CONTAINER=bind" -e "VOLUMES=/config" \
pstauffer/inotify:stable
```


### Docker Compose
Check out the docker-compose file in the [git repo](https://raw.githubusercontent.com/pstauffer/docker-inotify/master/docker-compose.yml) and create your own file. After that run this `docker-compose` command.
```
docker-compse up -d
```

### API Options
* Version: for robustness one must specify an [API version](https://docs.docker.com/engine/api/version-history/). Environment variable: `API_VERSION=1.24`
* Endpoint: specify the endpoint type which one need to access. [See here](https://docs.docker.com/engine/api/v1.24/) Environment variable: `API_ENDPOINT=container`
* Endpoint name: name or id of the enpoint (image/container/network/etc). Environment variable: `ENDPOINT_NAME=<container name>`
* Docker command: specify the command to be executed against the named endpoint. Environment variable: `DOCKER_COMMAND=restart`
* Docker parameters: parameter list and values of the command. Environment variable: `DOCKER_PARAMS=`

### Curl Options
For debug propose it's possible to pass additional curl options into the container. Just set the environment variable `CURL_OPTIONS=-s -X POST`.

### Inotify Events
The default inotify events are `create,delete,modify,move`. This behaviour can be overwritten, if you set the environment variable `INOTIFY_EVENTS=create,delete,modify,move`.

### Inotify Options
To define your own inotify options, overwrite the variable `INOTIFY_OPTONS=--monitor -r`.

### Settle down
Timer to settle down quick inotify repeated events. `SETTLE_DOWN=600`

## Security
Please be aware that the Docker Socket is mounted inside this Docker Container and with that you can manipulate all containers. So don't expose ports or use this image for external services!

## License
This project is licensed under `MIT <http://opensource.org/licenses/MIT>`_.
