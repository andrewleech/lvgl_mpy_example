set(IDF_TARGET esp32s3)

#
# Generate sdkconfig.partitions file
#
file(WRITE ${MICROPY_BOARD_DIR}/sdkconfig.partitions
           "CONFIG_ESPTOOLPY_FLASHSIZE_16MB=y\n")
file(APPEND ${MICROPY_BOARD_DIR}/sdkconfig.partitions
            "CONFIG_PARTITION_TABLE_CUSTOM=y\n")
file(APPEND ${MICROPY_BOARD_DIR}/sdkconfig.partitions
            "CONFIG_PARTITION_TABLE_CUSTOM_FILENAME=\"${MICROPY_BOARD_DIR}/partitions.csv\"\n")

set(SDKCONFIG_DEFAULTS
    ${MICROPY_PORT_DIR}/boards/sdkconfig.base
    ${MICROPY_PORT_DIR}/boards/sdkconfig.usb
    ${MICROPY_PORT_DIR}/boards/sdkconfig.ble
    ${MICROPY_PORT_DIR}/boards/sdkconfig.240mhz
    ${MICROPY_BOARD_DIR}/sdkconfig.board
    ${MICROPY_BOARD_DIR}/sdkconfig.partitions
)

set(MICROPY_FROZEN_MANIFEST ${MICROPY_BOARD_DIR}/manifest.py)

# set(EXTMOD_LCD 1)

# Set the user C modules to include in the build.
set(USER_C_MODULES
    # ${PROJECT_DIR}/cmodules/lcd_binding_micropython/lcd/micropython.cmake
    ${PROJECT_DIR}/cmodules/lv_binding_micropython/bindings.cmake
    # ${PROJECT_DIR}/cmodules/lv_binding_micropython/micropython.cmake
    ${PROJECT_DIR}/cmodules/st7789s3_mpy/st7789/micropython.cmake
)
