{ pkgs, lib, ... }:

{
  imports = [
    ./filesystem.nix
    ./users.nix
    #./restic.nix
    ./stacks/default.nix
  ];
}
