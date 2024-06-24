#!/bin/zsh
#
# DO NOT SOURCE THIS FILE BEFORE ~/.zshrc
#

##############################################################################
#
# Embedded Firmware
#
##############################################################################

# Ensure GCC colors are activated in the terminal
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export JSPEED=2000

alias jlink='JLinkExe -if SWD -speed $JSPEED'
alias jlinksnr='jlink -selectemubysn'
alias jlink_m4='jlink -Device $JDEV_M4'
alias jlink_m4snr='jlink_m4 -selectemubysn'
alias jlink_m33='jlink -Device $JDEV_M33'
alias jlink_m33snr='jlink_m33 -selectemubysn'

function jlinkgdb {
    usage="Usage: jlinkgdb <snr> <jlink dev id> [JTAG|SWD] [OPTIONS]"

    snr=$1; shift;
    device=$1; shift;
    interface=$1; shift;

    if [[ -z $snr || -z $device || -z $interface ]]; then
        echo $usage
        return
    fi

    JLinkGDBServerCLExe -select USB=$snr -device $device -endian little -if $interface -LocalhostOnly -noir -port 2331 $@
}

export JDEV_52810="nRF52810_xxAA"
export JDEV_52811="nRF52811_xxAA"
export JDEV_52832="nRF52832_xxAA"
export JDEV_52833="nRF52833_xxAA"
export JDEV_52820="nRF52820_xxAA"
export JDEV_52840="nRF52840_xxAA"
export JDEV_5340A="nRF5340_xxAA_APP"
export JDEV_5340N="nRF5340_xxAA_NET"
export JDEV_9160="nRF9160_xxAA"

alias jlink_52832='jlink -Device $JDEV_52832'
alias jlink_52833='jlink -Device $JDEV_52833'
alias jlink_52840='jlink -Device $JDEV_52840'
alias jlink_5340='jlink -Device $JDEV_5340A'
alias jlink_5340n='jlink -Device $JDEV_5340N'
alias jlink_9160='jlink -Device $JDEV_9160'

if [ -z $GNUARMEMB_TOOLCHAIN_PATH ]; then
    export GNUARMEMB_TOOLCHAIN_PATH="$TOOLS/gnuarmemb/latest"
fi

##############################################################################
#
# Embedded Firmware - Zephyr and nRF Connect SDK (NCS)
#
##############################################################################

if [ -z $NCS ]; then
    export NCS="$HOME/ncs"
fi

export NCS_SAMPLES="$NCS/nrf/samples"
export NCS_HAL="$NCS/modules/hal/nordic"
export NRF_BASE="$NCS/nrf"

if [ -z $ZEPHYRPROJECT ]; then
    export ZEPHYRPROJECT="$HOME/zephyrproject"
fi

function zbz()
{
    export ZEPHYR_BASE="$ZEPHYRPROJECT/zephyr"
    export ZB="$ZEPHYR_BASE"
    export ZEPHYR_MCUBOOT_MODULE_DIR="$ZEPHYR_BASE/bootloader/mcuboot"

    export TWISTER_OUT_DIR="$ZEPHYR_BASE/_twister"
    export TWISTER_REPORT_DIR="$ZEPHYR_BASE/_twister_report"
    export ZSAMPLES="$ZEPHYR_BASE/samples"
}

function zbn()
{
    export ZEPHYR_BASE="$NCS/zephyr"
    export ZB="$ZEPHYR_BASE"
    export ZEPHYR_MCUBOOT_MODULE_DIR="$ZEPHYR_BASE/bootloader/mcuboot"

    export TWISTER_OUT_DIR="$ZEPHYR_BASE/_twister"
    export TWISTER_REPORT_DIR="$ZEPHYR_BASE/_twister_report"
    export ZSAMPLES="$ZEPHYR_BASE/samples"
}

# Default to standard zephyr
zbz

# Local directory shortcuts
export ZSMP="$ZSAMPLES/subsys/mgmt/mcumgr/smp_svr"
export MBOOT="bootloader/mcuboot"
export MBOOTZ="$MBOOT/boot/zephyr"
export ZHELLO="$ZSAMPLES/hello_world"
export BOOT_SCRIPTS="nrf/scripts/bootloader"
export B0_SIGN_OUT="zephyr/nrf/subsys/bootloader/generated"
export NRF_BLE="nrf/samples/bluetooth"
export BLE_UART="$NRF_BLE/peripheral_uart"

export S0_HEX='zephyr/signed_by_b0_s0_image.hex'
export S1_HEX='zephyr/signed_by_b0_s1_image.hex'
export APP_UPD_HEX='zephyr/app_moved_test_update.hex'
export NET_UPD_HEX='zephyr/net_core_app_moved_test_update.hex'

# Point the build system to the SDK install in the toolchain directory if one
# exists, otherwise let it automatically grab one from one of the common
# locations, e.g. $HOME/zephyr-sdk-*
#
# Furthermore, we point to a specific active directory that has the specific SDK
# version to use symbolically linked inside of it. This is because pointing to
# a directory containing multiple versions will always take the highest,
# preventing going back to an earlier version to test.
if [ -d $TOOLS/zephyr-sdk/active ]; then
    export ZEPHYR_SDK_INSTALL_DIR="$TOOLS/zephyr-sdk/active"
    export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
else
    export ZEPHYR_TOOLCHAIN_VARIANT="gnuarmemb"
fi

