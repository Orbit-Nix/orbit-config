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
    };

    home.sessionVariables = lib.mkIf isCurrentShell {
      qsConfig = "noctalia";
    };
  };
}
