{ config, pkgs, ... }:

let
  autheliaConfig = ''
    server:
      host: 0.0.0.0
      port: 9091
      path: ""
      enable_pprof: false
      enable_expvars: false
      log:
        level: info
        format: json
      tls:
        certificate: /config/certs/cert.pem
        key: /config/certs/key.pem

    log:
      level: info
      format: json

    authentication_backend:
      password_reset:
        disable: false
      ldap:
        implementation: custom
        address: ldap://lldap:3890
        base_dn: dc=home,dc=arpa
        additional_users_dn: ou=people
        additional_groups_dn: ou=groups
        user: cn=admin,ou=people,dc=home,dc=arpa
        password: $argon2id$v=19$m=19456,t=2,p=1$yZlPAmR+2kYuth2wW3yeZw$aZvw8rUb3HmedHpJr+aTaVQ2MsnfFNlKbErDQIPFV0A
        users_filter: (&({username_attribute}={input})(objectClass=person))
        groups_filter: (member={dn})
        user_attribute: uid

    session:
      name: authelia_session
      same_site: lax
      expiration: 1h
      inactivity: 5m
      remember_me: 1M
      cookies:
        - domain: home.arpa
          authelia_url: https://auth.home.arpa

    storage:
      local:
        path: /config/db.sqlite

    notifier:
      filesystem:
        filename: /config/notification.txt

    identity_providers:
      oidc:
        cors:
          endpoints:
            - authorization
            - token
            - revocation
            - userinfo
          allowed_origins_exact:
            - https://gitea.home.arpa
            - https://immich.home.arpa

    access_control:
      default_policy: deny
      rules:
        - domain: auth.home.arpa
          policy: bypass
        - domain: gitea.home.arpa
          policy: one_factor
        - domain: immich.home.arpa
          policy: one_factor

    regulation:
      max_retries: 3
      find_time: 10m
      ban_time: 15m
  '';

  lldapConfig = ''
    http_url: https://lldap.home.arpa
    http_host: 0.0.0.0
    http_port: 17170
    ldap_host: 0.0.0.0
    ldap_port: 3890
    ldap_base_dn: dc=home,dc=arpa
    ldap_user_dn: ou=people
    ldap_group_dn: ou=groups
    database_url: sqlite:///data/lldap.sqlite?mode=rwc
    key_file: /data/private_key
    jwt_secret: ${builtins.hashString "sha256" "m_uvex-home-arpa-jwt-secret"}
    verbose: false
    log_level: info
  '';

  composeContent = ''
    version: '3.8'

    services:
      lldap:
        image: lldap/lldap:latest
        container_name: lldap
        environment:
          - LLDAP_LDAP_BASE_DN=dc=home,dc=arpa
          - LLDAP_LDAP_USER_DN=ou=people
          - LLDAP_LDAP_GROUP_DN=ou=groups
          - LLDAP_LDAP_PORT=3890
          - LLDAP_HTTP_PORT=17170
          - LLDAP_HTTP_URL=https://lldap.home.arpa
          - LLDAP_LDAP_USER_PASS=$argon2id$v=19$m=19456,t=2,p=1$yZlPAmR+2kYuth2wW3yeZw$aZvw8rUb3HmedHpJr+aTaVQ2MsnfFNlKbErDQIPFV0A
          - LLDAP_SEED_USERNAME=m_uvex
          - LLDAP_SEED_EMAIL=musamurado@proton.me
          - LLDAP_SEED_PASSWORD_HASH=$argon2id$v=19$m=19456,t=2,p=1$yZlPAmR+2kYuth2wW3yeZw$aZvw8rUb3HmedHpJr+aTaVQ2MsnfFNlKbErDQIPFV0A
        ports:
          - "3890:3890"
          - "17170:17170"
        volumes:
          - /srv/infra/lldap/data:/data
        networks:
          - authelia-net
        restart: unless-stopped
        healthcheck:
          test: ["CMD", "curl", "-f", "http://localhost:17170/health"]
          interval: 30s
          timeout: 10s
          retries: 3

      authelia:
        image: authelia/authelia:latest
        container_name: authelia
        environment:
          - TZ=Europe/Istanbul
        volumes:
          - /srv/infra/authelia/configuration.yml:/config/configuration.yml:ro
          - /srv/infra/authelia/certs:/config/certs:ro
          - /srv/infra/authelia/db:/config
        ports:
          - "9091:9091"
        networks:
          - authelia-net
        depends_on:
          lldap:
            condition: service_healthy
        restart: unless-stopped
        healthcheck:
          test: ["CMD", "curl", "-f", "http://localhost:9091/api/health"]
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

  systemd.tmpfiles.rules = [
    "d /srv/stacks/infra 0755 root root -"
    "d /srv/infra/authelia 0755 root root -"
    "d /srv/infra/lldap 0755 root root -"
    "d /srv/infra/authelia/certs 0700 root root -"
    "d /srv/infra/authelia/db 0700 root root -"
    "d /srv/infra/lldap/data 0700 root root -"
    "L+ /srv/stacks/infra/docker-compose.yml - - - - /etc/stacks/infra/docker-compose.yml"
    "L+ /srv/infra/authelia/configuration.yml - - - - /etc/infra/authelia/configuration.yml"
  ];
}