function zgnu()
{
    export ZEPHYR_SDK_INSTALL_DIR=""
    export ZEPHYR_TOOLCHAIN_VARIANT="gnuarmemb"
}

function zsdk()
{
    if [ ! -d $TOOLS/zephyr-sdk/latest ]; then
        export ZEPHYR_SDK_INSTALL_DIR=""
    else
        export ZEPHYR_SDK_INSTALL_DIR="$TOOLS/zephyr-sdk/active"
    fi

    export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
}

function zenv()
{
    echo "ZEPHYR_BASE: ${ZEPHYR_BASE}"
    echo "ZEPHYR_SDK_INSTALL_DIR: ${ZEPHYR_SDK_INSTALL_DIR}"
    echo "ZEPHYR_TOOLCHAIN_VARIANT: ${ZEPHYR_TOOLCHAIN_VARIANT}"
}

function ztwist()
{
    if [ ! -f $BIN/twister ]; then
        twister="$ZEPHYR_BASE/scripts/twister"
    else
        twister="$BIN/twister"
    fi

    echo "Using '$twister'"

    $twister -v -N --outdir $TWISTER_OUT_DIR --report-dir $TWISTER_REPORT_DIR $@
}

function rmtwist
{
    if [ -f $CARGO_ROOT_DIR/bin/fd ]; then
        fd -I -t d "(^twister$|^_twister.*$)" -d 1 -x sh -c "echo Removing {}; rm -r {}" \;
    else
        echo "Not yet defined for find."
    fi
}

export ZVENV="$PYVENV/zvenv"
alias zva='source $ZVENV/bin/activate'
export NVENV="$PYVENV/ncs_venv"
alias nva='source $NVENV/bin/activate'

alias wupd='west update -f smart -k'
alias wfl='west flash --skip-rebuild'
alias wdn='west debug -r nrfjprog'
alias wdj='west debug -r jlink'

alias zlint='pylint --rcfile="${ZEPHYR_BASE}/scripts/ci/pylintrc"'

function pm_report()
{
    builddir=$1

    if [[ -z $builddir ]] || [[ ! -d $builddir ]]; then
        echo "Invalid build directory: $builddir"
        exit 1
    fi

    if [ -z $2 ]; then
        netdir="hci_rpmsg"
    else
        netdir="$2"
    fi

    if [ ! -f $builddir/partitions.yml ]; then
        return
    fi

    echo
    python3 nrf/scripts/partition_manager_report.py -i $builddir/partitions.yml

    if [ -d $builddir/$netdir ]; then
        echo
        echo
        python3 nrf/scripts/partition_manager_report.py -i $builddir/$netdir/partitions_CPUNET.yml
    fi
}

function wbl()
{
    arg=$1
    with_sha=

    if [[ "$arg" =~ "-v" ]]; then
        verbose=-v
        shift
    else
        verbose=
    fi

    if [[ "$arg" =~ "-S" ]]; then
        with_sha=1
        shift
    fi

    board=$1
    shift

    if [ -z $board ]; then
        echo "Must specify a board target."
        return
    elif [ ! -z $with_sha ]; then
        commit_sha=$(git rev-parse --short HEAD)
        builddir="${BUILD_DIR}_${board}-${commit_sha}"
    else
        builddir="${BUILD_DIR}_${board}"
    fi

    if [ -d $builddir ]; then
        echo -n "Build directory '${builddir}' exists. Remove before building? [y/N]: "

        # Wait for input for 30s before using the default option.
        read -t 30 replace

        if [[ $replace =~ "y" ]] || [[ $replace =~ "Y" ]]; then
            echo "Removing build directory $builddir"
            echo
            rm -r $builddir
        fi
    fi

    west $verbose build -p auto -b $board -d $builddir $@

    # Print partition report on successful build
    if [ $(echo $?) -eq 0 ]; then
        pm_report $builddir
    fi
}

function wrom()
{
    west build -t rom_report -d $1 | batty
}

function wram()
{
    west build -t ram_report -d $1 | batty
}

function wmenu()
{
    west build -t menuconfig -d $1
}

function gnugdb()
{
    build=$1

    if [ -z $build ]; then
        echo "Must specify a .elf file."
        return
    fi

    if [ -z $2 ]; then
        port=2331
    else
        port=$2
    fi

    echo "Connecting to ${build}/zephyr/zephyr.elf on remote port ${port}"
    echo

    arm-none-eabi-gdb $build/zephyr/zephyr.elf -ex "target remote :${port}" --tui
}

function zephyr_gdb() {
    build=$1

    use_term=$TERM
    if [[ $TERM =~ "alacritty" ]]; then
        use_term=xterm-256color
    fi

    port=2331

    TERM=$use_term arm-zephyr-eabi-gdb $1 -ex "target remote :${port}" --tui
}

function show_dts() {
    build_dir=$1

    if [[ $2 =~ "-n" ]] then;
        numbers=$@
    fi

    less $numbers "${build_dir}/zephyr/zephyr.dts"
}

function dts_defs() {
    build_dir=$1

    less -n "${build_dir}/zephyr/include/generated/devicetree_unfixed.h"
}

# Removes Zephyr board revision builds
function rmrev() {
    if [ -f $CARGO_ROOT_DIR/bin/fd ]; then
        fd -I -t d "(^${BUILD_DIR}.*@.*$)" -d 1 -x sh -c "echo Removing {}; rm -r {}" \;
    else
        echo "Not yet defined for find."
    fi
}
