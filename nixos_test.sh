#!/usr/bin/env bash

set -e

FORCE=false
TARGET=$HOST
NIXOS_FLAKE_HOME="${HOME}/dotfiles"


for arg in "$@"; do
    case "$arg" in
        -f|--force)
            FORCE=true
            ;;
        *)
            ;;
    esac
done

pushd "${NIXOS_FLAKE_HOME}" || exit

BEFORE_HASH=$(sha256sum flake.lock 2>/dev/null)
nix flake update pam-okh
AFTER_HASH=$(sha256sum flake.lock 2>/dev/null)

if [ "$FORCE" = true ] || [ "$BEFORE_HASH" != "$AFTER_HASH" ]; then
    sudo nixos-rebuild test --flake .#"${TARGET}"
else
    echo "Lock file not updated, skipping test switch. Use --force to run forced nixos-rebuild test."
fi

popd || exit

set -x

pamtester -v pam-okh "${USER}" authenticate

