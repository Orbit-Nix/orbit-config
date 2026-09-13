{ ... }:

let
  composeContent = ''
    name: infra

    services:
      nginx:
        image: nginx:alpine
        container_name: nginx
        restart: unless-stopped
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - /srv/infra/nginx:/etc/nginx/conf.d
          - /srv/infra/nginx/certs:/etc/nginx/certs
        extra_hosts:
          - "host.docker.internal:host-gateway"

      authelia:
        image: authelia/authelia:latest
        container_name: authelia
        restart: unless-stopped
        ports:
          - "9091:9091"
        volumes:
          - /srv/infra/authelia:/config
        environment:
          - TZ=Europe/Istanbul
          - AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET=change_me_hmac_secret_32_chars
          - AUTHELIA_JWT_SECRET=change_me_jwt_secret_32_chars
          - AUTHELIA_SESSION_SECRET=change_me_session_secret_32_chars
          - AUTHELIA_STORAGE_ENCRYPTION_KEY=change_me_storage_key_32_chars
        depends_on:
          - redis
          - lldap

      lldap:
        image: lldap/lldap:latest-alpine
        container_name: lldap
        restart: unless-stopped
        ports:
          - "17170:17170"
          - "3890:3890"
        volumes:
          - /srv/infra/lldap:/data
        environment:
          - TZ=Europe/Istanbul
          - LLDAP_HTTP_PORT=17170
          - LLDAP_LDAP_PORT=3890
          - LLDAP_JWT_SECRET=change_me_lldap_jwt_secret
          - LLDAP_LDAP_USER_PASS=adminpassword
          - LLDAP_LDAP_BASE_DN=dc=home,dc=arpa

      redis:
        image: redis:alpine
        container_name: redis
        restart: unless-stopped
        volumes:
          - /srv/infra/redis:/data

      pihole:
        image: pihole/pihole:latest
        container_name: pihole
        restart: unless-stopped
        ports:
          - "53:53/tcp"
          - "53:53/udp"
          - "8081:80"
        volumes:
          - /srv/infra/pihole/etc-pihole:/etc/pihole
          - /srv/infra/pihole/etc-dnsmasq.d:/etc/dnsmasq.d
        environment:
          - TZ=Europe/Istanbul
  '';

  autheliaConfig = ''
    server:
      host: 0.0.0.0
      port: 9091

    log:
      level: info

    theme: dark

    identity_validation:
      reset_password:
        jwt_secret: change_me_jwt_secret_32_chars

    authentication_backend:
      ldap:
        implementation: custom
        address: ldap://lldap:3890
        base_dn: dc=home,dc=arpa
        additional_users_dn: ou=people
        additional_groups_dn: ou=groups
        user: cn=admin,ou=people,dc=home,dc=arpa
        password: adminpassword
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
  '';
in
{
  environment.etc."stacks/infra/docker-compose.yml".text = composeContent;
  environment.etc."infra/authelia/configuration.yml".text = autheliaConfig;

  systemd.tmpfiles.rules = [
    "d /srv/stacks/infra 0755 root root -"
    "d /srv/infra/authelia 0755 root root -"
    "d /srv/infra/lldap 0755 root root -"
    "L+ /srv/stacks/infra/docker-compose.yml - - - - /etc/stacks/infra/docker-compose.yml"
    "L+ /srv/infra/authelia/configuration.yml - - - - /etc/infra/authelia/configuration.yml"
  ];
}