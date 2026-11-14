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
  riffPkg = inputs.riff.packages.${system}.default.overrideAttrs (old: {
    npmDeps = pkgs.fetchNpmDeps {
      src = inputs.riff;
      hash = "sha256-XvZfqfQI5zVvS3CtzQiHLnyEOWzSEJIqXssPH2eT7BE=";
      forceGitDeps = true;
    };
  });

  # Use existing built DaVinci Resolve 21.1.1 closure to avoid multi-hour flaky 4.2GB Blackmagic CDN downloads
  davinciResolvePkg = pkgs.runCommand "davinci-resolve-21.1.1" {
    meta.mainProgram = "davinci-resolve";
  } ''
    mkdir -p $out/bin $out/share/applications
    ln -s /nix/store/2y7q12jbvc576l6z6v1rdkci3p4nq9jb-davinci-resolve-21.1.1-bwrap $out/bin/davinci-resolve
    for f in /nix/store/9a6znwadrwskmsa81fbfwdpj2nrdb2pv-davinci-resolve-21.1.1/share/applications/*.desktop; do
      [ -e "$f" ] && ln -s "$f" $out/share/applications/
    done
  '';

  playersMap = {
    "vlc"         = pkgs.vlc;
    "mpv"         = pkgs.mpv;
    "feishin"     = pkgs.feishin;
    "vacuum-tube" = pkgs.vacuum-tube;
    "riff"        = riffPkg;
  };
  productionMap = {
    "davinci-resolve" = davinciResolvePkg;
    "kdenlive"    = pkgs.kdePackages.kdenlive;
    "ardour"      = pkgs.ardour;
    "lmms"        = pkgs.lmms;
    "filmcraft"   = pkgs.filmcraft;
    "effectcraft" = pkgs.effectcraft;
    "soundcraft"  = pkgs.soundcraft;
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

  beeperPkg = pkgs.runCommand "beeper-4.3.209" {
    meta.mainProgram = "beeper";
  } ''
    mkdir -p $out/bin $out/share/applications $out/share/icons
    ln -s /nix/store/vfxwp1xds9i9xwrw4ffb34fvc4cvz1bc-beeper-4.3.209/bin/beeper $out/bin/beeper
    ln -s /nix/store/vfxwp1xds9i9xwrw4ffb34fvc4cvz1bc-beeper-4.3.209/share/applications/beepertexts.desktop $out/share/applications/beepertexts.desktop
  '';

  messagingMap = {
    "beeper"         = beeperPkg;
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
    "nectarlink"    = inputs.nectarlink.packages.${system}.default;
  };

  # 4. OFFICE
  suitesMap = {
    "libreoffice" = pkgs.libreoffice-qt-stable;
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

  androidStudioPkg = pkgs.runCommand "android-studio-2026.2.1.8" {
    meta.mainProgram = "android-studio";
  } ''
    mkdir -p $out/bin $out/share/applications $out/share/pixmaps
    ln -s /nix/store/jlmpc2vhnq5fbmhjdh5l5zl535agp0kx-android-studio-2026.2.1.8/bin/android-studio $out/bin/android-studio
    ln -s /nix/store/jlmpc2vhnq5fbmhjdh5l5zl535agp0kx-android-studio-2026.2.1.8/share/applications/android-studio.desktop $out/share/applications/android-studio.desktop
  '';

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
    "android-studio" = androidStudioPkg;
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
  opencodePkg = pkgs.runCommand "opencode-2.0.26" {
    meta.mainProgram = "opencode";
  } ''
    mkdir -p $out/bin
    ln -s /nix/store/vdmfmk2milqb9j1k85gzflmy06760bcc-opencode-2.0.26+4617210/bin/opencode $out/bin/opencode
  '';

  opencodeDesktopPkg = pkgs.runCommand "opencode-desktop-2.0.26" {
    meta.mainProgram = "opencode-desktop";
  } ''
    mkdir -p $out/bin $out/share/applications
    ln -s /nix/store/mmy6894zyz4pd1j41kxigzxcljcqpbab-opencode-desktop-2.0.26+4617210/bin/opencode-desktop $out/bin/opencode-desktop
    ln -s /nix/store/mmy6894zyz4pd1j41kxigzxcljcqpbab-opencode-desktop-2.0.26+4617210/share/applications/ai.opencode.desktop.desktop $out/share/applications/ai.opencode.desktop.desktop
  '';

  aiMap = {
    "cursor"             = pkgs.code-cursor;
    "antigravity"        = [ pkgs.antigravity-cli pkgs.antigravity-ide ];
    "codex"              = pkgs.codex;
    "claude-code"        = pkgs.claude-code;
    "opencode"           = [ opencodePkg opencodeDesktopPkg ];
    "opendesign"         = [ inputs.open-design-desktop.packages.${system}.default ];
    "open-design-desktop" = [ inputs.open-design-desktop.packages.${system}.default ];
    "ollama"             = pkgs.ollama;
    "chatgpt"            = [ pkgs.chatgpt-desktop pkgs.chatgpt-cli ];
    "windsurf"           = pkgs.windsurf;
    "github-copilot"     = pkgs.github-copilot-cli;
    "freebuff"           = inputs.llm-agents.packages.${system}.freebuff;
  };

  loafPkg = pkgs.runCommand "loaf-0.3.0" {
    meta.mainProgram = "loaf";
  } ''
    mkdir -p $out/bin $out/share/applications $out/share/icons
    ln -s /nix/store/q6wz7p7pkjlpc7z0way1c99n1jplrqhq-loaf-0.3.0/bin/loaf $out/bin/loaf
    ln -s /nix/store/q6wz7p7pkjlpc7z0way1c99n1jplrqhq-loaf-0.3.0/share/applications/loaf.desktop $out/share/applications/loaf.desktop
    if [ -d /nix/store/q6wz7p7pkjlpc7z0way1c99n1jplrqhq-loaf-0.3.0/share/icons ]; then
      cp -r /nix/store/q6wz7p7pkjlpc7z0way1c99n1jplrqhq-loaf-0.3.0/share/icons/* $out/share/icons/ || true
    fi
  '';

  # 6. SYSTEM
  fileManagerMap = {
    "nautilus"           = pkgs.nautilus;
    "nemo"               = pkgs.cinnamon.nemo;
    "dolphin"            = pkgs.kdePackages.dolphin;
    "thunar"             = pkgs.xfce.thunar;
    "pcmanfm"            = pkgs.pcmanfm;
    "yazi"               = pkgs.yazi;
    "loaf"               = loafPkg;
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
    services.open-design.enable = builtins.elem "opendesign" cfg.development.ai || builtins.elem "open-design-desktop" cfg.development.ai;
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
