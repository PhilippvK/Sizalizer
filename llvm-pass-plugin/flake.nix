{
  description = "vt-interp development environment";
  nixConfig.bash-prompt = "[nix(vt-interp):\\w]$ ";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/23.05"; };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
    in {
      devShells.x86_64-linux.default = import ./shell.nix { inherit pkgs; };
    };
}