{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.mySystem.apps;

  # Helper to resolve host Platform system for flakes
  system = pkgs.stdenv.hostPlatform.system;

  # --- TEMPORARY ---
  # Wrapper script for the flatpak version of IDEA
  # As the official nixpkgs is outdated and i need the latest version.
  # Will be replaced with nixpkgs version once its updated.
  ideaWrapper = pkgs.writeShellScriptBin "idea" ''
    exec flatpak run com.jetbrains.IntelliJ-IDEA-Community "$@"
  '';
  # -----------------

  #==================================#
  #        APPS DICTIONARIES         #
  #==================================#
  browserMap = {
    "zen"                = [ inputs.zen-browser.packages.${system}.default ];
    "firefox"            = pkgs.firefox;
    "librewolf"          = pkgs.librewolf;
    "waterfox"           = pkgs.waterfox;
    "floorp"             = pkgs.floorp;
    "brave"              = pkgs.brave;
    "chromium"           = pkgs.chromium;
    "ungoogled"          = pkgs.ungoogled-chromium;
    "chrome"             = pkgs.google-chrome;
    "vivaldi"            = pkgs.vivaldi;
    "opera"              = pkgs.opera;
    "edge"               = pkgs.microsoft-edge;
    "tor"                = pkgs.tor-browser;
    "helium"             = pkgs.helium-browser;
  };

  ideMap = {
    # "idea"               = pkgs.jetbrains.idea;  # Will be back once it gets updated
    "idea"               = ideaWrapper;            # Temporary
    "pycharm"            = pkgs.jetbrains.pycharm;
    "clion"              = pkgs.jetbrains.clion;
    "webstorm"           = pkgs.jetbrains.webstorm;
    "rider"              = pkgs.jetbrains.rider;
    "goland"             = pkgs.jetbrains.goland;
    "phpstorm"           = pkgs.jetbrains.phpstorm;
    "datagrip"           = pkgs.jetbrains.datagrip;
    "rust-rover"         = pkgs.jetbrains.rust-rover;
    "android-studio"     = pkgs.android-studio;
    "vscode"             = pkgs.vscode;
    "vscodium"           = pkgs.vscodium;
    "zed"                = pkgs.zed-editor;
  };

  aiMap = {
    "cursor"             = pkgs.code-cursor;
    "antigravity"        = [ pkgs.antigravity-cli pkgs.antigravity-ide ];
    "codex"              = pkgs.codex;
    "claude-code"        = pkgs.claude-code;
    "opencode"           = [ pkgs.opencode pkgs.opencode-desktop pkgs.opencode-claude-auth ];
    "ollama"             = pkgs.ollama;
    "chatgpt"            = [ pkgs.chatgpt-desktop pkgs.chatgpt-cli ];
    "warp-terminal"      = pkgs.warp-terminal;
    "windsurf"           = pkgs.windsurf;
    "github-copilot-cli" = pkgs.github-copilot-cli;
  };

  fileManagerMap = {
    "nautilus"           = pkgs.nautilus;
    "nemo"               = pkgs.cinnamon.nemo;
    "dolphin"            = pkgs.kdePackages.dolphin;
    "thunar"             = pkgs.xfce.thunar;
    "pcmanfm"            = pkgs.pcmanfm;
    "yazi"               = pkgs.yazi;
  };

  #==================================#
  #  AUTOMATIC RESOLUTION FUNCTION   #
  #         ( DONT TOUCH!)           #
  #==================================#
    resolveApps = mapObj: selectedKeys:
    lib.concatMap (key:
      let val = mapObj.${key}; in
      if builtins.isList val then val else [ val ]
    ) selectedKeys;

  # Check selections
  hasIdea = builtins.elem "idea" cfg.ides;

in
{
  options.mySystem.apps = {
    enable = lib.mkEnableOption "Desktop core system apps and utilities";

    # Enums are AUTOMATICALLY generated from the dictionary keys!
    browsers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames browserMap));
      default = [ "zen" ];
      description = "List of web browsers to install.";
    };

    ides = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames ideMap));
      default = [ "idea" ];
      description = "List of IDEs and code editors to install.";
    };

    ais = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames aiMap));
      default = [ ];
      description = "List of AI tools, IDEs, and CLI utilities.";
    };

    fileManagers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames fileManagerMap));
      default = [ "nautilus" ];
      description = "List of file managers to install.";
    };

    # Boolean toggles for full feature suites
    messaging = lib.mkEnableOption "Social & messaging clients";
    media     = lib.mkEnableOption "Creative and media software";
    sync      = lib.mkEnableOption "Device sync tools (LocalSend, Scrcpy)";
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;

    # Auto-install Flatpaks
    services.flatpak.packages = lib.optional hasIdea "com.jetbrains.IntelliJ-IDEA-Community";

    environment.systemPackages =
      # Base Utilities & System Tools
      (with pkgs; [
        kitty polkit_gnome playerctl libnotify steam-run
        wl-clipboard grim slurp rofi waybar awww cliphist quickshell
        matugen dart-sass gtk4 adwaita-icon-theme gtk4-layer-shell glib cairo
        python3Packages.pygobject3 python3Packages.pycairo mission-center obsidian
      ])

      # AUTOMATIC SELECTION RESOLUTION
      ++ (resolveApps browserMap cfg.browsers)
      ++ (resolveApps ideMap cfg.ides)
      ++ (resolveApps aiMap cfg.ais)
      ++ (resolveApps fileManagerMap cfg.fileManagers)

      # Optional Bundles
      ++ lib.optionals cfg.messaging (with pkgs; [ beeper vesktop signal-desktop ])
      ++ lib.optionals cfg.media     (with pkgs; [ krita gimp inkscape obs-studio feishin pear-desktop stremio-linux-shell vacuum-tube ])
      ++ lib.optionals cfg.sync      (with pkgs; [ localsend rquickshare trayscale proton-vpn scrcpy android-tools ]);
  };
}