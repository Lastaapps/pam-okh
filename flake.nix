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
        let
          pam-okh = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          environment.systemPackages = [ pam-okh ];

          security.pam.services."pam-okh".text = ''
            auth sufficient ${pam-okh}/lib64/security/libpam_okh.so 1000
            account sufficient ${pam-okh}/lib64/security/libpam_okh.so
          '';
        };
    };
}
