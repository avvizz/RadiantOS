#!/usr/bin/env bash
# Сборка RadiantOS ISO. Запускать на Ubuntu 22.04/24.04/26.04 (хост, WSL2 или VM).
set -euo pipefail
cd "$(dirname "$0")"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "Запусти от root: sudo -i, затем ./build.sh" >&2
    exit 1
fi

VERSION="$(cat VERSION)"
DATE="$(date +%Y%m%d)"

echo ">>> Зависимости"
apt-get update
apt-get install -y live-build debootstrap squashfs-tools xorriso \
    grub-pc-bin grub-efi-amd64-bin grub-common mtools ubuntu-keyring gnupg

echo ">>> Настройка и сборка системы (20-60 минут)"
lb clean || true
lb config
lb build 2>&1 | tee build.log

echo ">>> Упаковка ISO (BIOS + UEFI)"
./scripts/make-iso.sh

OUT="radiantos-${VERSION}-${DATE}-amd64.iso"
mv radiantos.iso "$OUT"
sha256sum "$OUT" > "$OUT.sha256"
echo ">>> Готово: $OUT"
