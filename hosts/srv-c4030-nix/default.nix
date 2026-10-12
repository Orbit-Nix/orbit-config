{ ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/hardware/swap.nix
    ../../modules/hardware/intel-cpu.nix
    ../../modules/hardware/intel-integrated.nix

    # Users
    ../../users/m_uvex
    ../../users/oliver

    # Modules
    ../../modules/core.nix
    ../../modules/roles/server.nix
    ../../modules/services
    ../../modules/services/docker.nix

  ];

  networking.hostName = "srv-c4030-nix";
  system.stateVersion = "24.05";
}
