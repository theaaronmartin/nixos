# ComfyUI image generation on the RTX 3080. Added 2026-10-08 with the SDXL 1.0
# base checkpoint; the Juggernaut XI and RealVisXL V5 fine-tunes were added
# 2026-10-09.
#
# services.comfyui exists only in nixpkgs-unstable, not in nixos-26.05, so the
# module is imported straight from that input. Drop the import once the stable
# channel ships it.
#
# The CUDA build of PyTorch is not on cache.nixos.org (CUDA is unfree), and
# compiling it here would take hours with CPU boost disabled. The NixOS CUDA
# team's cache serves torch and triton for this exact package. On 2026-10-08 it
# lacked only torchvision, torchaudio, torchcodec, einops and spandrel, which
# built locally.
{ inputs, pkgs-unstable, ... }:

{
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/comfyui.nix" ];

  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  services.comfyui = {
    enable = true;
    package = pkgs-unstable.comfyui;

    # Reachable from SHELL and the rest of the LAN at http://192.168.0.198:8188.
    # ComfyUI has no authentication of its own.
    listen = [
      "0.0.0.0"
      "::"
    ];
    port = 8188;

    extraArgs = [
      # Live previews of the image while it is being sampled.
      "--preview-method=auto"
      # The card is shared with Ollama (Hermes keeps a model loaded for 30m).
      # By default ComfyUI keeps the last model in VRAM between runs, which
      # would leave Ollama to spill onto the CPU. With this it moves models
      # back to system RAM after each run and reloads them over PCIe next time.
      "--disable-smart-memory"
    ];

    models = [
      {
        # Stability AI's SDXL 1.0 base (openrail++ licence, not gated). 6.9 GB
        # in the Nix store, pinned to a commit so the hash stays stable.
        name = "sd_xl_base_1.0.safetensors";
        url = "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/462165984030d82259a11f4367a4eed129e94a7b/sd_xl_base_1.0.safetensors";
        hash = "sha256-MeNcgPxIKdFPkBU/THTNWckLd59q/gWnTNYSC4k/fls=";
        installPaths = "checkpoints";
      }
      {
        # Juggernaut XI by RunDiffusion, an SDXL fine-tune for photographs and
        # cinematic scenes. 7.1 GB. CC BY-NC-ND 4.0: personal, non-commercial use
        # only, and the weights must not be re-hosted. Card settings: 832x1216 or
        # 1216x832, DPM++ 2M Karras, 30-40 steps, CFG 3-7.
        name = "Juggernaut-XI-byRunDiffusion.safetensors";
        url = "https://huggingface.co/RunDiffusion/Juggernaut-XI-v11/resolve/f836518c7a75f47a9e26bc661ff9509ef2ceb7c0/Juggernaut-XI-byRunDiffusion.safetensors";
        hash = "sha256-M+WOhmhvazhsUmaCtdqSKOrU+R2ZSr1LBTRC3FtCcZ4=";
        installPaths = "checkpoints";
      }
      {
        # RealVisXL V5.0 (fp16), an SDXL fine-tune aimed at photorealism.
        # 6.9 GB, openrail++. Card settings: DPM++ SDE Karras with 30+ steps, or
        # DPM++ 2M Karras with 50+ steps.
        name = "RealVisXL_V5.0_fp16.safetensors";
        url = "https://huggingface.co/SG161222/RealVisXL_V5.0/resolve/ac93e0dda1f6d448cae19bbfab8c5e720a5e48bc/RealVisXL_V5.0_fp16.safetensors";
        hash = "sha256-ajWnhVdwrpggo8kx1JZMOBe22ePG+cTau1s6lOVkO4A=";
        installPaths = "checkpoints";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8188 ];
}
