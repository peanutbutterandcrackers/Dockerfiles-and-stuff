### A container image to run GUI programs

Build with:
```
docker build --tag IMAGE_NAME .
```

RUN with:
```
docker run --rm \
           --interactive --tty \
           # use host's $DISPLAY \
           --env DISPLAY=$DISPLAY \
           # share x11 socket w/ host \
           --volume /tmp/.X11-unix:/tmp/.X11-unix \
           # for sound \
           # Add audio group to run as \
           -- group-add $(getent group audio | cut -d: -f3) \
           # Add the host sound device to the container
           --device /dev/snd \
       IMAGE_NAME
```
One might have to run `xhost +"local:docker@"` (on the host) [to allow the docker user X access](https://github.com/jessfraz/dockerfiles/issues/329#issuecomment-368262183).
For sound-related issues, [follow the blue hyperlink](https://github.com/jessfraz/dockerfiles/issues/85).

Change the Dockerfile as needed to install other programs.
