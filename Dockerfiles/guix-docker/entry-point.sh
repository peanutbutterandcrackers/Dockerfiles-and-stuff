#!/bin/sh

GUIX_PROFILE="`echo ~root`/.config/guix/current"
source $GUIX_PROFILE/etc/profile
~root/.config/guix/current/bin/guix-daemon --build-users-group=guixbuild & # start guix-daemon
exec "$@"
