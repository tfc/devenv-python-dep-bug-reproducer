{
  description = "devenv bug reproducer";

  inputs = {
    devenv.url = "github:cachix/devenv";
    nixpkgs.url = "github:NixOS/nixpkgs";
    poetry2nix.url = "github:nix-community/poetry2nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.devenv.flakeModule
    ];
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        pkgsPoetry = pkgs.extend inputs.poetry2nix.overlay;
      in
      {
        packages.standalone_app = pkgsPoetry.poetry2nix.mkPoetryApplication {
          projectDir = ./standalone-app;
        };

        devenv.shells.default = {
          packages = [
            # This app requires psycopg2>=2.9.6 via standalone-app/pyproject.toml
            # which devenv should ideally not care about.
            config.packages.standalone_app

            # these are deps for psycopg2
            pkgs.gcc
            pkgs.postgresql
          ];

          languages.python = {
            enable = true;
            venv = {
              enable = true;
              requirements = ''
                psycopg2==2.9.5
              '';
            };
          };
        };
      };
  };
}
