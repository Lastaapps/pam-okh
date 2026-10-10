#!/usr/bin/env bash
# Used to test whether the flake evaluates (compiles)
# before using it from the main NixOS flake.

set -ex

nix flake check
nix build .#default
nix flake metadata
nix flake show
