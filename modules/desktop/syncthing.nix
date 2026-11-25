{ ... }:

let
  home = "/home/m_uvex";
in
{
  # --- SYNCTHING (TAILSCALE ONLY) ---
  # 22000 stays closed in the firewall; reachable only via trusted tailscale0
  services.syncthing = {
    enable = true;
    user = "m_uvex";
    group = "users";
    dataDir = home;
    configDir = "${home}/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = false;
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      options = {
        listenAddresses = [ "tcp://0.0.0.0:22000" ];
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };

      devices = {
        "mb-np3ap-nos" = {
          id = "GAQRDSQ-OAKL5XC-NX5KNU7-O2X6TKK-5KTLQ2O-U6RMFRC-IJK5O2X-XHV2XQN";
          addresses = [ "tcp://100.100.5.20:22000" ];
        };
      };

      folders = {
        "obsidian-main-vault" = {
          label = "Obsidian Main Vault";
          path = "${home}/Documents/Obsidian/Main Vault";
          devices = [ "mb-np3ap-nos" ];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
