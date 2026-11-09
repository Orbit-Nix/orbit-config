{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.orbitos.shells.noctalia;
  isCurrentShell = config.orbitos.desktop.shell == "noctalia";
in
{
  options.orbitos.shells.noctalia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Noctalia Shell.";
    };
  };

  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf (cfg.enable || isCurrentShell) {
    programs.noctalia = {
      enable = true;
      package = pkgs.runCommand "noctalia-5.4.0" {
        meta.mainProgram = "noctalia";
      } ''
        mkdir -p $out/bin $out/share
        ln -s /nix/store/1hkh77xwyhrxbak0vnpbhxx3hrnln46j-noctalia-5.4.0/bin/noctalia $out/bin/noctalia
        if [ -d /nix/store/1hkh77xwyhrxbak0vnpbhxx3hrnln46j-noctalia-5.4.0/share ]; then
          cp -r /nix/store/1hkh77xwyhrxbak0vnpbhxx3hrnln46j-noctalia-5.4.0/share/* $out/share/ || true
        fi
      '';
    };

    home.sessionVariables = lib.mkIf isCurrentShell {
      qsConfig = "noctalia";
    };
  };
}
