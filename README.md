# OTP PAM - Okamžikové heslo

This is **a toy** project aiming to implement OTP PAM module for Linux.
The project is written in Rust and ready for NixOS.
No support is provided, this is not a production-ready module, nor it is secure!

## Usage on NixOS

Other systems are not covered here,
as installation there must be trivial compared to the pain of NixOS.

### Local installation


For local development, see bellow.
This section provides instructions for proper local installation.
If your NixOS installation is derived from a `configuration.nix` file,
see PAM Random for an example use.
For *flake based* systems like mine, add the following to your system `flake.nix`.

```nix
inputs = {
  pam-okh.url = "github:lastaapps/pam-okh";
  ...
}
outputs = { self, ... }@inputs:
{
  nixosConfigurations = {
    your_target = lib.nixosSystem {
      modules = [
        inputs.pam-okh.nixosModules.default
        ./configuration.nix
        ...
      ];
    };
    ...
  };
```

Then run `nixos-rebuild switch --flake .#"your_target"`,
and you're ready for further general PAM configuration fun.
You may use `test` instead of `switch` to evaluate the module.
Run `pamtester` to test the PAM module.

```bash
nix-shell -p pamtester
pamtester -v pam-okh "${USER}" authenticate
```

### Local development

Clone the repository and run `direnv allow`
to load corresponding Rust environment and `pamtester`.
In your system flake, use `dev` profile instead of `default`
for rapid development cycle - this creates symlinks to local build directory.

This variant is not secure for permanent setup in any way
as anyone can replace the libraries and authenticate!

```nix
inputs = {
  pam-okh.url = "path:/full/path/to/project";
  ...
}
outputs = { self, ... }@inputs:
{
  nixosConfigurations = {
    your_target = lib.nixosSystem {
      modules = [
        (inputs.pam-okh.nixosModules.dev "/full/path/to/project")
        ./configuration.nix
        ...
      ];
    };
    ...
  };
```

Then run `cargo build` and
`nixos-rebuild test --flake .#"your_target"` to create symlinks to your local build.
Then you can run `./build_test.sh` to test the module.


## Acknowledgements

NixOS integration and basic Rust structure and PAM integration was taken from
[PAM Random](https://github.com/ChocolateLoverRaj/pam-random).
Thank you for inspiration!

## Sources

- [Linux PAM](https://github.com/linux-pam/linux-pam)
- [PAM Random](https://github.com/ChocolateLoverRaj/pam-random)
- Gemini chats for NixOS setup

## License

This project is licensed under MIT license.

