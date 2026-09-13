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

  # --- HOME MANAGER PERSISTENCE (DECLARATIVE PATH PRESERVATION) ---
  home.persistence."/persist" = {
    directories = [
      ".gemini"
      ".config/Antigravity IDE/User/globalStorage"
    ];
    files = [
      ".config/hypr/monitors.conf"
      ".config/hypr/monitors.lua"
      ".config/hypr/workspaces.conf"
      ".config/hypr/workspaces.lua"
    ];
  };

  home.stateVersion = "24.05";
}
