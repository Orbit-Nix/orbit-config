{ pkgs, lib, ... }:

{
  # --- RESTIC REST BACKUP SERVER ---
  services.restic.server = {
    enable = true;
    listenAddress = "0.0.0.0:8000";
    dataDir = "/srv/data/backups/restic";
    appendOnly = true;
    privateRepos = false;
  };

  networking.firewall.allowedTCPPorts = [ 8000 ];
}
