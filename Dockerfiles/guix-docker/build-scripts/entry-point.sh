#!/bin/sh

/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon \
                           --build-users-group=guixbuild \
                           --cache-failures \
                           ${DISABLE_CHROOT:+--disable-chroot} \
                           &> ~/guix_daemon_logs &
source /etc/profile
exec "$@"
