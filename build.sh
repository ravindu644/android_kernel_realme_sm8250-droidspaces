#!/bin/bash
clear
git submodule update --init --recursive
echo Cloning AnyKernel
git clone https://github.com/provasish/AnyKernel3.git anykernel

echo Cloning TC
git clone https://gitlab.com/provasishh/clang-20.git tc

DT=$(date +"%Y%m%d-%H%M")
config="vendor/kona-perf_defconfig vendor/oplus.config"

MAKE_PATH=$(pwd)/tc/build-tools/bin/
CROSS_COMPILE=$(pwd)/tc/aarch64-linux-android-4.9/bin/aarch64-linux-android-
KERNEL_ARCH=arm64
KERNEL_OUT=$(pwd)/out
export KERNEL_SRC=${KERNEL_OUT}
export CLANG_TRIPLE=aarch64-linux-gnu-
OUT_DIR=${KERNEL_OUT}
ARCH=${KERNEL_ARCH}
TARGET_INCLUDES=${TARGET_KERNEL_MAKE_CFLAGS}
TARGET_LINCLUDES=${TARGET_KERNEL_MAKE_LDFLAGS}

TARGET_KERNEL_MAKE_ENV+="CC=$(pwd)/tc/clang/bin/clang"

compile() {
echo compiling kernel...

BUILD_OPTIONS=(O=${OUT_DIR} ${TARGET_KERNEL_MAKE_ENV} LLVM_IAS=1 HOSTLDFLAGS="${TARGET_LINCLUDES}" ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip LLVM_IAS=1)

make "${BUILD_OPTIONS[@]}" $config droidspaces.config
make "${BUILD_OPTIONS[@]}" menuconfig || true
make "${BUILD_OPTIONS[@]}" -j$(nproc --all) |& tee build.log
}

zipping() {
echo zipping kernel...

cd anykernel || exit 1
    rm *zip
    cp ../out/arch/arm64/boot/Image .
    cp ../out/arch/arm64/boot/dtbo.img .
    cp ../out/arch/arm64/boot/dtb .
    zip -r9 Droidspaces-El-Diablo-AOSP-${DT}.zip *
    rm Image dtbo.img dtb
    cd ..
}

remove() {
echo removing compiled images....
cd out/arch/arm64/boot
rm Image dtbo.img dtb
cd -
}

compile
zipping
remove
