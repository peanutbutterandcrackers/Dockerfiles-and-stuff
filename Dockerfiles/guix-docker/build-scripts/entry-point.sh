#!/bin/sh

# By default, guix-daemon is only available at the following location:
STANDARD_GUIX_DAEMON_PATH="/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon"
GUIX_DAEMON_PATH="$STANDARD_GUIX_DAEMON_PATH"

# Guix maintains two separate profiles: one for the PACKAGES installed with
# guix, at ~/.guix-profile, and another for the PACKAGE MANAGER itself (gu-
# ix and guix-daemon), at ~/.config/guix/current. This allows users to roll
# back to previous generation of their PACKAGE profile without having roll-
# ing back to a previous version of the PACKAGE MANAGER itself.
# This ~/.config/guix/current, however, is only initialized at a successful
# run of `guix pull` command.
# Since `~/.config/guix/current` exists outside of the two standard direct-
# ries that guix is concerned with --- /gnu/store and /var/guix: the only
# directories most likely to be in a data-volume container (if that is bei-
# ng used) --- the following code uses a path that `~/.config/guix/current`
# itself points to, as an intermediate symbolic link. The eventual target
# of both symbolic links (as determined using `readlink -f LINK`) is the same.
PULLED_GUIX_DAEMON_PATH="/var/guix/profiles/default/current-guix/bin/guix-daemon"

if [ -L "$PULLED_GUIX_DAEMON_PATH" ]; then
	# Resolve the $PULL_GUIX_DAEMON_PATH link and store it as $GUIX_DAEMON_PATH
	# for execution later on.
	GUIX_DAEMON_PATH=`readlink -f "$PULLED_GUIX_DAEMON_PATH"`
	# Guix exits with an error if /var/guix/profiles/default/current-guix exists
	# when an attempt is made to run `guix pull`. So, delete it.
	rm "/var/guix/profiles/default/current-guix"
fi

${GUIX_DAEMON_PATH} --build-users-group=guixbuild \
                                 --cache-failures \
                                 ${DISABLE_CHROOT:+--disable-chroot} \
                                 &> ~/guix_daemon_logs &

source /etc/profile
exec "$@"
