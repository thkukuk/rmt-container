#!/bin/sh

MYSQL_ROOT_PASSWORD=root

# Run mariadb
mkdir -p /srv/rmt/mariadb

podman stop rmt-mariadb
podman pull registry.opensuse.org/opensuse/mariadb:latest
podman run -d --rm --name rmt-mariadb -p 3306:3306 -v /srv/rmt/mariadb:/var/lib/mysql -e MYSQL_DATABASE=rmt -e MYSQL_USER=rmt -e MYSQL_PASSWORD=rmt -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} registry.opensuse.org/opensuse/mariadb:latest

# Run nginx
mkdir -p /srv/rmt/storage
mkdir -p /srv/rmt/ssl
mkdir -p /srv/rmt/vhosts.d

podman stop rmt-nginx
podman pull registry.opensuse.org/opensuse/nginx:latest
podman run -d --rm --name rmt-nginx -p 80:80 -p 443:443 -v /srv/rmt/vhosts.d:/etc/nginx/vhosts.d -v /srv/rmt/ssl:/etc/rmt/ssl -v /srv/rmt/storage:/usr/share/rmt registry.opensuse.org/opensuse/nginx:latest

MYSQL_HOST=`podman inspect -f "{{.NetworkSettings.IPAddress}}" rmt-mariadb`
podman stop rmt-server
podman pull registry.opensuse.org/opensuse/rmt-server:latest
podman run -d --rm --name rmt-server -p 4224:4224 -v /srv/rmt/storage:/var/lib/rmt -e MYSQL_HOST=${MYSQL_HOST} -e MYSQL_DATABASE=rmt -e MYSQL_USER=rmt -e MYSQL_PASSWORD=rmt registry.opensuse.org/opensuse/rmt-server:latest
