{ config, lib, ... }:

{
  orbitos.apps.fastfetch = {
    enable = lib.mkDefault true;
    mode = lib.mkDefault "overwrite";
  };
}
