{ config, pkgs, ... }:

{
  imports = [
    ./infra.nix
    ./media.nix
    ./cloud.nix
    ./dev.nix
  ];

  # --- DOCKER COMPOSE STACK SERVICES ---
  # Automatically start docker-compose stacks via systemd

  systemd.services.docker-compose-infra = {
    description = "Docker Compose Infrastructure Stack";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      TimeoutStartSec = "600s";
      TimeoutStopSec = "180s";
      WorkingDirectory = "/srv/stacks/infra";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
    restartTriggers = [ config.environment.etc."stacks/infra/docker-compose.yml".source ];
  };

  systemd.services.docker-compose-media = {
    description = "Docker Compose Media Stack";
    after = [ "docker.service" "docker-compose-infra.service" ];
    requires = [ "docker.service" "docker-compose-infra.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      TimeoutStartSec = "600s";
      TimeoutStopSec = "180s";
      WorkingDirectory = "/srv/stacks/media";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
    restartTriggers = [ config.environment.etc."stacks/media/docker-compose.yml".source ];
  };

  systemd.services.docker-compose-cloud = {
    description = "Docker Compose Cloud Stack";
    after = [ "docker.service" "docker-compose-infra.service" ];
    requires = [ "docker.service" "docker-compose-infra.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      TimeoutStartSec = "600s";
      TimeoutStopSec = "180s";
      WorkingDirectory = "/srv/stacks/cloud";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
    restartTriggers = [ config.environment.etc."stacks/cloud/docker-compose.yml".source ];
  };

  systemd.services.docker-compose-dev = {
    description = "Docker Compose Development Stack";
    after = [ "docker.service" "docker-compose-infra.service" ];
    requires = [ "docker.service" "docker-compose-infra.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      TimeoutStartSec = "600s";
      TimeoutStopSec = "180s";
      WorkingDirectory = "/srv/stacks/dev";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
    restartTriggers = [ config.environment.etc."stacks/dev/docker-compose.yml".source ];
  };
}
