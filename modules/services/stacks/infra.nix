{ config, pkgs, ... }:

let
  nginxConfig = ''
    events {
      worker_connections 1024;
    }

    http {
      include /etc/nginx/mime.types;
      default_type application/octet-stream;
      sendfile on;
      tcp_nopush on;
      tcp_nodelay on;
      keepalive_timeout 65;
      types_hash_max_size 2048;
      client_max_body_size 100M;

      # Docker internal DNS resolver
      resolver 127.0.0.11 valid=10s ipv6=off;

      # SSL Configuration
      ssl_certificate /etc/nginx/certs/cert.pem;
      ssl_certificate_key /etc/nginx/certs/key.pem;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_prefer_server_ciphers on;
      ssl_ciphers HIGH:!aNULL:!MD5;

      # HTTP -> HTTPS redirect
      server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        return 301 https://$host$request_uri;
      }

      # --- 1. Homepage (Dashboard) ---
      server {
        listen 443 ssl;
        server_name homepage.lunar.srv lunar.srv;

        location / {
          proxy_pass http://host.docker.internal:8083;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }

      # --- 2. Gitea ---
      server {
        listen 443 ssl;
        server_name gitea.lunar.srv;

        location / {
          proxy_pass http://host.docker.internal:3001;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }

      # --- 3. Immich ---
      server {
        listen 443 ssl;
        server_name immich.lunar.srv;
        client_max_body_size 50000M;

        location / {
          proxy_pass http://host.docker.internal:2283;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        }
      }

      # --- 4. Dockhand ---
      server {
        listen 443 ssl;
        server_name dockhand.lunar.srv;

        location / {
          proxy_pass http://host.docker.internal:3000;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        }
      }

      # --- 5. Jellyfin ---
      server {
        listen 443 ssl;
        server_name jellyfin.lunar.srv;

        location / {
          proxy_pass http://host.docker.internal:8096;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        }
      }

      # --- 6. Vaultwarden ---
      server {
        listen 443 ssl;
        server_name vaultwarden.lunar.srv;

        location / {
          proxy_pass http://host.docker.internal:8085;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }

      # --- 7. Uptime Kuma ---
      server {
        listen 443 ssl;
        server_name uptime.lunar.srv;

        location / {
          proxy_pass http://host.docker.internal:3002;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        }
      }

      # --- 8. Cloudreve ---
      server {
        listen 443 ssl;
        server_name cloud.lunar.srv;
        client_max_body_size 50000M;

        location / {
          proxy_pass http://host.docker.internal:5212;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        }
      }
    }
  '';

  composeContent = ''
    version: '3.8'

    services:
      nginx:
        image: nginx:alpine
        container_name: nginx
        restart: unless-stopped
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - /srv/infra/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
          - /srv/infra/nginx/certs:/etc/nginx/certs:ro
        extra_hosts:
          - "host.docker.internal:host-gateway"
  '';

in
{
  environment.etc."stacks/infra/docker-compose.yml".text = composeContent;
  environment.etc."infra/nginx/nginx.conf".text = nginxConfig;

  # Auto-generate self-signed wildcard SSL certificate for *.lunar.srv if missing
  systemd.services.generate-nginx-certs = {
    description = "Generate self-signed SSL certificates for Lunar Nginx";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-compose-infra.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /srv/infra/nginx/certs
      if [ ! -f /srv/infra/nginx/certs/cert.pem ] || [ ! -f /srv/infra/nginx/certs/key.pem ]; then
        ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
          -keyout /srv/infra/nginx/certs/key.pem \
          -out /srv/infra/nginx/certs/cert.pem \
          -subj "/CN=lunar.srv/O=Lunar Home Lab" \
          -addext "subjectAltName = DNS:lunar.srv,DNS:*.lunar.srv,IP:127.0.0.1"
        chmod 600 /srv/infra/nginx/certs/key.pem
        chmod 644 /srv/infra/nginx/certs/cert.pem
      fi
    '';
  };

  systemd.tmpfiles.rules = [
    "d /srv/stacks/infra 0755 root root -"
    "d /srv/infra/nginx 0755 root root -"
    "d /srv/infra/nginx/certs 0755 root root -"
    "L+ /srv/stacks/infra/docker-compose.yml - - - - /etc/stacks/infra/docker-compose.yml"
    "L+ /srv/infra/nginx/nginx.conf - - - - /etc/infra/nginx/nginx.conf"
  ];
}
