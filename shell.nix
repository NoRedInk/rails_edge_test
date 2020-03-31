{ ... }:
let
  sources = import ./nix/sources.nix { };
  nixpkgs = import sources.nixpkgs { };
  gems = nixpkgs.bundlerEnv {
    name = "rails_edge_test";
    gemfile = nix/Gemfile;
    lockfile = nix/Gemfile.lock;
    ruby = nixpkgs.ruby_2_5;
    gemdir = ./nix;
  };
in with nixpkgs;
stdenv.mkDerivation {
  name = "rails_edge_test";
  buildInputs = [
    # deps
    pkgs.zlib
    pkgs.sqlite
    pkgs.libiconv

    # ruby and gems
    pkgs.bundix
    gems
    gems.wrappedRuby
  ];
}
