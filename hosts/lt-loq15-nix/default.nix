{ config, pkgs, lib, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ../../modules/hardware/default.nix
    ../../modules/hardware/swap.nix
    ../../modules/hardware/amd-cpu.nix
    ../../modules/hardware/amd-gpu.nix
    ../../modules/hardware/nvidia-hybrid.nix

    # Users
    ../../users/m_uvex

    # Modules
    ../../modules/core.nix
    ../../modules/desktop
    ../../modules/desktop/software/apps.nix
    ../../modules/desktop/software/gaming.nix
    ../../modules/desktop/software/waydroid/minimal.nix
    ../../modules/desktop/software/waydroid/gaming.nix
    ../../modules/desktop/ollama.nix
    ../../modules/desktop/remote-desktop/client.nix
    ../../modules/desktop/syncthing.nix
  ];

  # --- HOST CONFIGURATION ---
  networking.hostName = "lt-loq15-nix";
  networking.hosts = {
    "100.100.5.5" = [
      "homepage.lunar.srv"
      "lunar.srv"
      "gitea.lunar.srv"
      "immich.lunar.srv"
      "dockhand.lunar.srv"
      "jellyfin.lunar.srv"
      "vault.lunar.srv"
      "vaultwarden.lunar.srv"
      "uptime.lunar.srv"
      "cloud.lunar.srv"
      "jellyseerr.lunar.srv"
      "seerr.lunar.srv"
      "aria.lunar.srv"
      "ariang.lunar.srv"
      "bazarr.lunar.srv"
      "it-tools.lunar.srv"
      "tools.lunar.srv"
      "karakeep.lunar.srv"
      "hoarder.lunar.srv"
    ];
  };
  system.stateVersion = "24.05";

  # --- NVIDIA DRIVER OVERRIDE ---
  # RTX 5050 (Blackwell/GB207M) uses current drivers and strictly REQUIRES the open kernel modules
  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.open = lib.mkForce true;
  # Blackwell supports finegrained RTD3 power management
  hardware.nvidia.powerManagement.finegrained = lib.mkForce true;

  # --- LID & POWER BUTTON ---
  # Lid closed keeps running. Power button sleeps; holding it is the firmware hard-off.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "ignore";
  };

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
      remote = [ "scrcpy" "android-tools" "nectarlink" ];
    };

    development = {
      ide = [ "idea" ];
      terminals = [ "kitty" ];
      ai = [ "antigravity" "claude-code" "opencode" "opendesign" "ollama" "freebuff" "qwen-code" ];
    };

    system = {
      fileManagers = [ "loaf" "nautilus" "dolphin" ];
      utilities = [ "flatseal" "mission-center" ];
    };

    office = {
      suites = [ "wordcraft" "deckcraft" "gridcraft" "libreoffice" ];
      notes = [ "obsidian" ];
      utilities = [ "pdfcraft" ];
    };

    graphics = {
      raster = [ "gimp" "krita" "photocraft" "lightcraft" ];
      vector = [ "inkscape" "vectorcraft" "designcraft" ];
      cad = [ "cadcraft" ];
    };

    media = {
      broadcasting = [ "obs-studio" ];
      streaming = [ "stremio" "pear-desktop" ];
      players = [ "feishin" "vacuum-tube" ];
      production = [ "filmcraft" "effectcraft" "soundcraft" "davinci-resolve" ];
    };
  };
  # --- WAYDROID ---
  mySystem.waydroid.gaming.enable = false;

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
      "geforcenow"
    ];

    minecraft = [
      "prism"
      "lunar"
      "bedrock"
      "modrinth"
      "gdlauncher"
      "horizon"
    ];

    emulators = [ ];

    tools = [
      "mangohud"
      "dualsensectl"
      "protonup-qt"
    ];
  };
}
