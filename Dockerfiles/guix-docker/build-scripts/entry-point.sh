#!/bin/sh

/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon --build-users-group=guixbuild &> ~/guix_daemon_logs &
source /etc/profile
exec "$@"
