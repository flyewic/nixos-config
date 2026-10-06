{ inputs, ... }:
{
  # Hybrid laptop: import the NVIDIA driver, then PRIME offload.
  # The integrated GPU drives the session. `nvidia-offload` runs one program
  # on the NVIDIA GPU. Offload stays disabled until the host sets nvidiaBusId
  # and exactly one of intelBusId or amdgpuBusId. NixOS rejects PRIME without them.
  flake.modules.nixos."nvidia-prime" =
    { config, lib, ... }:
    let
      prime = config.hardware.nvidia.prime;
      ready = prime.nvidiaBusId != "" && (prime.intelBusId != "" || prime.amdgpuBusId != "");
    in
    {
      imports = [ inputs.self.modules.nixos.nvidia ];

      hardware.nvidia.prime.offload = {
        enable = ready;
        enableOffloadCmd = ready;
      };
    };
}
