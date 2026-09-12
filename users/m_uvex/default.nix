{ pkgs, ... }:

{
  users.users.m_uvex = {
    isNormalUser = true;
    description = "m_uvex";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "storage" ];
    hashedPassword = "$6$tFhMrTUbXvCtUK2O$VyQs7xSfEOGBPZlb8UZPOZEA6tr2ZR5ixEvbO1wwhN6iGb3kmgvTCVDbGmAx1u33FSomD4wWIQFw.ly3yGj141";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKT+rzs85ZnNdaPFsc9FjNFASNYATaXY5qkWQEOJhHfc m_uvex"
    ];
  };
}
