/*
 * Copyright (c) 2026 Bitcraze AB
 *
 * SPDX-License-Identifier: Apache-2.0 OR MIT
 */

#include <zephyr/kernel.h>
#include <zephyr/sys/reboot.h>
#include <openthread/instance.h>
#include <openthread/platform/misc.h>

/* GPREGRET value that makes the UF2 bootloader stay in UF2 mode after a reset */
#define UF2_BOOTLOADER_MAGIC 0x57

otError __wrap_otPlatResetToBootloader(otInstance *aInstance)
{
	ARG_UNUSED(aInstance);

	NRF_POWER->GPREGRET = UF2_BOOTLOADER_MAGIC;
	sys_reboot(SYS_REBOOT_COLD);

	return OT_ERROR_NOT_CAPABLE;
}
