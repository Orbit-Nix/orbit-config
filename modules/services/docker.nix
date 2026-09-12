{ pkgs, ... }:

{
  # --- DOCKER ENGINE CONFIGURATION ---
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" "--volumes" ];
    };
    daemon.settings = {
      "log-driver" = "json-file";
      "log-opts" = {
        "max-size" = "10m";
        "max-file" = "3";
      };
      "live-restore" = true;
    };
  };

  # Add m_uvex to docker group to run docker CLI without sudo
  users.users.m_uvex.extraGroups = [ "docker" ];

  # Docker CLI & Terminal GUI Utilities
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
    ctop
  ];

  # --- DOCKHAND CONFIGURATION ---
  # Create dockhand config file declaratively
  environment.etc."dockhand/config.yml".text = ''---
server:
  port: 3000

environments:
  - name: Local Docker
    socket: /var/run/docker.sock
    default: true

stacks:
  - path: /stacks/infra
    name: Infrastructure
    description: Core networking, identity, and security services

  - path: /stacks/media
    name: Media
    description: Media server stack (Jellyfin, arr-suite, qBittorrent)

  - path: /stacks/cloud
    name: Cloud
    description: Cloud storage and photo management services

  - path: /stacks/dev
    name: Development
    description: Development and utility services
  '';

  systemd.tmpfiles.rules = [
    "d /var/lib/dockhand 0755 root root -"
    "d /var/lib/dockhand/data 0755 root root -"
    "d /var/lib/dockhand/config 0755 root root -"
    "C+ /var/lib/dockhand/config/config.yml 0644 root root - /etc/dockhand/config.yml"
  ];

  # --- DOCKHAND GUI STACK MANAGER (OCI CONTAINER) ---
  # Automatically starts Dockhand GUI dashboard on port 3000
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      dockhand = {
        image = "fnsys/dockhand:latest";
        autoStart = true;
        ports = [
          "3000:3000"
        ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/var/lib/dockhand/data:/app/data"
          "/var/lib/dockhand/config:/app/config"
          "/srv/stacks:/stacks"
        ];
        environment = {
          TZ = "Europe/Istanbul";
        };
      };
    };
  };
}
