# guix-docker: containerized Guix
Containerized version of the [GNU GUIX](https://guix.gnu.org/) package manger, on top of alpine linux base image.

## Build Instructions:
`docker build --tag guix_image .`

## Running:
`docker run --rm -it --privileged guix_image`

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

# Explanations:

## Why does guix require `--privileged`?
With the recommended setup, Guix builds the packages in a `chroot` so as to isolate the builds from the host. This is essentially a container. And `docker` requires that for a container to spin up containers inside of it, the host container must be `--privileged`.

## Bypassing `--privileged`:
If you don't want to make the guix container `--privileged`:
<pre>
docker run --rm -it <b>--env NO_CHROOT=True</b> guiximage
</pre>
`NO_CHROOT` env var can be set to anything (even 'False'). If it is NOT unset (i.e. is set to ANY value whatsoever), [the `guix-daemon` will run with `--no-chroot` option](https://github.com/peanutbutterandcrackers/Dockerfiles-and-stuff/blob/b1fced1be5ed785c3919ea2e73e4d30af764a053/Dockerfiles/guix-docker/build-scripts/entry-point.sh#L33). This means that it will not build packages inside containers and thus `--privileged` will not be required. Please note, however, that this is NOT the recommended way for running guix.

## `guix-sourcerer.sh`
This comes from https://github.com/peanutbutterandcrackers/Dockerfiles-and-stuff/blob/master/Sourcerer/guix_sourcerer.sh and is a guix-profile initialize-r. It is put in `/etc/profile.d` and is read by all non-login shells. It is written in the hopes that any foreign distro might benefit from it.

## Switching base-image:
If you need to switch to another base image (say `debian`), just change the Dockerfile: The `FROM` and the two `RUN` statements that update&&upgrade the image and install the dependencies. The following are the dependencies required:
1. GNU coreutils
2. `gpg`
3. `wget`
4. `tar`
5. GNU shadow-utils
6. `info`

## Other Explanations:
Please consult the comments in the build-scripts. There are a few explanations there about why things are done a certain way.

## References:
1. [Guix Package Manger Reference](https://guix.gnu.org/manual/en/guix.pdf)
