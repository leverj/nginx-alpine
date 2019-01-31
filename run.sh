#!/usr/bin/env bash
[ -z "$SITE_ADDR" ] && echo SITE_ADDR not defined && exit 1
[ -z "$CERTS" -a ! -d ~/.acme.sh/$SITE_ADDR ] && echo acme.sh not found and CERTS directory not defined && exit 1
CERTS=${CERTS:-~/.acme.sh}
APP1=${APP1:-10.242.0.11:9000}
APP2=${APP2:-10.242.0.12:9000}
echo Using certs in $CERTS
eval echo "\"$(<site-https.in)\"" > conf.d/site-https.conf

[ ! -f $PWD/params/dhparam4096.pem ] && echo dhparam4096 missing. Generate using: openssl dhparam -out dhparam4096.pem 4096 && exit 1

docker run -d --restart=unless-stopped \
          --cap-drop ALL --cap-add NET_BIND_SERVICE --cap-add SETUID \
          --cap-add SETGID --cap-add DAC_OVERRIDE --cap-add CHOWN --read-only \
          --name nginx \
          -v $CERTS:/etc/letsencrypt:ro \
          -v $PWD/html:/var/lib/nginx/html:ro \
          -v $PWD/params:/var/lib/nginx/params:ro \
          -v $PWD/conf.d:/var/lib/nginx/conf.d:ro \
          -v $PWD/state:/var/lib/nginx/state:ro \
          -p 1500:80 -p 1543:443 nginx-alpine
