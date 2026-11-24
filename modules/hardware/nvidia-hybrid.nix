{ config, lib, pkgs, ... }:

{
  # --- NVIDIA HYBRID / OPTIMUS LAPTOP (PRIME OFFLOAD) ---
  # Supports both Intel+NVIDIA and AMD+NVIDIA hybrid setups.
  # Bus IDs must be set per-host in hardware-configuration.nix or default.nix —
  # they are machine-specific and cannot be defaulted here.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = lib.mkDefault true;

    # Dynamic power management. Finegrained RTD3 requires Turing (RTX 20xx+) or newer.
    # Enable finegrained per-host for Turing+ laptops; leave false for Pascal/Maxwell.
    powerManagement.enable = lib.mkDefault true;
    powerManagement.finegrained = lib.mkDefault false;

    # Open-source kernel module: supported on Turing+ (RTX 20xx+). Set true per-host
    # for modern GPUs; keep false for Pascal (MX150) and older.
    open = lib.mkDefault false;
    nvidiaSettings = lib.mkDefault true;

    # Driver package: defaults to legacy_580 for Pascal/Maxwell (MX150, GTX 10xx) compatibility.
    # Override per-host with nvidiaPackages.stable for Turing+ (RTX 20xx and newer).
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.legacy_580;

    # PRIME Offload — bus IDs are set per-host, not here.
    # Intel+NVIDIA: set hardware.nvidia.prime.intelBusId + nvidiaBusId in host config.
    # AMD+NVIDIA:   set hardware.nvidia.prime.amdgpuBusId + nvidiaBusId in host config.
    prime = {
      offload = {
        enable = lib.mkForce true;
        enableOffloadCmd = lib.mkForce true; # provides `nvidia-offload <app>`
      };
      sync.enable = lib.mkForce false;
    };
  };

  # Hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      nvidia-vaapi-driver
    ];
  };

  # Wayland compatibility
  environment.sessionVariables = {
    NVD_BACKEND = lib.mkDefault "direct";
    ELECTRON_OZONE_PLATFORM_HINT = lib.mkDefault "auto";
  };
}
