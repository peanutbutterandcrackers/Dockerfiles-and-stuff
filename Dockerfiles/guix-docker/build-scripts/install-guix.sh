#!/bin/sh

REQUIRES="gnupg shadow"
apk add ${REQUIRES}

GUIX_VERSION=1.0.1
GNU_URL="https://ftp.gnu.org/gnu/guix/"

ARCH=$(uname -m)
KERNEL=$(uname -s)
SYSTEM=$(echo ${ARCH}-${KERNEL} | tr [[:upper:]] [[:lower:]])
TAR_FILE="guix-binary-${GUIX_VERSION}.${SYSTEM}.tar.xz"
SHELLRC_FILE="guix_sourcerer.sh"
SHELLRC_FILE_URL="https://raw.githubusercontent.com/peanutbutterandcrackers/Dockerfiles-and-stuff/master/Sourcerer/guix_sourcerer.sh"

cd /tmp
gpg --keyserver pool.sks-keyservers.net --recv-keys 3CE464558A84FDC69DB40CFB090B11993D9AEBB5
wget ${GNU_URL}${TAR_FILE}
wget ${GNU_URL}${TAR_FILE}.sig
gpg --verify ${TAR_FILE}.sig
tar xvf ${TAR_FILE}
mv var/guix /var && mv gnu /
wget ${SHELLRC_FILE_URL}
mkdir -p /etc/profile.d && mv -v ${SHELLRC_FILE} /etc/profile.d/
rm -rvf *

# Make guix command available to all users on the machine
mkdir -p /usr/local/bin
ln -s /var/guix/profiles/per-user/root/current-guix/bin/guix /usr/local/bin/

# Authorize substitute server
guix archive --authorize < /var/guix/profiles/per-user/root/current-guix/share/guix/ci.guix.gnu.org.pub

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
