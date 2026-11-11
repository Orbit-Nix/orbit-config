{ ... }:

let
  composeContent = ''
    name: media

    services:
      jellyfin:
        image: jellyfin/jellyfin:latest
        container_name: jellyfin
        restart: unless-stopped
        devices:
          - /dev/dri:/dev/dri
        ports:
          - "8096:8096"
        volumes:
          - /srv/apps/jellyfin:/config
          - /srv/data/media:/media
          - /srv/data/downloads:/downloads
        environment:
          - TZ=Europe/Istanbul
          - JELLYFIN_PublishedServerUrl=http://srv-c4030-nix:8096
        group_add:
          - "1050"

      seerrng:
        image: ghcr.io/snapetech-org/seerrng:latest
        container_name: seerrng
        restart: unless-stopped
        security_opt:
          - no-new-privileges:true
        cap_drop:
          - ALL
        ports:
          - "5055:5055"
        volumes:
          - /srv/apps/arr-stack/seerrng:/app/config
        environment:
          - LOG_LEVEL=info
          - TZ=Europe/Istanbul
          - PORT=5055

      lidarr:
        image: lscr.io/linuxserver/lidarr:latest
        container_name: lidarr
        restart: unless-stopped
        ports:
          - "8686:8686"
        volumes:
          - /srv/apps/arr-stack/lidarr:/config
          - /srv/data:/data
          - /srv/data/downloads:/downloads
        environment:
          - PUID=1000
          - PGID=1050
          - UMASK=002
          - TZ=Europe/Istanbul

      radarr:
        image: lscr.io/linuxserver/radarr:latest
        container_name: radarr
        restart: unless-stopped
        ports:
          - "7878:7878"
        volumes:
          - /srv/apps/arr-stack/radarr:/config
          - /srv/data:/data
        environment:
          - PUID=1000
          - PGID=1050
          - UMASK=002
          - TZ=Europe/Istanbul

      sonarr:
        image: lscr.io/linuxserver/sonarr:latest
        container_name: sonarr
        restart: unless-stopped
        ports:
          - "8989:8989"
        volumes:
          - /srv/apps/arr-stack/sonarr:/config
          - /srv/data:/data
        environment:
          - PUID=1000
          - PGID=1050
          - UMASK=002
          - TZ=Europe/Istanbul

      prowlarr:
        image: lscr.io/linuxserver/prowlarr:latest
        container_name: prowlarr
        restart: unless-stopped
        ports:
          - "9696:9696"
        volumes:
          - /srv/apps/arr-stack/prowlarr:/config
        environment:
          - PUID=1000
          - PGID=1050
          - UMASK=002
          - TZ=Europe/Istanbul

      qbittorrent:
        image: lscr.io/linuxserver/qbittorrent:latest
        container_name: qbittorrent
        restart: unless-stopped
        ports:
          - "8080:8080"
          - "6881:6881"
          - "6881:6881/udp"
        volumes:
          - /srv/apps/arr-stack/qbittorrent:/config
          - /srv/data/downloads:/downloads
        environment:
          - PUID=1000
          - PGID=1050
          - UMASK=002
          - TZ=Europe/Istanbul
          - WEBUI_PORT=8080
  '';
in
{
  environment.etc."stacks/media/docker-compose.yml".text = composeContent;

  systemd.tmpfiles.rules = [
    "d /srv/stacks/media 0755 root root -"
    "d /srv/apps/jellyfin 0755 1000 1050 -"
    "d /srv/apps/arr-stack/seerrng 0755 1000 1050 -"
    "d /srv/apps/arr-stack/lidarr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/radarr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/sonarr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/prowlarr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/qbittorrent 0755 1000 1050 -"
    "d /srv/data/media 0775 1000 1050 -"
    "d /srv/data/media/music 0775 1000 1050 -"
    "d /srv/data/downloads 0775 1000 1050 -"
    "L+ /srv/stacks/media/docker-compose.yml - - - - /etc/stacks/media/docker-compose.yml"
  ];
}