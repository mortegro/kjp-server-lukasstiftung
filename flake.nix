{
  description = "kjp NixOS host + self-installing ISO (VMware guest)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {

        # ---- The real system installed on the machine ----
        kjp = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            disko.nixosModules.disko
            ./disko.nix
          ];
        };

        # ---- The installer ISO that carries this flake ----
        installer = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };   # pass the flake into installer.nix
          modules = [ ./installer.nix ];
        };
      };
    };
}
