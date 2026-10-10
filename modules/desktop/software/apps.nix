{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.mySystem.apps;
  system = pkgs.stdenv.hostPlatform.system;

  ideaWrapper = pkgs.writeShellScriptBin "idea" ''
    exec flatpak run com.jetbrains.IntelliJ-IDEA-Community "$@"
  '';
  flatsealWrapper = pkgs.writeShellScriptBin "flatseal" ''
    exec flatpak run com.github.tchx84.Flatseal "$@"
  '';

  #==================================#
  #        APPS DICTIONARIES         #
  #==================================#
  
  # 1. GRAPHICS
  rasterMap = {
    "gimp"  = pkgs.gimp;
    "krita" = pkgs.krita;
    "photocraft" = pkgs.photocraft;
    "lightcraft" = pkgs.lightcraft;
  };
  vectorMap = {
    "inkscape" = pkgs.inkscape;
    "vectorcraft" = pkgs.vectorcraft;
    "designcraft" = pkgs.designcraft;
  };
  threeDMap = {
    "blender" = pkgs.blender;
  };
  cadMap = {
    "fusion360" = pkgs.fusion360;
    "cadcraft"  = pkgs.cadcraft;
  };

  # 2. MEDIA
  broadcastingMap = {
    "obs-studio" = pkgs.obs-studio;
  };
  streamingMap = {
    "stremio"      = pkgs.stremio-linux-shell;
    "spotify"      = pkgs.spotify;
    "pear-desktop" = pkgs.pear-desktop;
  };
  playersMap = {
    "vlc"         = pkgs.vlc;
    "mpv"         = pkgs.mpv;
    "feishin"     = pkgs.feishin;
    "vacuum-tube" = pkgs.vacuum-tube;
  };
  productionMap = {
    "kdenlive" = pkgs.kdePackages.kdenlive;
    "ardour"   = pkgs.ardour;
    "lmms"     = pkgs.lmms;
    "filmcraft"   = pkgs.filmcraft;
    "effectcraft" = pkgs.effectcraft;
    "soundcraft"= pkgs.soundcraft;
  };

  # 3. NETWORK
  browserMap = {
    "zen"       = [ inputs.zen-browser.packages.${system}.default ];
    "firefox"   = pkgs.firefox;
    "librewolf" = pkgs.librewolf;
    "waterfox"  = pkgs.waterfox;
    "floorp"    = pkgs.floorp;
    "brave"     = pkgs.brave;
    "chromium"  = pkgs.chromium;
    "ungoogled" = pkgs.ungoogled-chromium;
    "chrome"    = pkgs.google-chrome;
    "vivaldi"   = pkgs.vivaldi;
    "opera"     = pkgs.opera;
    "edge"      = pkgs.microsoft-edge;
    "tor"       = pkgs.tor-browser;
    "helium"    = pkgs.helium-browser;
  };
  messagingMap = {
    "beeper"         = pkgs.beeper;
    "vesktop"        = pkgs.vesktop;
    "discord"        = pkgs.discord;
    "signal"         = pkgs.signal-desktop;
    "telegram"       = pkgs.telegram-desktop;
  };
  sharingMap = {
    "localsend"   = pkgs.localsend;
    "rquickshare" = pkgs.rquickshare;
    "syncthing"   = pkgs.syncthing;
  };
  vpnMap = {
    "trayscale"  = pkgs.trayscale;
    "proton-vpn" = pkgs.proton-vpn;
    "mullvad"    = pkgs.mullvad-vpn;
  };
  remoteMap = {
    "scrcpy"        = pkgs.scrcpy;
    "android-tools" = pkgs.android-tools;
    "rustdesk"      = pkgs.rustdesk;
  };

  # 4. OFFICE
  suitesMap = {
    "libreoffice" = pkgs.libreoffice-qt6-fresh;
    "onlyoffice"  = pkgs.onlyoffice-bin;
    "wordcraft" = pkgs.wordcraft;
    "deckcraft" = pkgs.deckcraft;
    "gridcraft" = pkgs.gridcraft;
  };
  notesMap = {
    "obsidian" = pkgs.obsidian;
    "logseq"   = pkgs.logseq;
    "joplin"   = pkgs.joplin-desktop;
  };
  officeUtilitiesMap = {
    "evince"   = pkgs.evince;
    "zathura"  = pkgs.zathura;
    "pdfcraft" = pkgs.pdfcraft;
  };

  # 5. DEVELOPMENT
  ideMap = {
    "idea"           = ideaWrapper;            # Temporary
    "pycharm"        = pkgs.jetbrains.pycharm;
    "clion"          = pkgs.jetbrains.clion;
    "webstorm"       = pkgs.jetbrains.webstorm;
    "rider"          = pkgs.jetbrains.rider;
    "goland"         = pkgs.jetbrains.goland;
    "phpstorm"       = pkgs.jetbrains.phpstorm;
    "datagrip"       = pkgs.jetbrains.datagrip;
    "rust-rover"     = pkgs.jetbrains.rust-rover;
    "android-studio" = pkgs.android-studio;
    "vscode"         = pkgs.vscode;
    "vscodium"       = pkgs.vscodium;
    "zed"            = pkgs.zed-editor;
  };
  terminalsMap = {
    "kitty"         = pkgs.kitty;
    "wezterm"       = pkgs.wezterm;
    "alacritty"     = pkgs.alacritty;
    "warp"          = pkgs.warp-terminal;
  };
  aiMap = {
    "cursor"             = pkgs.code-cursor;
    "antigravity"        = [ pkgs.antigravity-cli pkgs.antigravity-ide ];
    "codex"              = pkgs.codex;
    "claude-code"        = pkgs.claude-code;
    "opencode"           = [ pkgs.opencode pkgs.opencode-desktop pkgs.opencode-claude-auth ];
    "opendesign"         = [ ];
    "ollama"             = pkgs.ollama;
    "chatgpt"            = [ pkgs.chatgpt-desktop pkgs.chatgpt-cli ];
    "windsurf"           = pkgs.windsurf;
    "github-copilot"     = pkgs.github-copilot-cli;
  };

  # 6. SYSTEM
  fileManagerMap = {
    "nautilus"           = pkgs.nautilus;
    "nemo"               = pkgs.cinnamon.nemo;
    "dolphin"            = pkgs.kdePackages.dolphin;
    "thunar"             = pkgs.xfce.thunar;
    "pcmanfm"            = pkgs.pcmanfm;
    "yazi"               = pkgs.yazi;
  };
  systemUtilitiesMap = {
    "flatseal"       = flatsealWrapper;
    "mission-center" = pkgs.mission-center;
  };

  resolveApps = mapObj: selectedKeys:
    lib.concatMap (key:
      let val = mapObj.${key}; in
      if builtins.isList val then val else [ val ]
    ) selectedKeys;

  # Check flatpak specific overrides
  hasIdea = builtins.elem "idea" cfg.development.ide;
  hasFlatseal = builtins.elem "flatseal" cfg.system.utilities;
in
{
  imports = [
    inputs.opendesign.nixosModules.default
  ];

  options.mySystem.apps = {
    enable = lib.mkEnableOption "Desktop core system apps and utilities";

    graphics = {
      raster = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames rasterMap)); default = []; description = "Raster graphics (gimp, krita, etc)"; };
      vector = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames vectorMap)); default = []; description = "Vector graphics (inkscape)"; };
      threeD = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames threeDMap)); default = []; description = "3D modelling and sculpting"; };
      cad    = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames cadMap));    default = []; description = "CAD and engineering"; };
    };

    media = {
      broadcasting = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames broadcastingMap)); default = []; description = "Live streaming/recording"; };
      streaming    = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames streamingMap));    default = []; description = "Client streaming apps"; };
      players      = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames playersMap));      default = []; description = "Local audio/video playback"; };
      production   = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames productionMap));   default = []; description = "Non-linear editors and DAWs"; };
    };

    network = {
      browsers  = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames browserMap));   default = [ "zen" ]; description = "Web browsers"; };
      messaging = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames messagingMap)); default = []; description = "Chat clients"; };
      sharing   = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames sharingMap));   default = []; description = "Local file transfer P2P"; };
      vpn       = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames vpnMap));       default = []; description = "Network tunnels"; };
      remote    = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames remoteMap));    default = []; description = "Remote desktop/screencasting"; };
    };

    office = {
      suites    = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames suitesMap));          default = []; description = "Office suites"; };
      notes     = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames notesMap));           default = []; description = "Markdown/PKM tools"; };
      utilities = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames officeUtilitiesMap)); default = []; description = "Office utilities"; };
    };

    development = {
      ide       = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames ideMap));       default = [ "idea" ]; description = "IDEs and coders"; };
      terminals = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames terminalsMap)); default = [ "kitty" ]; description = "Terminal emulators"; };
      ai        = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames aiMap));        default = []; description = "AI dev tools"; };
    };

    system = {
      fileManagers = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames fileManagerMap));     default = [ "nautilus" ]; description = "File explorers"; };
      utilities    = lib.mkOption { type = lib.types.listOf (lib.types.enum (builtins.attrNames systemUtilitiesMap)); default = [ "flatseal" ]; description = "System tools & utilities"; };
    };
  };

  config = lib.mkIf cfg.enable {
    services.open-design.enable = builtins.elem "opendesign" cfg.development.ai;
    programs.kdeconnect.enable = true;

    services.flatpak.packages = lib.unique (
      lib.optional hasFlatseal "com.github.tchx84.Flatseal"
      ++ lib.optional hasIdea "com.jetbrains.IntelliJ-IDEA-Community"
    );

    environment.systemPackages =
      (with pkgs; [
        polkit_gnome playerctl libnotify steam-run
        wl-clipboard grim slurp rofi waybar awww cliphist quickshell
        matugen dart-sass gtk4 adwaita-icon-theme gtk4-layer-shell glib cairo
        python3Packages.pygobject3 python3Packages.pycairo

        # Thumbnailing, Image & Icon Support for Quickshell
        imagemagick file kdePackages.qtsvg kdePackages.qtimageformats
        librsvg gnome-desktop python3Packages.loguru python3Packages.tqdm
        python3Packages.click python3Packages.pillow
      ])
      ++ (resolveApps rasterMap cfg.graphics.raster)
      ++ (resolveApps vectorMap cfg.graphics.vector)
      ++ (resolveApps threeDMap cfg.graphics.threeD)
      ++ (resolveApps cadMap cfg.graphics.cad)

      ++ (resolveApps broadcastingMap cfg.media.broadcasting)
      ++ (resolveApps streamingMap cfg.media.streaming)
      ++ (resolveApps playersMap cfg.media.players)
      ++ (resolveApps productionMap cfg.media.production)

      ++ (resolveApps browserMap cfg.network.browsers)
      ++ (resolveApps messagingMap cfg.network.messaging)
      ++ (resolveApps sharingMap cfg.network.sharing)
      ++ (resolveApps vpnMap cfg.network.vpn)
      ++ (resolveApps remoteMap cfg.network.remote)

      ++ (resolveApps suitesMap cfg.office.suites)
      ++ (resolveApps notesMap cfg.office.notes)
      ++ (resolveApps officeUtilitiesMap cfg.office.utilities)

      ++ (resolveApps ideMap cfg.development.ide)
      ++ (resolveApps terminalsMap cfg.development.terminals)
      ++ (resolveApps aiMap cfg.development.ai)

      ++ (resolveApps fileManagerMap cfg.system.fileManagers)
      ++ (resolveApps systemUtilitiesMap cfg.system.utilities);
  };
}
