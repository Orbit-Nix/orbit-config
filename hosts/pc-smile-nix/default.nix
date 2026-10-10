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
    ../../modules/core.nix
    ../../modules/desktop
    ../../modules/desktop/software/apps.nix
    ../../modules/desktop/software/gaming.nix
    #../../modules/desktop/ollama.nix
    ../../modules/desktop/remote-desktop/host.nix
  ];

  # --- HOST CONFIGURATION ---
  networking.hostName = "pc-smile-nix";
  system.stateVersion = "24.05";

  # --- DESKTOP SHELL SELECTION ---
  # Choices: "end4-pC" | "midnight" | "dms" | "none"
  mySystem.desktop.shell = "end4-pC";

  # --- INSTALLED APPS ---
  mySystem.apps = {
    enable = true;

    network = {
      browsers = [ "zen" "ungoogled" ];
      messaging = [ "beeper" "vesktop" "signal" ];
      sharing = [ "localsend" "rquickshare" ];
      vpn = [ "trayscale" "proton-vpn" ];
      remote = [ "scrcpy" "android-tools" ];
    };

    development = {
      ide = [ "idea" "vscode" "android-studio" ];
      terminals = [ "kitty" ];
      ai = [ "antigravity" "opencode" "ollama" ];
    };

    system = {
      fileManagers = [ "nautilus" "dolphin" ];
      utilities = [ "flatseal" "mission-center" ];
    };

    office = {
      notes = [ "obsidian" ];
    };

    graphics = {
      raster = [ "gimp" "krita" ];
      vector = [ "inkscape" ];
    };

    media = {
      broadcasting = [ "obs-studio" ];
      streaming = [ "stremio" "pear-desktop" ];
      players = [ "feishin" "vacuum-tube" ];
    };
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
