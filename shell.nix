let
  sources = import ./nix/sources.nix;
  pathfinder_c = import ./nix/pathfinder.nix { inherit sources; };
  wasmer_c = import ./nix/wasmer-c-api.nix { inherit sources; };
  pkgs = import sources.nixpkgs {};
in
pkgs.mkShell {
  buildInputs = [
    pkgs.zig
    pkgs.pkg-config
    pkgs.SDL2
    pkgs.enet
    pathfinder_c
    wasmer_c
    pkgs.gdb
  ];
}
