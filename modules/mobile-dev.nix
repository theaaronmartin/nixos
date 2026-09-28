# Android / React Native / Expo toolchain.
# Evidence this belongs on SHELL: Android Studio and Maestro Studio are both
# taskbar-pinned on the Windows install, alongside ~/.android, ~/.gradle,
# ~/.expo, ~/.maestro, ~/.mobiledev and a Temurin JDK 17.
{ pkgs, ... }:
{
  # programs.adb was removed in NixOS 26.05: systemd 258's 70-uaccess.rules tags
  # ADB/Fastboot USB interfaces (ff4201/ff4203/dc0201) for the seat user, so
  # neither a udev rules package nor the old adbusers group is needed. The
  # adbusers extraGroups entry went with it -- the group no longer exists and
  # activation would warn about it on every switch. android-tools below has adb.

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
