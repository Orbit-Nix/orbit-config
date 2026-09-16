{ config, pkgs, ... }:

let
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
        - domain: 192.168.5.23
          authelia_url: https://192.168.5.23:9091

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
        - domain: 192.168.5.23
          policy: one_factor
        - domain: gitea.lunar.srv
          policy: one_factor
        - domain: immich.lunar.srv
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

  systemd.tmpfiles.rules = [
    "d /srv/stacks/infra 0755 root root -"
    "d /srv/infra/authelia 0755 root root -"
    "d /srv/infra/authelia/data 0755 1000 1000 -"
    "L+ /srv/stacks/infra/docker-compose.yml - - - - /etc/stacks/infra/docker-compose.yml"
    "L+ /srv/infra/authelia/configuration.yml - - - - /etc/infra/authelia/configuration.yml"
    "L+ /srv/infra/authelia/users_database.yml - - - - /etc/infra/authelia/users_database.yml"
  ];
}