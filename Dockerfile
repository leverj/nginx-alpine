FROM alpine:edge

RUN apk update && \
    apk add ca-certificates nginx openssl nginx-mod-http-headers-more nginx-mod-http-image-filter libcap && \
    # Let the non-root nginx master bind 80/443 (needs CAP_NET_BIND_SERVICE in
    # the container's bounding set — run.sh already adds it).
    setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx && \
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
USER nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY busybox  /bin/busybox
EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
