{ lib, ... }:

{
  orbitos.apps.starship = {
    enable = lib.mkDefault true;
    mode = lib.mkDefault "overwrite";
  };
}
