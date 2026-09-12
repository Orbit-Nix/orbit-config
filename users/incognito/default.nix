{ config, pkgs, ... }:

{
  users.users.incognito = {
    isNormalUser = true;
    description = "Incognito Session";
    extraGroups = [ "networkmanager" "video" "audio" ];
    hashedPassword = ""; # Passwordless login!
  };

  # Mount ~ strictly in RAM (gets wiped completely on logout/reboot)
  fileSystems."/home/incognito" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "mode=0700"
      "uid=1002"
      "size=4G"
    ];
  };

  # Force unmount on logout so RAM is wiped instantly without rebooting
  security.pam.services.incognito = {
    text = ''
      session optional pam_exec.so type=close_session log=/tmp/incognito_cleanup.log ${pkgs.util-linux}/bin/umount -l /home/incognito
    '';
  };
}