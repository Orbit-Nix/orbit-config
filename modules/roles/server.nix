{ pkgs, lib, ... }:

{
  # --- HEADLESS & 24/7 UP ---
  # Turn off screen after 1 minute of inactivity
  boot.kernelParams = [
    "consoleblank=60"
  ];

  # Prevent system from going to sleep / suspending / hibernating
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.logind.settings = {
    Login = {
      HandleSuspendKey = "ignore";
      HandleHibernateKey = "ignore";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "poweroff";
    };
  };

  # --- SERVER KERNEL & NETWORK SYSCTL TUNING ---
  boot.kernel.sysctl = {
    # Container inotify & file limits
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
    "fs.file-max" = 2097152;

    # Networking socket buffer & queue sizes
    "net.core.somaxconn" = 4096;
    "net.core.netdev_max_backlog" = 4096;

    # IP Forwarding for Tailscale Subnet Router & Docker bridge networking
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # --- TAILSCALE CONFIG ---
  services.tailscale.extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.5.0/24"
      "--accept-routes=true"
    ];
  };

  # --- LOCAL DNS RESOLVER FOR TAILSCALE SPLIT-DNS (*.lunar.srv) ---
  services.dnsmasq = {
    enable = true;
    settings = {
      bind-dynamic = true;
      address = [
        "/lunar.srv/192.168.5.23"
      ];
    };
  };

  # --- STORAGE & DISK HEALTH ---
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # --- SERVER CLI UTILITIES ---
  environment.systemPackages = with pkgs; [
    tmux
    screen
    ncdu
    duf
    iotop
    iftop
    iperf3
    nethogs
    hdparm
  ];
}
