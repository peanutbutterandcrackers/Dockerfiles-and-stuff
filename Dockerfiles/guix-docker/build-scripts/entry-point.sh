#!/bin/sh

/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon --build-users-group=guixbuild &
source /etc/profile
exec "$@"
