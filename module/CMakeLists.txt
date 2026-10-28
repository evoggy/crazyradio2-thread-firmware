# Copyright (c) 2026 Bitcraze AB
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

if(CONFIG_CRAZYRADIO2_UF2_BOOTLOADER_RESET)
  zephyr_library()
  zephyr_library_sources(uf2_bootloader.c)

  # Zephyr's OpenThread platform implements otPlatResetToBootloader() with boot
  # mode retention or a GPIO only, send OpenThread to the UF2 version instead
  zephyr_ld_options(-Wl,--wrap=otPlatResetToBootloader)
endif()
