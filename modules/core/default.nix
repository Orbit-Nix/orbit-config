{ config, pkgs, inputs, ... }:

{
  imports = [
    ../hardware
    ./rebuild.nix
  ];

  # --- SSH SERVER & CLIENT INFRASTRUCTURE ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
    openFirewall = true;
  };

  programs.ssh = {
    extraConfig = ''
      Host *
        IdentityFile ~/.ssh/id_ed25519
        IdentityFile ~/.ssh/m_uvex

      Host lunar
        HostName srv-c4030-nix
        User m_uvex
        ForwardAgent yes

      Host andromeda
        HostName pc-main-nix
        User m_uvex
        ForwardAgent yes

      Host orion
        HostName lt-hp15-nix
        User m_uvex
        ForwardAgent yes
    '';
  };

  # --- CORE PACKAGES & SHELL ---
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    # Filesystem support
    ntfs3g
    exfatprogs
    dosfstools
    rsync
    gparted

    # CLI tools
    git
    micro
    zoxide
    tree
    fastfetch
    bat
    age
    trashy
    btop
    fd
    home-manager
    wget
    curl
    jq
    socat
    tailscale
    wakeonlan
  ];

  # --- BOOT & NIX SYSTEM SETTINGS ---
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      gnome-icon-theme = final.adwaita-icon-theme;
    })
  ];

  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "daily";
  system.autoUpgrade.flake = inputs.self.outPath;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- NIX HELPER (NH) ---
  programs.nh = {
    enable = true;
    flake = "/orbitos";
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };

  # --- NETWORKING BASE ---
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  services.tailscale.enable = true;

  # WoL alias for pc-smile-nix (wake-pc via Lunar)
  environment.shellAliases = {
    wake-pc = "ssh lunar 'wakeonlan 00:11:22:33:44:55'";
  };
}