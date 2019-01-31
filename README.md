# nginx-alpine

Nginx docker container based off alpine. Designed to be run fully read-only.

## Host Requirements

1. Docker for container management
2. acme.sh for certificate management

## Features

1. Switch among two backend servers based on state file
2. Proxy https/websocket to app server if state files are present
3. Static file server if state files are not present
4. Support TLS1.3, OCSP Stapling, HSTS (CSP responsibility of proxied app)
5. Combined RSA/ECC certs, Stateless acme.sh certificate renewals
6. HTTP2 push and preload
7. 4096 bit DH params
8. Custom error pages
9. Highly constrained busybox image with small subset of commands

```
[, [[, adjtimex, basename, bunzip2, bzcat, bzip2,
cat, clear, cp, cpio, cryptpw, cut, date, dirname,
dnsdomainname, dos2unix, du, echo, env, false, find,
grep, gunzip, gzip, head, hostname, install, kill,
ln, ls, md5sum, mkdir, more, mv, nice, nohup, nologin,
nslookup, od, ping, pipe_progress, ps, pwd, reset,
run-parts, sed, sh, sha1sum, sha256sum, sha3sum,
sha512sum, sleep, start-stop-daemon, tail, tar, tee,
test, true, udhcpc, uname, unit, unix2dos, unzip, wc,
which, whoami, xargs, yes, zcat
```

## usage:

### Run using certificates stored in ~/.acme.sh
```
$ SITE_ADDR=www.example.com ./run.sh

```

Uses ~/.acme.sh/${SITE_ADDR}_ecc for ecc certificates and ~/.acme.sh/${SITE_ADDR} for RSA certificates

### Override certificate location

```
$ CERTS=/etc/ssl/certs SITE_ADDR=www.example.com ./run.sh

```
