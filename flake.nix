{
  description = "Shipnix application config for ihp-multi-project";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    ihp-app-one.url = "git+ssh://git@github.com/kodeFant/ihp-private-one.git?ref=main";
    ihp-app-two.url = "git+ssh://git@github.com/kodeFant/ihp-private-two.git?ref=main";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ihp-app-one, ihp-app-two } @attrs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        # use this variant if unfree packages are needed:
        # unstable = import nixpkgs-unstable {
        #  inherit system;
        #  config.allowUnfree = true;
        # };
      };
    in
    {
      nixosConfigurations."ihp-multi-project" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs // {
          environment = "production";
          ihp-app-one = ihp-app-one;
          ihp-app-two = ihp-app-two;
        };
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./nixos/configuration.nix
        ];
      };
    };
}
