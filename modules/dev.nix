{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    gcc
    lua-language-server
    nil
    nixpkgs-fmt
    typescript-language-server
    yaml-language-server
    biome
    clang-tools
    nodejs_20
    opencode
    # claude-code is deliberately NOT installed from nixpkgs: the /nix/store
    # copy is read-only, so `claude update` can't write and it drifts behind.
    # Use the native installer instead -- it self-updates into
    # ~/.local/share/claude, already on PATH via home.sessionPath.
    #
    # NOTE: this module is imported by BOTH hosts. Before the first rebuild on a
    # host that has not migrated yet, run `claude install` there while the old
    # nixpkgs build is still present. SHELL migrated 2026-09-02; NIXCORE has not.
    cmake
    gnumake
    pkg-config
    curl.dev
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
    openssl
    openssl.dev

    # --- added 2026-09-01 -------------------------------------------------
    # Toolchains installed on the Windows laptop that had no equivalent here.
    gh
    fzf
    hugo
    pandoc
    ffmpeg
    awscli2
    postman
    vscode

    # nodejs_20 stays pinned above. fnm covers the multi-version workflow that
    # NVM for Windows was doing; nodejs_22 is packaged if you want to bump.
    fnm
    pnpm
    yarn

    go
    gopls
    delve

    python313

    dotnet-sdk_9
    lua5_1
    luarocks
  ];
}
