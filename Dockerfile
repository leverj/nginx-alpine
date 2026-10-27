# Pinned Alpine stable + exact nginx revision, not alpine:edge + whatever apk
# resolves that day: the version that ships is the version in this diff.
# 1.30.6 is the first stable release carrying all of nginx's 2026 fixes,
# including CVE-2026-97205 (AIO use-after-free) and CVE-2026-97629
# (TLS session tickets).
# See https://nginx.org/en/security_advisories.html.
# Alpine removes superseded revisions from the branch, so once a newer one
# ships this build fails until both pins are bumped together; the weekly CI
# check reports that. scripts/docker-publish.sh reads both ARGs for the tag.
ARG ALPINE_VERSION=3.24
FROM alpine:${ALPINE_VERSION}
ARG NGINX_VERSION=1.30.6-r0

RUN apk add --no-cache ca-certificates openssl \
      nginx=${NGINX_VERSION} \
      nginx-mod-http-headers-more=${NGINX_VERSION} \
      nginx-mod-http-image-filter=${NGINX_VERSION} && \
#    mkdir /run/nginx && \
    mkdir -p /var/lib/nginx/tmp/client_body && \
    chown nginx:nginx /var/lib/nginx/tmp/client_body &&\
    mkdir -p /var/lib/nginx/tmp/proxy && \
    chown nginx:nginx /var/lib/nginx/tmp/proxy &&\
    mkdir -p /var/lib/nginx/tmp/fastcgi && \
    chown nginx:nginx /var/lib/nginx/tmp/fastcgi &&\
    mkdir -p /var/lib/nginx/tmp/uwsgi && \
    chown nginx:nginx /var/lib/nginx/tmp/uwsgi &&\
    mkdir -p /var/lib/nginx/tmp/scgi && \
    chown nginx:nginx /var/lib/nginx/tmp/scgi &&\
    ln -s /dev/stdout /var/log/nginx/access.log && \
    ln -s /dev/stderr /var/log/nginx/error.log
#USER nginx
COPY nginx.conf /etc/nginx/nginx.conf
# Fail the build, not the host, if this nginx.conf or a module no longer loads on
# the pinned nginx. Site configs are mounted at run time, so only the base config
# and the two dynamic modules are exercised here.
RUN nginx -t
COPY busybox  /bin/busybox
EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
