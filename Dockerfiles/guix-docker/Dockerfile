FROM alpine

ADD install-guix.sh /tmp
ADD entry-point.sh /

RUN /tmp/install-guix.sh

ENTRYPOINT [./entry-point.sh]
