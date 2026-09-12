{ config, pkgs, lib, ... }:

{
  # Enable zRAM dynamically scaled to physical memory
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # Dynamic swapfile fallback
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 12288; # 12 GB
    priority = 10; # Lower priority than zRAM
  } ];

  boot.kernel.sysctl = {
    # Aggressive swap
    "vm.swappiness" = 180;

    # Optimize kswapd behavior for RAM-based swap
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0; # Disable sequential disk cluster read ahead for zRAM
  };

  # Prevent out-of-memory lockups
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = false;
    extraArgs = [
      "--avoid" "'^(init|systemd|Hyprland|wezterm|kitty|sshd)$'"
      "--prefer" "'^(chrome|firefox|electron|java)$'"
    ];
  };
}