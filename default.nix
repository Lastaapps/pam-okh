{
  lib,
  rustPlatform,
  pkgs,
}:

let
  cargoToml = fromTOML (builtins.readFile ./Cargo.toml);
in
rustPlatform.buildRustPackage {
  pname = cargoToml.package.name;
  version = cargoToml.package.version;
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  # useNextest = true;

  postInstall = ''
    mkdir -p $out/lib64/security
    cp $out/lib/libpam_okh.so $out/lib64/security/
  '';

  buildInputs = with pkgs; [
    linux-pam
  ];

  meta = {
    description = "PAM - Okamžikové heslo";
    homepage = "https://github.com/LastaApps/pam-okh";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
