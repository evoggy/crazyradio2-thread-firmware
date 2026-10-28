# This message
help:
    @just --list

sdk_version := "1.0.1"

# Build against this workspace even if ZEPHYR_BASE is set in the environment
export ZEPHYR_BASE := justfile_directory() / "zephyr"

# Prepare system to build the project. Alias for [fetch-ncs fetch-zephyr-sdk fetch-python-dep]
prepare-system:
	just fetch-ncs
	[ -d $HOME/.local/zephyr-sdk-{{sdk_version}} ] || just --yes fetch-zephyr-sdk
	just fetch-python-dep

# Download and install Zephyr SDK in ~/.local
[confirm("Download and install Zephyr SDK in ~/.local?")]
fetch-zephyr-sdk:
    mkdir -p $HOME/.local
    curl -L https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v{{sdk_version}}/zephyr-sdk-{{sdk_version}}_{{os()}}-{{arch()}}_minimal.tar.xz | tar xJ -C $HOME/.local/
    mkdir -p $HOME/.local/zephyr-sdk-{{sdk_version}}/gnu
    curl -L https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v{{sdk_version}}/toolchain_gnu_{{os()}}-{{arch()}}_arm-zephyr-eabi.tar.xz | tar xJ -C $HOME/.local/zephyr-sdk-{{sdk_version}}/gnu/

# Download the nRF Connect SDK (shallow, only the modules the build needs)
fetch-ncs: west-exists
    #!/usr/bin/env bash
    set -e
    # Test if the .west folder exists
    if [ ! -d .west ]; then
        # If not, then initialize the west project
        west init -l tools
    fi

    # Always update the west project
    west update --narrow -o=--depth=1

# Fetch python dependencies
fetch-python-dep:
    uv pip install -r zephyr/scripts/requirements-base.txt -r nrf/scripts/requirements-build.txt

# Build the OpenThread RCP firmware, result in build/coprocessor/zephyr/zephyr.uf2
build: west-exists
    west build -b crazyradio2 nrf/samples/openthread/coprocessor -d build -- \
        -DBOARD_ROOT={{justfile_directory()}} \
        -DEXTRA_ZEPHYR_MODULES={{justfile_directory()}}/module \
        -DEXTRA_CONF_FILE={{justfile_directory()}}/rcp.conf \
        -DEXTRA_DTC_OVERLAY_FILE={{justfile_directory()}}/rcp.overlay

# Reset a Crazyradio running this firmware to the UF2 bootloader
bootloader *port:
    python tools/reset-to-bootloader.py {{port}}

# Flash and reset Crazyradio to firmware mode using probe-rs
flash: west-exists
    west flash -d build
    sleep 1
    probe-rs reset --chip nrf52840_xxAA

west-exists:
	@type west &> /dev/null || (echo "West not found, please enter the venv with '. enter.sh'" && exit 1)
