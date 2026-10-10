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
    ../../modules/core.nix
    ../../modules/desktop
    ../../modules/desktop/software/apps.nix
    ../../modules/desktop/software/gaming.nix
    #../../modules/desktop/ollama.nix
    ../../modules/desktop/remote-desktop/client.nix
  ];

  # --- HOST CONFIGURATION ---
  networking.hostName = "lt-hp15-nix";
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
      ide = [ "idea" "android-studio" ];
      terminals = [ "kitty" ];
      ai = [ "antigravity" "opencode" "opendesign" "ollama" ];
    };

    system = {
      fileManagers = [ "nautilus" "dolphin" ];
      utilities = [ "flatseal" "mission-center" ];
    };

    office = {
      suites = [ "wordcraft" "deckcraft" "gridcraft" ];
      notes = [ "obsidian" ];
      utilities = [ "pdfcraft" ];
    };

    graphics = {
      raster = [ "gimp" "krita" "photocraft" "lightcraft" ];
      vector = [ "inkscape" "vectorcraft" "designcraft" ];
      cad = [ "fusion360" "cadcraft" ];
    };

    media = {
      broadcasting = [ "obs-studio" ];
      streaming = [ "stremio" "pear-desktop" ];
      players = [ "feishin" "vacuum-tube" ];
      production = [ "filmcraft" "effectcraft" "soundcraft" ];
    };
  };
  # --- INSTALLED GAMING APPS ---
  mySystem.gaming = {
    enable = true;

    optimizations = true;
    controllers = true;
    deckyLoader = true;

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
