{ config, pkgs, lib, ... }:

let
  lunarPrint = pkgs.writeShellScriptBin "lunar-print" ''
    if [ -n "$1" ]; then
      TEXT="$*"
    else
      TEXT="$(cat)"
    fi
    ${pkgs.curl}/bin/curl -s -X POST http://127.0.0.1:9123/print \
      -H "Content-Type: application/json" \
      -d "$(${pkgs.jq}/bin/jq -n --arg t "$TEXT" '{title: "CLI PRINT", text: $t}')"
  '';

  composeConfig = ''
    services:
      lunar-printer:
        image: python:alpine
        container_name: lunar_printer
        restart: unless-stopped
        network_mode: host
        environment:
          - PRINTER_DEV=/dev/usb/lp0
          - PRINTER_PORT=9123
          - DOCKER_SOCK=/var/run/docker.sock
          - TZ=Europe/Istanbul
        volumes:
          - /srv/apps/lunar-printer/printer.py:/app/printer.py:ro
          - /var/run/docker.sock:/var/run/docker.sock:ro
          - /srv:/srv:ro
        devices:
          - /dev/usb/lp0:/dev/usb/lp0
        command: python3 -u /app/printer.py
  '';
in
{
  # Ensure USB printer has correct permissions on connection
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0456", ATTRS{idProduct}=="0808", MODE="0660", GROUP="lp"
  '';

  # CLI tool to print messages
  environment.systemPackages = [ lunarPrint ];

  # Declarative docker-compose stack
  environment.etc."stacks/printer/docker-compose.yml".text = composeConfig;

  systemd.tmpfiles.rules = [
    "d /srv/stacks/printer 0755 root root -"
    "L+ /srv/stacks/printer/docker-compose.yml - - - - /etc/stacks/printer/docker-compose.yml"
    "d /srv/apps/lunar-printer 0755 m_uvex users -"
  ];

  systemd.services.docker-compose-printer = {
    description = "Docker Compose Lunar Printer Stack";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      TimeoutStartSec = "300s";
      TimeoutStopSec = "60s";
      WorkingDirectory = "/srv/stacks/printer";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
    restartTriggers = [ config.environment.etc."stacks/printer/docker-compose.yml".source ];
  };
}
