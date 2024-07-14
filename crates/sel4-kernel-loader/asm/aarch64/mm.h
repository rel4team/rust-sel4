/*
 * Copyright 2023, Colias Group, LLC
 * Copyright 2014, General Dynamics C4 Systems
 *
 * SPDX-License-Identifier: GPL-2.0-only
 */

#include "registers.h"

#ifdef CONFIG_ARM_PA_SIZE_BITS_40
#define TCR_PS TCR_PS_1T
#else
#define TCR_PS TCR_PS_16T
#endif

#define TCR_ISH 0

#define MT_DEVICE_nGnRnE  0
#define MT_DEVICE_nGnRE   1
#define MT_DEVICE_GRE     2
#define MT_NORMAL_NC      3
#define MT_NORMAL         4
#define MT_NORMAL_WT      5
#define MAIR(_attr, _mt)  ((_attr) << ((_mt) * 8))

.macro disable_mmu sctlr tmp
    mrs     \tmp, \sctlr
    bic     \tmp, \tmp, #(1 << 0)
    bic     \tmp, \tmp, #(1 << 2)
    bic     \tmp, \tmp, #(1 << 12)
    msr     \sctlr, \tmp
    isb
.endm

.macro enable_mmu sctlr tmp
    mrs     \tmp, \sctlr
    orr     \tmp, \tmp, #(1 << 0)
    orr     \tmp, \tmp, #(1 << 2)
    orr     \tmp, \tmp, #(1 << 12)
    msr     \sctlr, \tmp
    isb
.endm
