{ config, pkgs, ... }:

{
  # 1. Ollama Service Setup (Modern nixpkgs syntax)
  services.ollama = {
    enable = true;

    # Vulkan backend for hardware acceleration across MX150 & Intel UHD
    package = pkgs.ollama-vulkan;

    # Pre-load recommended models: light everyday (qwen2.5:3b) & heavier coding (qwen2.5-coder:7b)
    loadModels = [
      "qwen2.5:3b"
      "qwen2.5-coder:7b"
    ];

    # Environment variables for execution performance
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "30m";
      OMP_NUM_THREADS = "4";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };

  # 2. Local speech-to-text (pluto-watch-chat transcribes incoming voice notes)
  environment.systemPackages = [ pkgs.whisper-cpp ];

  # 3. Open Local Port
  networking.firewall.allowedTCPPorts = [ 11434 ];
}