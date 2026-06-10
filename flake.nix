{
  description = "xvc-pico: Raspberry Pi Pico / Pico 2 based Xilinx Virtual Cable (XVC) JTAG probe";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in rec {
          xvcd-pico = pkgs.callPackage ./nix/package.nix { };
          default = xvcd-pico;
        });

      # Usage in a flake-based NixOS configuration:
      #
      #   inputs.xvc-pico.url = "github:jannes922/xvc-pico/ng";
      #
      #   # in your nixosSystem modules:
      #   imports = [ inputs.xvc-pico.nixosModules.default ];
      #   services.xvcd-pico.enable = true;
      #
      # The daemon is started by udev when the probe (2e8a:000a) is plugged in
      # and stopped when it is removed. Vivado then connects via
      # Hardware Manager -> Add Xilinx Virtual Cable -> localhost:2542.
      nixosModules = rec {
        xvcd-pico = import ./nix/module.nix;
        default = xvcd-pico;
      };
    };
}
