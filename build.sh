#!/usr/bin/env bash
# Сборка RadiantOS ISO. Запускать на Ubuntu 22.04/24.04 (или в такой VM/контейнере).
set -euo pipefail
cd "$(dirname "$0")"

VERSION="$(cat VERSION)"
DATE="$(date +%Y%m%d)"

if [[ $EUID -ne 0 ]]; then
    echo "Запусти от root: sudo ./build.sh" >&2
    exit 1
fi

echo ">>> Проверка зависимостей"
apt-get update
apt-get install -y live-build debootstrap squashfs-tools xorriso \
    grub-pc-bin grub-efi-amd64-bin mtools isolinux syslinux-utils \
    ubuntu-keyring gnupg

echo ">>> Очистка и настройка"
lb clean --purge || true
lb config

echo ">>> Сборка (займёт 20-60 минут)"
lb build 2>&1 | tee build.log

ISO="$(ls -1 *.iso 2>/dev/null | head -n1 || true)"
if [[ -z "$ISO" ]]; then
    echo "ISO не найден, смотри build.log" >&2
    exit 1
fi
OUT="radiantos-${VERSION}-${DATE}-amd64.iso"
mv "$ISO" "$OUT"
sha256sum "$OUT" > "$OUT.sha256"
echo ">>> Готово: $OUT"
