FROM alpine:latest

MAINTAINER Zimmermann Zsolt

#
# Install all required dependencies.
#

RUN apk --update upgrade && \
    apk add --update curl inotify-tools coreutils tini && \
    rm -rf /var/cache/apk/*

#
# Add named init script.
#

ADD init.sh /init.sh
RUN chmod 750 /init.sh


#
# Define container settings.
#

WORKDIR /tmp


#
# Start named.
#

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/init.sh"]
