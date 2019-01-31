FROM alpine:edge

RUN apk update && \
    apk add ca-certificates nginx openssl && \
    mkdir /run/nginx && \
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
    ln -s /dev/stderr /var/log/nginx/error.log && \
    ln -sf /var/lib/nginx/conf.d/site-https.conf /etc/nginx/conf.d/site-https.conf
#USER nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY busybox  /bin/busybox
EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
