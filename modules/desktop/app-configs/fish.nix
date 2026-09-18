{ config, lib, ... }:

{
  # Fish is managed globally via NixOS programs.fish in modules/core/default.nix
  orbitos.apps.fish = {
    enable = lib.mkDefault false;
    mode = lib.mkDefault "layer";
    layerTarget = lib.mkDefault "conf.d";
  };

  # Automatically disable upstream illogical-impulse fish dotfiles
  programs.illogical-impulse.dotfiles.fish.enable = lib.mkDefault false;
}
