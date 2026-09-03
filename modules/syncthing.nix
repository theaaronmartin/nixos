# Syncthing, configured declaratively and shared by every host.
#
# `peers` is derived by dropping the local hostname from `devices`, so this one
# file works unmodified on NIXCORE and SHELL - each host ends up sharing with
# the other two and never with itself. GHOST is the phone; it is not managed by
# Nix and only appears here as a peer to share folders with.
#
# overrideDevices/overrideFolders default to true, which makes this file the
# single source of truth: anything added through the web GUI at
# http://127.0.0.1:8384 is reverted on the next rebuild. Add it here instead.
#
# History: SHELL was reinstalled bare metal 2026-09-01 and generated a fresh
# device ID, so the old SHELL entry (4ANYYNV-...) is deliberately absent - the
# override above deletes it from NIXCORE on rebuild.
{ config, lib, ... }:
let
  devices = {
    NIXCORE = "QDKVXN6-YV4QMVK-5262IVF-7FPR3XC-GMA35GR-LUZ44KV-V6BHFKT-XCKPJAN";
    SHELL = "RHWMA34-PEXE2DT-HDQE5X3-DS6DZIB-DTNJLMZ-T7AGCR2-AO446Y5-B5E3LQ3";
    GHOST = "RDTPWPL-MMPPBH7-ZMGVR4J-XBL7CLX-NFPXWOI-6BDZ6HQ-HGWDIWX-Z4W3ZA3";
  };

  peers = lib.filterAttrs (name: _: name != config.networking.hostName) devices;
  peerNames = lib.attrNames peers;
in
{
  services.syncthing = {
    enable = true;
    user = "plague";

    # configDir defaults to "${dataDir}/.config/syncthing", so the live config
    # actually sits at ~/.config/syncthing/.config/syncthing. Ugly, but that is
    # where both hosts' device keys already are; pointing configDir somewhere
    # tidier would hand each host a brand new device ID and unpair everything.
    dataDir = "/home/plague/.config/syncthing/";

    # 22000/tcp+udp for sync, 21027/udp for LAN discovery. Without these the
    # hosts fall back to relays, which works but is far slower.
    openDefaultPorts = true;

    settings = {
      devices = lib.mapAttrs (_: id: { inherit id; }) peers;

      # Folder IDs must match what NIXCORE and GHOST already use, otherwise
      # each host creates a second, unrelated folder.
      folders = {
        keepass = {
          id = "nunzg-hstld";
          label = "keepass";
          path = "/home/plague/keepass";
          devices = peerNames;
        };

        notes = {
          id = "s4ylj-rxtlq";
          label = "notes";
          path = "/home/plague/notes";
          devices = peerNames;

          # Written to the folder's .stignore. .obsidian is per-machine window
          # layout and only ever produces conflicts; Obsidian recreates it on
          # first open. Kept byte-identical to the .stignore NIXCORE already
          # had so this is a no-op there.
          ignorePatterns = [
            "(?d).git"
            "(?d).obsidian"
            "(?d).sync-conflict-*"
            "*.db-shm"
            "*.db-wal"
            ".DS_Store"
            ".trash"
          ];
        };
      };
    };
  };
}
