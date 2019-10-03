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
           --device /dev/snd \
           # sound wasn't outputting without this on my machine \
           --privileged \
       IMAGE_NAME
```
One might have to run `xhost +"local:docker@"` (on the host) [to allow the docker user X access](https://github.com/jessfraz/dockerfiles/issues/329#issuecomment-368262183).

Change the Dockerfile as needed to install other programs.
