{
  description = "Blog";

  inputs = {
    # Consider pinning to a stable channel unless you specifically need unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            # Elm toolchain parity with dm6-elm
            pkgs.elmPackages.elm
            pkgs.elmPackages.elm-format
            pkgs.elmPackages.elm-language-server
            pkgs.elmPackages.elm-test
            pkgs.elmPackages.elm-review

            # Your blog stack
            pkgs.just
            pkgs.leiningen
            pkgs.mprocs
            pkgs.nodePackages.prettier
            # Prefer LTS unless you truly need 24
            pkgs.nodejs_20
            pkgs.nushell
            pkgs.pnpm
            pkgs.qrtool
            pkgs.rsync
            pkgs.typescript
            pkgs.nodePackages.typescript-language-server
          ];
        };
      }
    );
}
