{ pkgs, lib, ... }:

{
  imports = [
    # Hardware
    ../../modules/hardware/universal-hardware-configuration.nix
    ../../modules/hardware/default.nix
    ../../modules/hardware/swap.nix
    ../../modules/hardware/universal-cpu.nix
    ../../modules/hardware/universal-gpu.nix

    # Users
    ../../users/m_uvex
    ../../users/incognito

    # Modules
    ../../modules/core
    ../../modules/desktop
    ../../modules/desktop/apps.nix
    ../../modules/desktop/gaming.nix
    ../../modules/desktop/remote-desktop/client.nix
  ];

  # --- HOST CONFIGURATION ---
  networking.hostName = "prt-roam-nix";
  system.stateVersion = "24.05";

  # --- DESKTOP SHELL SELECTION ---
  # Choices: "end4-pC" | "midnight" | "dms" | "none"
  mySystem.desktop.shell = "end4-pC";

  # --- INSTALLED APPS ---
  mySystem.apps = {
    enable = true;

    browsers = [
      "zen"
      "ungoogled"
    ];

    fileManagers = [
      "dolphin"
    ];

    ides = [
      "vscode"
      "idea"
    ];

    ais = [
      "antigravity"
      "opencode"
      "ollama"
    ];

    messaging = true;
    media = false;
    sync = true;
  };

  # --- INSTALLED GAMING APPS ---
  mySystem.gaming = {
    enable = false;

    optimizations = true;
    controllers = true;

    launchers = [
    ];

    minecraft = [
    ];

    emulators = [ ];

    tools = [
    ];
  };
}
