{
  description = "cv gen";

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages.default =
        pkgs.writeShellApplication
        {
          name = "cv-gen";
          runtimeInputs = [
            pkgs.pandoc
            (pkgs.texliveBasic.withPackages
              (ps: [
                ps.etoolbox
                ps.fancyhdr
                ps.fontawesome
                ps.enumitem
                ps.hyperref
                ps.titlesec
                ps.parskip
                ps.metafont
              ]))
          ];
          text = builtins.readFile ./cv-pdf.sh;
        };
    });
}
