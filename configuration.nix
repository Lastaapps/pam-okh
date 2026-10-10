# To test out pam-okh on NixOS run
# sudo nixos-rebuild test -I nixos-config=./configuration.nix
# Then you can use pamtester:
# pamtester --command "pamtester pam-okh $USER authenticate"
{ pkgs, ... }:
let
  pam-okh =
    with pkgs;
    stdenv.mkDerivation {
      name = "pam-okh";
      src = ./.;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/lib64/security
        cp $src/target/debug/libpam_okh.so $out/lib64/security
      '';
    };
in
{
  imports = [
    /etc/nixos/configuration.nix
  ];

  environment.systemPackages = [
    pam-okh
  ];

  security.pam.services."pam-okh".text = ''
    auth sufficient ${pam-okh}/lib64/security/libpam_okh.so 1000
    account sufficient ${pam-okh}/lib64/security/libpam_okh.so
  '';
}
