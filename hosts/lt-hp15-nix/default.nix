{ pkgs, lib, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ../../modules/hardware/default.nix
    ../../modules/hardware/swap.nix
    ../../modules/hardware/intel-cpu.nix
    ../../modules/hardware/intel-integrated.nix
    ../../modules/hardware/nvidia-hybrid.nix

    # Users
    ../../users/m_uvex

    # Modules
    ../../modules/core
    ../../modules/desktop
    ../../modules/desktop/apps.nix
    ../../modules/desktop/gaming.nix
    #../../modules/desktop/ollama.nix
    ../../modules/desktop/remote-desktop/client.nix
  ];

  # --- HOST CONFIGURATION ---
  networking.hostName = "lt-hp15-nix";
  system.stateVersion = "24.05";

  # --- INSTALLED APPS ---
  mySystem.apps = {
    enable = true;

    browsers = [
      "zen"
      "ungoogled"
    ];

    fileManagers = [
      "nautilus"
      "dolphin"
    ];

    ides = [
      "idea"
      "android-studio"
    ];

    ais = [
      "antigravity"
      "opencode"
      "ollama"
    ];

    messaging = true;
    media = true;
    sync = true;
  };

  # --- INSTALLED GAMING APPS ---
  mySystem.gaming = {
    enable = true;

    optimizations = true;
    controllers = true;

    launchers = [
      "steam"
      "heroic"
      "hydra"
      "sober"
    ];

    minecraft = [
      "prism"
      "lunar"
      "bedrock"
      "modrinth"
    ];

    emulators = [ ];

    tools = [
      "mangohud"
      "dualsensectl"
      "protonup-qt"
    ];
  };
}