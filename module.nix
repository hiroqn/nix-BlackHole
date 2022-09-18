{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.BlackHole;
  drivers = map (n: pkgs.callPackage ./BlackHole.nix { }) cfg.channels;
in
{
  options = {
    BlackHole = {
      enable = mkEnableOption "BlackHole";
      # TODO: currently not supported
      channels = mkOption {
        default = [ 2 ];
        type = types.uniq (types.listOf types.int);
        description = ''
          num of channels
        '';
      };
      stateFileName = mkOption {
        type = types.str;
        default = "nix-BlackHole";
        description = "state file to manage Audio Plug-Ins. use carefully";
      };
    };
  };
  config = mkIf cfg.enable {
    system.activationScripts.extraActivation.text = ''
      mkdir -p /Library/Audio/Plug-Ins/HAL

      # cleanup phase
      find -L /Library/Audio/Plug-Ins/HAL -type d -name "*.driver" -print0 | while IFS= read -rd "" driver; do
        stateFile="$driver/Contents/Resources/${cfg.stateFileName}"
        if [ -r "$state" ]; then
          # if driver manged by this module
          drv="$(cat "$state")"
          if [ ${concatStringsSep " && " (map (driver: '' "$drv" != "${driver}"'') drivers) } ];then
            rm -rf "$driver"
          fi
        fi
      done
      ${concatStringsSep "\n" (map (driver: ''
        cp -r ${driver}/Library/Audio/Plug-Ins/HAL/*.driver /Library/Audio/Plug-Ins/HAL/
      '') drivers)}
    '';
    system.activationScripts.postActivation.text = ''
      launchctl kickstart -kp system/com.apple.audio.coreaudiod
    '';
  };
}
