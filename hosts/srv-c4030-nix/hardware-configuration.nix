{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/af2c99cf-f1b0-4d87-a7a1-95ac9fe577e6";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/af2c99cf-f1b0-4d87-a7a1-95ac9fe577e6";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/af2c99cf-f1b0-4d87-a7a1-95ac9fe577e6";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" "nofail" ];
    };

  fileSystems."/srv" =
    { device = "/dev/disk/by-uuid/af2c99cf-f1b0-4d87-a7a1-95ac9fe577e6";
      fsType = "btrfs";
      options = [ "subvol=@srv" "compress=zstd" "noatime" "nofail" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/af2c99cf-f1b0-4d87-a7a1-95ac9fe577e6";
      fsType = "btrfs";
      options = [ "subvol=@var_log" "compress=zstd" "noatime" "nofail" ];
      neededForBoot = true;
    };

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-uuid/af2c99cf-f1b0-4d87-a7a1-95ac9fe577e6";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" "compress=zstd" "noatime" "nofail" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D1E9-833F";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" "nofail" ];
    };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

#  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}