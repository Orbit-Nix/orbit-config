{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Uses NixOS's baseline hardware detection
    (modulesPath + "/installer/scan/not-detected.nix")

    # Universal CPU and GPU modules
    ../../modules/hardware/universal-cpu.nix
    ../../modules/hardware/universal-gpu.nix
  ];

  boot = {
    # Early boot modules for USB 2/3/C, NVMe, SATA, and HID input
    initrd.availableKernelModules = [
      "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod"
      "nvme" "uas" "hid_generic" "usbhid" "atkbd"
    ];

    # Additional kernel modules available after stage 1
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # Wi-Fi, Bluetooth, GPU blobs
  hardware.enableAllFirmware = true;

  # Mount filesystems by filesystem label
  fileSystems."/" = {
    device = "/dev/disk/by-label/PORTABLE_NIXOS";
    fsType = "ext4"; # Replace with "btrfs" if using Btrfs
    options = [ "noatime" "nodiratime" ]; # Reduces USB write wear
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/PORTABLE_BOOT";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Platform host architecture
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}