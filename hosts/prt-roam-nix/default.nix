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
    ../../modules/core.nix
    ../../modules/desktop
    ../../modules/desktop/software/apps.nix
    ../../modules/desktop/software/gaming.nix
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

    network = {
      browsers = [ "zen" "ungoogled" ];
      messaging = [ "beeper" "vesktop" "signal-desktop" ];
      sharing = [ "localsend" "rquickshare" ];
      vpn = [ "trayscale" "proton-vpn" ];
      remote = [ "scrcpy" "android-tools" ];
    };

    development = {
      ide = [ "vscode" "idea" ];
      terminals = [ "kitty" ];
      ai = [ "antigravity" "opencode" "ollama" ];
    };

    system = {
      fileManagers = [ "dolphin" ];
      utilities = [ "flatseal" "mission-center" ];
    };

    office = {
      notes = [ "obsidian" ];
    };
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
