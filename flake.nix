{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      mkModule = package: {
        environment.systemPackages = [ package ];

        security.pam.services."pam-okh".text = ''
          auth sufficient ${package}/lib64/security/libpam_okh.so 1000
          account sufficient ${package}/lib64/security/libpam_okh.so
        '';
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        pam-okh = pkgs.callPackage ./default.nix { };
      in
      {
        # Builds the library itself
        packages.default = pam-okh;

        # Creates a shell dev environment for direnv
        devShells.default = pkgs.mkShell {
          inputsFrom = [ pam-okh ];
          packages = with pkgs; [
            cargo
            rustc
            rust-analyzer
            clippy
            rustfmt
            # For testing
            pamtester
          ];
        };
      }
    )
    // {
      # Installs the library into a NixOS system
      nixosModules.default =
        { pkgs, ... }:
        mkModule self.packages.${pkgs.stdenv.hostPlatform.system}.default;

      # Development module pointing to local debug build output
      nixosModules.dev =
        project_dir:
        { pkgs, ... }:
        let
          debugLibPath = "${project_dir}/target/debug/libpam_okh.so";

          devPackage = pkgs.runCommandLocal "pam-okh-dev" { } ''
            mkdir -p $out/lib/security $out/lib64/security
            ln -s ${debugLibPath} $out/lib/libpam_okh.so
            ln -s ${debugLibPath} $out/lib64/security/libpam_okh.so
          '';
        in
        mkModule devPackage;
    };
}
