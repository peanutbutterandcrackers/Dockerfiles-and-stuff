FROM alpine

ADD build-scripts/install-guix.sh /tmp
ADD build-scripts/entry-point.sh /

RUN apk update && apk upgrade
# Install deps for install-guix.sh
RUN apk add gnupg shadow texinfo
RUN /tmp/install-guix.sh
# Alpine doesn't provide /etc/nsswitch.conf. Missing /etc/nsswitch.conf
# causes some guix builds to fail. Work around that. Until alpine ships
# with one. [https://github.com/alpinelinux/docker-alpine/issues/46]
RUN touch /etc/nsswitch.conf

ENTRYPOINT ["/entry-point.sh", "sh"]
