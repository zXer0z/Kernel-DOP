#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
# Kernel-DOP reference build. No downloads, packaging or device operations.
set -euo pipefail

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
out="$source_dir/out-dop"
jobs=${JOBS:-4}
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo 'JOBS must be a positive integer.' >&2; exit 2; }

for tool in make clang-16 ld.lld-16 llvm-ar-16 llvm-nm-16 llvm-objcopy-16 \
    llvm-objdump-16 llvm-strip-16 aarch64-linux-gnu-gcc arm-linux-gnueabi-gcc \
    bison flex bc python3; do
    command -v "$tool" >/dev/null || { printf 'Missing dependency: %s\n' "$tool" >&2; exit 2; }
done

mkdir -p "$out"
if [[ ! -e "$out/.config" ]]; then
    cp "$source_dir/dop/config/v60_dop_lab3.config" "$out/.config"
else
    echo 'Keeping existing out-dop/.config; the reference configuration is in dop/config/.'
fi

export KBUILD_BUILD_USER=V60AudioLab KBUILD_BUILD_HOST=local-verification
args=(O="$out" ARCH=arm64 CC=clang-16 HOSTCC=clang-16 LLVM=1 LLVM_IAS=1
    CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu-
    CROSS_COMPILE_COMPAT=arm-linux-gnueabi- CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    LD=ld.lld-16 AR=llvm-ar-16 NM=llvm-nm-16 OBJCOPY=llvm-objcopy-16
    OBJDUMP=llvm-objdump-16 STRIP=llvm-strip-16)

cd "$source_dir"
make "${args[@]}" olddefconfig
make "${args[@]}" -j"$jobs" Image dtbs
sha256sum "$out/arch/arm64/boot/Image"
printf '\nBuilt kernel Image: %s\nNot a flashable boot image. No device was modified.\n' "$out/arch/arm64/boot/Image"
