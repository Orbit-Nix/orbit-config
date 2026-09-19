{ pkgs, inputs, osConfig, lib, ... }:

{
  # --- WALLPAPERS ---
  home.file."Pictures/Wallpapers" = {
    source = ../../modules/desktop/assets/Wallpapers;
    recursive = true;
  };

  # --- ICONS ---
  home.packages = with pkgs; [
    whitesur-icon-theme
  ];

  gtk = {
    enable = true;
    iconTheme = {
      name = "WhiteSur";
      package = pkgs.whitesur-icon-theme;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style.name = "";
  };

  # --- MODULAR SHELLS & DESKTOP CONFIGS ---
  imports = [
    ../../modules/desktop/shells
    ../../modules/desktop/app-configs.nix
  ];

  # Default shell (switchable with "orbit shell {shell name}
  orbitos.desktop.shell = lib.mkDefault (osConfig.mySystem.desktop.shell or "end4-pC");

  # --- ORBITOS MODULAR CONFIGURATION MANAGER ---
  orbitos = {
    enable = true;
    profile = "orbitos";
  };

  # --- ANTIGRAVITY IDE CONVERSATION HISTORY PERSISTENCE ---
  systemd.user.services.antigravity-chat-sync = {
    Unit = {
      Description = "Sync Antigravity IDE conversation histories to state.vscdb";
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "antigravity-sync-start" ''
        /run/current-system/sw/bin/sync-chats || sync-chats || true
      ''}";
      ExecStop = "${pkgs.writeShellScript "antigravity-sync-stop" ''
        /run/current-system/sw/bin/sync-chats || sync-chats || true
      ''}";
    };
  };

  systemd.user.timers.antigravity-chat-sync = {
    Unit = {
      Description = "Periodic sync of Antigravity IDE conversation histories";
    };
    Install = {
      WantedBy = [ "timers.target" "graphical-session.target" ];
    };
    Timer = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
  };

  home.stateVersion = "24.05";
}
