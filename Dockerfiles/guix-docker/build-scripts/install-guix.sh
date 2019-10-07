#!/bin/sh

REQUIRES="gnupg shadow"
apk add ${REQUIRES}

GUIX_VERSION=1.0.1
GNU_URL="https://ftp.gnu.org/gnu/guix/"

ARCH=$(uname -m)
KERNEL=$(uname -s)
SYSTEM=$(echo ${ARCH}-${KERNEL} | tr [[:upper:]] [[:lower:]])
TAR_FILE="guix-binary-${GUIX_VERSION}.${SYSTEM}.tar.xz"

cd /tmp
gpg --keyserver pool.sks-keyservers.net --recv-keys 3CE464558A84FDC69DB40CFB090B11993D9AEBB5
wget ${GNU_URL}${TAR_FILE}
wget ${GNU_URL}${TAR_FILE}.sig
gpg --verify ${TAR_FILE}.sig
tar xvf ${TAR_FILE}
mv var/guix /var && mv gnu /

# Make profile available (for root)
mkdir -p ~root/.config/guix
ln -sf /var/guix/profiles/per-user/root/current-guix ~root/.config/guix/current
GUIX_PROFILE="`echo ~root`/.config/guix/current"
source $GUIX_PROFILE/etc/profile

# Make guix command available to other users on the machine
mkdir -p /usr/local/bin
ln -s /var/guix/profiles/per-user/root/current-guix/bin/guix /usr/local/bin/

# Authorize substitute server
guix archive --authorize < ~root/.config/guix/current/share/guix/ci.guix.gnu.org.pub

# Add a build user pool
groupadd --system guixbuild
for i in `seq -w 1 10`; do
	useradd -g guixbuild -G guixbuild -d /var/empty -s `which nologin` -c "Guix build user $i" --system guixbuilder$i
done

# Optional, but cool: add `$ info guix`
OPTIONALS="texinfo"
apk add ${OPTIONALS}
mkdir -p /usr/local/share/info
cd /usr/local/share/info
for i in /var/guix/profiles/per-user/root/current-guix/share/info/*; do
	ln -vs $i
done
