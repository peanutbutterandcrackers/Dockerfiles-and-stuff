FROM alpine

ADD build-scripts/install-guix.sh /tmp
ADD build-scripts/entry-point.sh /

RUN /tmp/install-guix.sh

ENTRYPOINT ["/entry-point.sh", "sh"]
