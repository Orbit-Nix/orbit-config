{ config, pkgs, inputs, ... }:

let
  gparted = pkgs.gparted.override { withAllTools = true; }; # gparted fix
in

{
  imports = [
    ./hardware
    
  ];

  # --- SSH CONFIG ---
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
        HostName pc-smile-nix
        User m_uvex
        ForwardAgent yes

      Host orion
        HostName lt-hp15-nix
        User m_uvex
        ForwardAgent yes
    '';
  };

  # --- CORE PACKAGES & TERMINAL SHELL ---
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ../config/fish/config.fish;
    vendor = {
      functions.enable = true;
      completions.enable = true;
      config.enable = true;
    };
  };

  environment.etc."fish/functions".source = ../config/fish/functions;

  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    # Orbit CLI
    inputs.orbit-cli.packages.${pkgs.system}.default

    # Fish plugins
    fishPlugins.autopair-fish
    fishPlugins.done
    fishPlugins.fzf-fish

    # Filesystem
    ntfs3g
    exfatprogs
    dosfstools
    rsync
    btrfs-progs
    gparted

    # CLI tools
    git
    micro
    zoxide
    tree
    fastfetch
    bat
    eza
    starship
    fzf
    atuin
    direnv
    yazi
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

  # --- BOOT & SYSTEM SETTINGS ---
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
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  

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
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
  };
  services.tailscale.enable = true;

  # WoL alias for pc-smile-nix (wake-pc via Lunar)
  environment.shellAliases = {
    wake-pc = "ssh lunar 'wakeonlan 00:11:22:33:44:55'";
  };
}
