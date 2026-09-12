{ config, lib, pkgs, ... }:

{
  # --- AMD & INTEL CPU MICROCODE ---
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # --- AMD & INTEL VIRTUALIZATION ---
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
}