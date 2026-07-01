{
  description = "kjp NixOS host + self-installing ISO (VMware guest)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-dokploy.url = "github:el-kurto/nix-dokploy";
    nix-dokploy.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, nix-dokploy }:
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
            nix-dokploy.nixosModules.default
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
