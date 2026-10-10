# PAM - Okamžikové heslo

This is **a toy** project aiming to implement OTP PAM module for Linux.
The project is written in Rust and ready for NixOS.
No support is provided, this is not a production-ready module, nor it is secure!

## Acknowledgements

NixOS integration and basic Rust structure and PAM integration was taken from
[PAM Random](https://github.com/ChocolateLoverRaj/pam-random).
Thank you for inspiration!

## Usage on NixOS

For development, run `direnv allow` to load corresponding Rust compiler and `pamtester`.
If your NixOS installation is derived from a `configuration.nix` file, see PAM Random for an example use.
For flake based systems like mine, add the following to your system `flake.nix`.

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
        inputs.pam-okh.nixosModules.default
        ./configuration.nix
        ...
      ];
    };
    ...
  };
```

Then go to your system flake directory and for testing run:

```bash
# Update lock file in case of incremental changes
nix flake update pam-okh
# Apply new system with PAM module included without touching boot entries
sudo nixos-rebuild test --flake .#"your_target"
```

Then run `pamtester` to test your PAM module.

```bash
nix-shell -p pamtester
pamtester -v pam-okh "${USER}" authenticate
```


## Sources

- [Linux PAM](https://github.com/linux-pam/linux-pam)
- [PAM Random](https://github.com/ChocolateLoverRaj/pam-random)
- Gemini chats for NixOS setup

## License

This project is licensed under MIT license.

