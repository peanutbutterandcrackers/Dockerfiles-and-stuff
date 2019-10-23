FROM alpine

ADD build-scripts/install-guix.sh /tmp
ADD build-scripts/entry-point.sh /

# Install deps for install-guix.sh
RUN apk add gnupg shadow texinfo
RUN /tmp/install-guix.sh

ENTRYPOINT ["/entry-point.sh", "sh"]
