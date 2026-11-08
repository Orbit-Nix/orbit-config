{ config, pkgs, ... }:

let
  composeContent = ''
    name: mail

    services:
      stalwart:
        image: stalwartlabs/stalwart:v1
        container_name: stalwart
        restart: unless-stopped
        ulimits:
          nofile:
            soft: 65536
            hard: 65536
        ports:
          - "25:25"
          - "465:465"
          - "587:587"
          - "993:993"
          - "8080:8080"
        volumes:
          - /srv/apps/stalwart/etc:/etc/stalwart
          - /srv/apps/stalwart/data:/var/lib/stalwart
        networks:
          mail_net:
            ipv4_address: 172.29.0.2
          default: {}

      sogo-db:
        image: postgres:15-alpine
        container_name: sogo_db
        restart: unless-stopped
        environment:
          - POSTGRES_DB=sogo
          - POSTGRES_USER=sogo
          - POSTGRES_PASSWORD=sogopassword
        volumes:
          - /srv/apps/sogo/postgres:/var/lib/postgresql/data
          - /srv/apps/sogo/db-init:/docker-entrypoint-initdb.d:ro
        networks:
          mail_net:
            ipv4_address: 172.29.0.3
          default: {}

      sogo-memcached:
        image: memcached:alpine
        container_name: sogo_memcached
        restart: unless-stopped
        networks:
          mail_net:
            ipv4_address: 172.29.0.4
          default: {}

      sogo:
        image: sonroyaalmerol/docker-sogo:latest
        container_name: sogo
        restart: unless-stopped
        depends_on:
          - sogo-db
          - sogo-memcached
          - stalwart
        ports:
          - "8082:80"
        volumes:
          - /srv/apps/sogo/config:/etc/sogo/sogo.conf.d:ro
        networks:
          mail_net:
            ipv4_address: 172.29.0.5
          default: {}

      mail-receiver:
        image: python:3.11-alpine
        container_name: mail_receiver
        restart: unless-stopped
        depends_on:
          - stalwart
        ports:
          - "8089:8089"
        volumes:
          - /srv/apps/mail-receiver/receiver.py:/app/receiver.py:ro
        working_dir: /app
        command: python3 -u receiver.py
        environment:
          - WEBHOOK_SECRET=lunar-mail-secret-2026
          - SMTP_HOST=172.29.0.2
          - SMTP_PORT=25
        networks:
          mail_net:
            ipv4_address: 172.29.0.6
          default: {}

    networks:
      mail_net:
        driver: bridge
        ipam:
          config:
            - subnet: 172.29.0.0/16
  '';
in
{
  environment.etc."stacks/mail/docker-compose.yml".text = composeContent;
  environment.etc."apps/sogo/config/sogo.yaml".text = builtins.readFile ./mail/sogo.yaml;
  environment.etc."apps/sogo/db-init/init.sql".text = builtins.readFile ./mail/init.sql;
  environment.etc."apps/sogo/sogo-expressive-theme.js".text = builtins.readFile ./mail/sogo-expressive-theme.js;
  environment.etc."apps/mail-receiver/receiver.py".text = builtins.readFile ./mail/receiver.py;

  systemd.tmpfiles.rules = [
    "d /srv/stacks/mail 0755 root root -"
    "d /srv/apps/stalwart/etc 0770 2000 2000 -"
    "d /srv/apps/stalwart/data 0770 2000 2000 -"
    "d /srv/apps/sogo 0755 root root -"
    "d /srv/apps/sogo/config 0755 root root -"
    "d /srv/apps/sogo/postgres 0700 70 70 -"
    "d /srv/apps/sogo/db-init 0755 root root -"
    "d /srv/apps/mail-receiver 0755 root root -"
    "L+ /srv/stacks/mail/docker-compose.yml - - - - /etc/stacks/mail/docker-compose.yml"
    "L+ /srv/apps/sogo/config/sogo.yaml - - - - /etc/apps/sogo/config/sogo.yaml"
    "L+ /srv/apps/sogo/db-init/init.sql - - - - /etc/apps/sogo/db-init/init.sql"
    "L+ /srv/apps/sogo/sogo-expressive-theme.js - - - - /etc/apps/sogo/sogo-expressive-theme.js"
    "L+ /srv/apps/mail-receiver/receiver.py 0755 root root - /etc/apps/mail-receiver/receiver.py"
  ];
}
