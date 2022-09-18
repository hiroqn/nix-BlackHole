{
  description = "BlackHole nix file";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    darwinModules = rec {
      default = import ./module.nix;
    };
    packages.x86_64-darwin.BlackHole = nixpkgs.legacyPackages.x86_64-darwin.callPackage ./BlackHole.nix { };
    defaultPackage.x86_64-darwin = self.packages.x86_64-darwin.BlackHole;
  };
}
