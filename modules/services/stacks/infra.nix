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

      # --- 1. Authelia Authentication Portal ---
      server {
        listen 443 ssl;
        server_name auth.lunar.srv;

        location / {
          proxy_pass http://authelia:9091;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-URI $request_uri;
        }
      }

      # --- 2. Homepage (Dashboard) ---
      server {
        listen 443 ssl;
        server_name homepage.lunar.srv lunar.srv;

        location /authelia {
          internal;
          proxy_pass http://authelia:9091/api/verify;
          proxy_pass_request_body off;
          proxy_set_header Content-Length "";
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Original-Method $request_method;
          proxy_set_header X-Forwarded-Method $request_method;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-URI $request_uri;
          proxy_set_header X-Forwarded-For $remote_addr;
        }

        location / {
          auth_request /authelia;
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $groups $upstream_http_remote_groups;
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Groups $groups;

          error_page 401 =302 https://auth.lunar.srv/?rd=$scheme://$http_host$request_uri;

          proxy_pass http://host.docker.internal:8083;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }

      # --- 3. Gitea ---
      server {
        listen 443 ssl;
        server_name gitea.lunar.srv;

        location /authelia {
          internal;
          proxy_pass http://authelia:9091/api/verify;
          proxy_pass_request_body off;
          proxy_set_header Content-Length "";
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Original-Method $request_method;
          proxy_set_header X-Forwarded-Method $request_method;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-URI $request_uri;
          proxy_set_header X-Forwarded-For $remote_addr;
        }

        location / {
          auth_request /authelia;
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $groups $upstream_http_remote_groups;
          auth_request_set $name $upstream_http_remote_name;
          auth_request_set $email $upstream_http_remote_email;
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Groups $groups;
          proxy_set_header Remote-Name $name;
          proxy_set_header Remote-Email $email;

          error_page 401 =302 https://auth.lunar.srv/?rd=$scheme://$http_host$request_uri;

          proxy_pass http://host.docker.internal:3001;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }

      # --- 4. Immich ---
      server {
        listen 443 ssl;
        server_name immich.lunar.srv;
        client_max_body_size 50000M;

        location /authelia {
          internal;
          proxy_pass http://authelia:9091/api/verify;
          proxy_pass_request_body off;
          proxy_set_header Content-Length "";
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Original-Method $request_method;
          proxy_set_header X-Forwarded-Method $request_method;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-URI $request_uri;
          proxy_set_header X-Forwarded-For $remote_addr;
        }

        location / {
          auth_request /authelia;
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $groups $upstream_http_remote_groups;
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Groups $groups;

          error_page 401 =302 https://auth.lunar.srv/?rd=$scheme://$http_host$request_uri;

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

      # --- 5. Dockhand ---
      server {
        listen 443 ssl;
        server_name dockhand.lunar.srv;

        location /authelia {
          internal;
          proxy_pass http://authelia:9091/api/verify;
          proxy_pass_request_body off;
          proxy_set_header Content-Length "";
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Original-Method $request_method;
          proxy_set_header X-Forwarded-Method $request_method;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-URI $request_uri;
          proxy_set_header X-Forwarded-For $remote_addr;
        }

        location / {
          auth_request /authelia;
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $groups $upstream_http_remote_groups;
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Groups $groups;

          error_page 401 =302 https://auth.lunar.srv/?rd=$scheme://$http_host$request_uri;

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

      # --- 6. Jellyfin ---
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

      # --- 7. Vaultwarden ---
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

      # --- 8. Uptime Kuma ---
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
    }
  '';

  autheliaConfig = ''
    server:
      address: "tcp://0.0.0.0:9091"
      endpoints:
        enable_pprof: false
        enable_expvars: false

    log:
      level: info
      format: json

    theme: dark

    identity_validation:
      reset_password:
        jwt_secret: ${builtins.hashString "sha256" "m_uvex-authelia-jwt-secret"}

    authentication_backend:
      password_reset:
        disable: true
      file:
        path: /config/users_database.yml
        password:
          algorithm: argon2

    session:
      name: authelia_session
      secret: ${builtins.hashString "sha256" "m_uvex-authelia-session-secret"}
      same_site: lax
      expiration: 1h
      inactivity: 5m
      remember_me: 1M
      cookies:
        - domain: lunar.srv
          authelia_url: https://auth.lunar.srv
          default_redirection_url: https://auth.lunar.srv

    storage:
      encryption_key: ${builtins.hashString "sha256" "m_uvex-authelia-storage-key"}
      local:
        path: /data/db.sqlite

    notifier:
      filesystem:
        filename: /data/notification.txt

    access_control:
      default_policy: deny
      rules:
        - domain: auth.lunar.srv
          policy: bypass
        - domain:
            - "*.lunar.srv"
          policy: one_factor

    regulation:
      max_retries: 3
      find_time: 10m
      ban_time: 15m
  '';

  usersDatabase = ''
    users:
      # Temporary admin user (username: admin, password: admin)
      admin:
        displayname: "Admin"
        password: "$argon2id$v=19$m=65536,t=3,p=4$LEhLJo7X72FgWaSjuTxy9A$YcZP2y2M3/MQvoijSGu2zgPFuUjD5bMKLqe/KFRh1fI"
        email: admin@lunar.srv
        groups:
          - admins
          - dev
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
        networks:
          - authelia-net
        depends_on:
          - authelia

      authelia:
        image: authelia/authelia:latest
        container_name: authelia
        restart: unless-stopped
        ports:
          - "9091:9091"
        volumes:
          - /srv/infra/authelia/configuration.yml:/config/configuration.yml:ro
          - /srv/infra/authelia/users_database.yml:/config/users_database.yml:ro
          - /srv/infra/authelia/data:/data
        environment:
          - TZ=Europe/Istanbul
          - AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET=${builtins.hashString "sha256" "m_uvex-authelia-jwt-secret"}
          - AUTHELIA_SESSION_SECRET=${builtins.hashString "sha256" "m_uvex-authelia-session-secret"}
          - AUTHELIA_STORAGE_ENCRYPTION_KEY=${builtins.hashString "sha256" "m_uvex-authelia-storage-key"}
        networks:
          - authelia-net
        healthcheck:
          test: ["CMD", "wget", "--spider", "-q", "http://localhost:9091/api/health"]
          interval: 30s
          timeout: 10s
          retries: 3

    networks:
      authelia-net:
        driver: bridge
  '';

in
{
  environment.etc."stacks/infra/docker-compose.yml".text = composeContent;
  environment.etc."infra/authelia/configuration.yml".text = autheliaConfig;
  environment.etc."infra/authelia/users_database.yml".text = usersDatabase;
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
    "d /srv/infra/authelia 0755 root root -"
    "d /srv/infra/authelia/data 0755 1000 1000 -"
    "d /srv/infra/nginx 0755 root root -"
    "d /srv/infra/nginx/certs 0755 root root -"
    "L+ /srv/stacks/infra/docker-compose.yml - - - - /etc/stacks/infra/docker-compose.yml"
    "L+ /srv/infra/authelia/configuration.yml - - - - /etc/infra/authelia/configuration.yml"
    "L+ /srv/infra/authelia/users_database.yml - - - - /etc/infra/authelia/users_database.yml"
    "L+ /srv/infra/nginx/nginx.conf - - - - /etc/infra/nginx/nginx.conf"
  ];
}
