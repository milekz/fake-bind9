# Fake-bind9
fake-bind9 - bind9 that answer with fake IP

# Based on Bind-9.14.1

`/etc/bind` should have two major files: `named.conf` and `hook.sh`.

`named.conf` is the configure file for bind, and you can include any other
files in it.

`hook.sh` is the hook will be executed when you trigger
`http://container-ip:9000/hooks/bind`.

53/tcp, 53/udp, 9000/tcp are exported.

## Guide

Sample command to run with fake IP set to 1.2.3.4:

```
docker run -d -p 53:53/udp -e FAKEIP=1.2.3.4 milekz/fake-bind9
```
Sample command to run :

```
docker run -d -v /srv/docker/bind:/etc/bind milekz/fake-bind9

docker run -d -v /srv/docker/bind:/etc/bind -p 53:53/udp milekz/fake-bind9
```

