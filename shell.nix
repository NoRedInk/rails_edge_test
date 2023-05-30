{ ... }:
let
  sources = import ./nix/sources.nix { };
  nixpkgs = import sources.nixpkgs { };
  gems = nixpkgs.bundlerEnv {
    name = "rails_edge_test";
    gemfile = nix/Gemfile;
    lockfile = nix/Gemfile.lock;
    ruby = nixpkgs.ruby;
    gemdir = ./nix;
  };
in with nixpkgs;
stdenv.mkDerivation {
  name = "rails_edge_test";
  buildInputs = [
    gems gems.wrappedRuby
    # nixpkgs.ruby
  ];
}
