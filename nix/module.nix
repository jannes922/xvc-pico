{ config, lib, pkgs, ... }:

let
  cfg = config.services.xvcd-pico;

  # udev rules must sort before 73-seat-late.rules for the uaccess tag to
  # take effect, hence a packaged rules file instead of services.udev.extraRules
  # (which lands in 99-local.rules).
  udevRules = pkgs.writeTextFile {
    name = "xvc-pico-udev-rules";
    destination = "/lib/udev/rules.d/70-xvc-pico.rules";
    text = ''
      # xvc-pico JTAG probe: give the seated user direct access (picotool etc.)
      # and start the XVC daemon while the probe is plugged in.
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="000a", TAG+="uaccess", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/xvcpico", ENV{SYSTEMD_WANTS}="xvcd-pico.service"
    '';
  };
in
{
  options.services.xvcd-pico = {
    enable = lib.mkEnableOption "the XVC daemon for the xvc-pico JTAG probe";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The xvcd-pico package to run.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open TCP port 2542 so Vivado on another machine can reach the probe.
        Not needed when Vivado runs on this host (localhost is always allowed).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ udevRules ];

    systemd.services.xvcd-pico = {
      description = "Xilinx Virtual Cable daemon for the xvc-pico JTAG probe";
      # Bound to the probe's device unit (aliased by the udev rule above):
      # started on plug, stopped on unplug. The daemon also exits by itself
      # when the probe disappears; Restart covers transient USB errors.
      bindsTo = [ "dev-xvcpico.device" ];
      after = [ "dev-xvcpico.device" ];
      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 2542 ];
  };
}
