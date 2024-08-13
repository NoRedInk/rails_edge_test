{ ... }:
let
  sources = import ./nix/sources.nix { };
  nixpkgs = import sources.nixpkgs { };
  gems = nixpkgs.bundlerEnv {
    name = "rails_edge_test";
    gemfile = nix/Gemfile;
    lockfile = nix/Gemfile.lock;
    ruby = nixpkgs.ruby_3_1;
    gemdir = ./nix;
  };
in
with nixpkgs;
stdenv.mkDerivation {
  FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  name = "rails_edge_test";
  buildInputs = [
    gems
    gems.wrappedRuby
    # nixpkgs.ruby_3_1
    nixpkgs.sqlite
  ];
}
