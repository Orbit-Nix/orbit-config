{ pkgs, inputs, ... }:

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

  # --- ILLOGICAL-IMPULSE & END4-PC ---
  imports = [
    inputs.illogical-flake.homeManagerModules.default
    ../../modules/desktop/app-configs.nix
  ];
  programs.illogical-impulse.enable = true;

  # Build end4-pC with dynamic Material cursor integration and compatibility fixes
  xdg.configFile."quickshell/end4-pC".source = pkgs.runCommand "quickshell-end4-pC" { } ''
    cp -r "${inputs.end4-pC}" "$out"
    chmod -R u+w "$out"

    # Fix KeyError on primary_paletteKeyColor in generate_colors_material.py
    if [ -f "$out/scripts/colors/generate_colors_material.py" ]; then
      ${pkgs.gnused}/bin/sed -i "s/material_colors\['primary_paletteKeyColor'\]/material_colors.get('primary_paletteKeyColor', material_colors.get('primary', '#c7bfff'))/g" "$out/scripts/colors/generate_colors_material.py"
    fi

    # Fix thumbgen-venv.sh
    if [ -f "$out/scripts/thumbnails/thumbgen-venv.sh" ]; then
      ${pkgs.gnused}/bin/sed -i 's|source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate|[ -f "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate" ] \&\& source "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate" \|\| true|' "$out/scripts/thumbnails/thumbgen-venv.sh"
      ${pkgs.gnused}/bin/sed -i 's|deactivate|type deactivate \&>/dev/null \&\& deactivate \|\| true|' "$out/scripts/thumbnails/thumbgen-venv.sh"
    fi

    # Inject dynamic Material cursor switcher into applycolor.sh
    if [ -f "$out/scripts/colors/applycolor.sh" ]; then
      cat << 'EOF' >> "$out/scripts/colors/applycolor.sh"

# Dynamic Material Cursor integration
if [ -x "$HOME/.config/cursor/cursor-material-set-color.sh" ]; then
  "$HOME/.config/cursor/cursor-material-set-color.sh" &
fi
EOF
    fi
  '';

  home.sessionVariables = {
    qsConfig = "end4-pC";
  };

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
