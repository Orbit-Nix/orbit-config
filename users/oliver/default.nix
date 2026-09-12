{ pkgs, lib, ... }:

{
  # --- DEV USER: OLIVER ---
  users.users.oliver = {
    isNormalUser = true;
    description = "Oliver (Dev)";
    group = "pocketbase";
    extraGroups = [ "pocketbase" ];
    createHome = true;
    home = "/home/oliver";
    openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqs/vQve3v+GqID2nGB1Y+ZWth7+j0fNBS+LaDFCpnS olive@MACBOOK-PRO-2019--WINDOWS"
    ];
  };
}
