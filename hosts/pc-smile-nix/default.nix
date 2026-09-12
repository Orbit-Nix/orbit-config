{ pkgs, lib, ... }:

{
  imports = [
    # Hardware (temporarily disabled)
    #./hardware-configuration.nix
    ../../modules/hardware/swap.nix
    ../../modules/hardware/default.nix
    #../../modules/hardware/amd-cpu.nix
    #../../modules/hardware/nvidia-desktop.nix

    # Temporarily point to laptop hardware for testing
    ../lt-hp15-nix/hardware-configuration.nix
    ../../modules/hardware/nvidia-hybrid.nix
    ../../modules/hardware/intel-cpu.nix
    # ------------------------------------------------

    # Users
    ../../users/m_uvex

    # Modules
    ../../modules/core
    ../../modules/desktop
    ../../modules/desktop/apps.nix
    ../../modules/desktop/gaming.nix
    #../../modules/desktop/ollama.nix
    ../../modules/desktop/remote-desktop/host.nix
  ];

  # --- HOST CONFIGURATION ---
  networking.hostName = "pc-smile-nix";
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
      "vscode"
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