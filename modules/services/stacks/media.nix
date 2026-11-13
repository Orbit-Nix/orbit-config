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

      seerr:
        image: ghcr.io/seerr-team/seerr:latest
        container_name: seerr
        restart: unless-stopped
        ports:
          - "5055:5055"
        volumes:
          - /srv/apps/arr-stack/seerr:/app/config
        environment:
          - LOG_LEVEL=info
          - TZ=Europe/Istanbul
          - PORT=5055

      bazarr:
        image: lscr.io/linuxserver/bazarr:latest
        container_name: bazarr
        restart: unless-stopped
        ports:
          - "6767:6767"
        volumes:
          - /srv/apps/arr-stack/bazarr:/config
          - /srv/data:/data
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

      aria2:
        image: p3terx/aria2-pro:latest
        container_name: aria2
        restart: unless-stopped
        ports:
          - "6800:6800"
          - "6888:6888"
          - "6888:6888/udp"
        volumes:
          - /srv/apps/arr-stack/aria2:/config
          - /srv/data/downloads:/downloads
        environment:
          - PUID=1000
          - PGID=1050
          - UMASK=022
          - TZ=Europe/Istanbul
          - RPC_PORT=6800
          - LISTEN_PORT=6888
          - ENABLE_IPV6=false

      ariang:
        image: p3terx/ariang:latest
        container_name: ariang
        restart: unless-stopped
        ports:
          - "6880:6880"
        environment:
          - PUID=1000
          - PGID=1050
          - TZ=Europe/Istanbul

      byparr:
        image: ghcr.io/thephaseless/byparr:latest
        container_name: byparr
        restart: unless-stopped
        shm_size: "1gb"
        tmpfs:
          - /tmp:exec,mode=1777,size=1G
        ports:
          - "8191:8191"
        environment:
          - TZ=Europe/Istanbul
  '';
in
{
  environment.etc."stacks/media/docker-compose.yml".text = composeContent;

  systemd.tmpfiles.rules = [
    "d /srv/stacks/media 0755 root root -"
    "d /srv/apps/jellyfin 0755 1000 1050 -"
    "d /srv/apps/arr-stack/seerr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/bazarr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/radarr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/sonarr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/prowlarr 0755 1000 1050 -"
    "d /srv/apps/arr-stack/aria2 0755 1000 1050 -"
    "d /srv/data/media 0775 1000 1050 -"
    "d /srv/data/downloads 0775 1000 1050 -"
    "L+ /srv/stacks/media/docker-compose.yml - - - - /etc/stacks/media/docker-compose.yml"
  ];
}
