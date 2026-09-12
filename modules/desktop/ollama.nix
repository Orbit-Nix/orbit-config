{ config, pkgs, ... }:

{
  # 1. Ollama Service Setup (Modern nixpkgs syntax)
  services.ollama = {
    enable = true;

    # Updated package selection for CUDA 12 acceleration
    # (Matches MX150 / Pascal GPU support)
    package = pkgs.ollama-cuda;

    # Environment variables use environmentVariables (or env in newer unstable)
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "30m";
      OMP_NUM_THREADS = "4";
      OLLAMA_NUM_PARALLEL = "1";
    };
  };

  # 2. Open WebUI Setup
  services.open-webui = {
    enable = true;
    port = 8080;

    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "False";
      ENABLE_SIGNUP = "False";
      DO_NOT_TRACK = "True";
    };
  };

  # 3. Native Desktop & CLI Tools
  environment.systemPackages = with pkgs; [
    ollama
    alpaca # GTK4 desktop client for Ollama
  ];

  # 4. Open Local Ports (Optional)
  networking.firewall.allowedTCPPorts = [ 11434 8080 ];
}