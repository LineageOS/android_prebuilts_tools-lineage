#!/bin/bash -ex

: "${OUT_DIR:?Must set OUT_DIR}"
TOP=$(pwd)

UNAME="$(uname)"
case "$UNAME" in
Linux)
    OS='linux'
    ;;
Darwin)
    OS='darwin'
    ;;
*)
    exit 1
    ;;
esac

build_soong=1
clean=t
[[ "${1:-}" != '--resume' ]] || clean=''

if [ -n ${build_soong} ]; then
    SOONG_OUT=${OUT_DIR}/soong
    SOONG_HOST_OUT=${OUT_DIR}/soong/host/${OS}-x86
    [[ -z "${clean}" ]] || rm -rf ${SOONG_OUT}
    mkdir -p ${SOONG_OUT}
    cat > ${SOONG_OUT}/soong.variables << EOF
{
    "Platform_sdk_version": 0,
    "Allow_missing_dependencies": true,
    "DeviceName": "generic_arm64",
    "DeviceArch": "arm64",
    "DeviceArchVariant": "armv8-a",
    "DeviceAbi": ["arm64-v8a"],
    "HostArch": "x86_64",
    "VendorVars": {
        "lineageVarsPlugin": {
            "KERNEL_ARCH": "",
            "KERNEL_BUILD_OUT_PREFIX": "",
            "KERNEL_CROSS_COMPILE": "",
            "KERNEL_MAKE_CMD": "",
            "KERNEL_MAKE_FLAGS": "",
            "PATH_OVERRIDE_SOONG": "",
            "TARGET_KERNEL_SOURCE": ""
        }
    }
}
EOF
    SOONG_BINARIES=(
        patchelf
    )

    binaries="${SOONG_BINARIES[@]/#/${SOONG_HOST_OUT}/bin/}"

    # Build everything
    build/soong/soong_ui.bash --make-mode --skip-make ${binaries}
fi
