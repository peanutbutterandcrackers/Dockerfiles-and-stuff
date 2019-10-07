# guix-docker: containerized Guix
Containerized version of the [GNU GUIX](https://guix.gnu.org/) package manger, on top of alpine linux base image.

## Build Instructions:
`docker build --tag guix_image .`

## Recommended Usage:
Use the following shell function to run the guix container. It creates a data-volume-container to save data in the `/gnu` and `/var/guix` data in the guix container.
```bash

function spinguix {

	# Spin up a guix container
	# USAGE:
	#   $ spinguix GUIX-IMAGE DATA-CONTAINER
	#   - GUIX-IMAGE: must exist
	#   - DATA-CONTAINER: Is created if it does not exist already
	# The spinned guix container has all GUI capabilities (including sound).
	# It is removed as soon as it is stopped. The reason why it is started
	# using --privileged is because `guix build` builds things essentially inside
	# containers. And --privileged is required to spin containers inside of containers.

	local GUIX_IMAGE=$1
	local DATA_CONTAINER=$2
	local GUIX_IMAGE_EXISTS=$(docker inspect --format {{.RepoTags}} $GUIX_IMAGE 2> /dev/null)
	local DATA_CONTAINER_EXISTS=$(docker inspect --format {{.Name}} $DATA_CONTAINER 2> /dev/null)
	[ -z $GUIX_IMAGE_EXISTS ] && echo 'The specified guix image could not be found.' >&2 && return 1
	[ -z $DATA_CONTAINER_EXISTS ] && docker create --volume /gnu \
                                                   --volume /var/guix/ \
                                                   --name "$DATA_CONTAINER" "$GUIX_IMAGE"

	xhost +"local:docker@" &> /dev/null
	docker run --rm --interactive --tty \
                    --volumes-from "$DATA_CONTAINER" \
                    --volume /tmp/.X11-unix:/tmp/.X11-unix \
                    --env DISPLAY=$DISPLAY \
                    --group-add $(getent group audio | cut -d: -f3) \
                    --device /dev/snd \
                    --privileged \
                    "$GUIX_IMAGE"

}
```
Add the given shell function to `~/.bashrc`, `source ~/.bashrc` it and then run:
```
$ spinguix guix_image guix_data_container
```
One can also migrate the data-volume container between hosts, thus saving time. Consult [.dockerfuncs](https://github.com/peanutbutterandcrackers/Dockerfiles-and-stuff/blob/master/Sourcerer/.dockerfuncs) dot file for functions to aid in the migration (`docker-export-data-container` and `docker-import-data-container`).

## References:
1. [Guix Package Manger Reference](https://guix.gnu.org/manual/en/guix.pdf)
