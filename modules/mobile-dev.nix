# Android / React Native / Expo toolchain.
# Evidence this belongs on SHELL: Android Studio and Maestro Studio are both
# taskbar-pinned on the Windows install, alongside ~/.android, ~/.gradle,
# ~/.expo, ~/.maestro, ~/.mobiledev and a Temurin JDK 17.
{ pkgs, ... }:
{
  programs.adb.enable = true; # installs udev rules and creates the adbusers group

  # Scoped here rather than in the shared users.nix, so hosts that do not import
  # this module never reference a group that does not exist.
  users.users.plague.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    android-studio
    android-tools # adb, fastboot
    maestro
    scrcpy
    jdk17
    gradle
    kotlin
    eas-cli
    # expo-cli is no longer in nixpkgs (deprecated upstream) - use `npx expo`.
  ];
}
