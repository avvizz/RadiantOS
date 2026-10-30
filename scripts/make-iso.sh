#!/usr/bin/env bash
# Пересборка ISO из binary/ через grub-mkrescue (BIOS + UEFI)
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $EUID -eq 0 ]] || { echo "Нужен root: sudo $0"; exit 1; }

apt-get install -y grub-pc-bin grub-efi-amd64-bin grub-common xorriso mtools

KERNEL="$(basename "$(ls binary/casper/vmlinuz-* | head -n1)")"
INITRD="$(basename "$(ls binary/casper/initrd.img-* | head -n1)")"
STAGE="$PWD/.iso-stage"

rm -rf "$STAGE"
cp -al binary "$STAGE" 2>/dev/null || cp -a binary "$STAGE"
rm -rf "$STAGE/boot/grub" "$STAGE/SHA256SUMS"
mkdir -p "$STAGE/boot/grub"

cat > "$STAGE/boot/grub/grub.cfg" <<CFG
set default=0
set timeout=5

menuentry "RadiantOS (live)" {
    linux  /casper/$KERNEL boot=casper
    initrd /casper/$INITRD
}
menuentry "RadiantOS (безопасный режим)" {
    linux  /casper/$KERNEL boot=casper nomodeset noapic nolapic
    initrd /casper/$INITRD
}
CFG

rm -f radiantos.iso
grub-mkrescue -o radiantos.iso "$STAGE"
rm -rf "$STAGE"
ls -lh radiantos.iso
