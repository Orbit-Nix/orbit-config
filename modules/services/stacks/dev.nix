{ ... }:

let
  composeContent = ''
    name: dev

    services:
      pocketbase:
        image: ghcr.io/muchobien/pocketbase:latest
        container_name: pocketbase
        restart: unless-stopped
        ports:
          - "8090:8090"
        networks:
          pocketbase_net:
            ipv4_address: 172.28.0.2
          default: {}
        volumes:
          - /srv/apps/pocketbase/pb_data:/pb_data
          - /srv/apps/pocketbase/pb_public:/pb_public
        environment:
          - TZ=Europe/Istanbul

      cloudflared:
        image: cloudflare/cloudflared:latest
        container_name: cloudflared
        restart: unless-stopped
        depends_on:
          - pocketbase
        command: tunnel --no-autoupdate run --token eyJhIjoiMGEyZGZjYjVhMjdmNDhlYWFhZjc4N2QzNTQ3NDg1NjUiLCJ0IjoiNjQ3ZDcyN2MtZjA0Ny00NjljLWJmMTgtMmFmNzc0YTA5N2ZhIiwicyI6Ik9UUTJaREUyTkdZdE1tTXdNUzAwTWpNeExXRTVZell0TkRRNVl6bGpPV016TjJNMyJ9
        networks:
          pocketbase_net:
            ipv4_address: 172.28.0.3

      gitea:
        image: gitea/gitea:latest
        container_name: gitea
        restart: unless-stopped
        ports:
          - "3001:3000"
          - "2222:22"
        volumes:
          - /srv/apps/gitea:/data
          - /etc/localtime:/etc/localtime:ro
        environment:
          - USER_UID=1000
          - USER_GID=1000

      it-tools:
        image: corentinth/it-tools:latest
        container_name: it_tools
        restart: unless-stopped
        ports:
          - "8084:80"

      homepage:
        image: ghcr.io/gethomepage/homepage:latest
        container_name: homepage
        restart: unless-stopped
        ports:
          - "8083:3000"
        volumes:
          - /srv/apps/homepage:/app/config
          - /var/run/docker.sock:/var/run/docker.sock:ro
        environment:
          - TZ=Europe/Istanbul
          - HOMEPAGE_ALLOWED_HOSTS=homepage.lunar.srv,lunar.srv,localhost:3000,100.100.5.5:8083

      uptime-kuma:
        image: louislam/uptime-kuma:latest
        container_name: uptime_kuma
        restart: unless-stopped
        ports:
          - "3002:3001"
        networks:
          pocketbase_net:
            ipv4_address: 172.28.0.5
          default: {}
        volumes:
          - /srv/apps/uptime-kuma:/app/data
        environment:
          - TZ=Europe/Istanbul

      # Glyphix Discord bot (commented out for now)
      # glyphix-discord-bot:
      #   image: discord-bot:latest
      #   container_name: glyphix-discord-bot
      #   restart: unless-stopped
      #   environment:
      #     - DISCORD_TOKEN=''${DISCORD_TOKEN} # Uses dockhand to inject the token

    networks:
      pocketbase_net:
        driver: bridge
        ipam:
          config:
            - subnet: 172.28.0.0/16
  '';
in
{
  environment.etc."stacks/dev/docker-compose.yml".text = composeContent;

  systemd.tmpfiles.rules = [
    "d /srv/stacks/dev 0755 root root -"
    "d /srv/apps/homepage 0755 root root -"
    "d /srv/apps/uptime-kuma 0755 root root -"
    "d /srv/apps/pocketbase/pb_data 0770 1000 1000 -"
    "d /srv/apps/pocketbase/pb_public 0770 1000 1000 -"
    "d /srv/apps/gitea 0770 1000 1000 -"
    "L+ /srv/stacks/dev/docker-compose.yml 0644 root root - /etc/stacks/dev/docker-compose.yml"
  ];
}