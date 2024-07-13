/*
 * Copyright 2023, Colias Group, LLC
 * Copyright 2014, General Dynamics C4 Systems
 *
 * SPDX-License-Identifier: GPL-2.0-only
 */

#include "macros.h"
#include "registers.h"
#include "mm.h"

.text

BEGIN_FUNC(switch_translation_tables_el2)

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    bl      clean_and_invalideate_dcache

    disable_mmu sctlr_el2, x8

    bl      invalidate_icache

    ldr     x8, =kernel_boot_level_0_table
    ldr     x8, [x8]
    msr     ttbr0_el2, x8
    isb

    tlbi    alle2is
    dsb     ish
    isb

    enable_mmu  sctlr_el2, x8

    ic      ialluis
    dsb     ish
    isb

    tlbi    alle2is
    dsb     ish
    isb

    ldp     x29, x30, [sp], #16

    ret

END_FUNC(switch_translation_tables_el2)

BEGIN_FUNC(drop_to_el1)
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    bl      clean_and_invalideate_dcache
    
    disable_mmu sctlr_el2,x9
    bl      invalidate_icache

    mov     x9, #(1 << 31)
    msr     hcr_el2, x9

    mov     x9, #0x33ff
    msr     cptr_el2, x9
    msr     hstr_el2, xzr
    msr     vttbr_el2, xzr

    disable_mmu sctlr_el1 , x9

    mov     x9, #(PSR_F_BIT | PSR_I_BIT | PSR_A_BIT | PSR_D_BIT | PSR_MODE_EL1h)
    msr     spsr_el2, x9

    ldp     x29, x30, [sp], #16
    mov     x10, sp
    msr     sp_el1, x10
    msr     elr_el2, x30
    eret
END_FUNC(drop_to_el1)

BEGIN_FUNC(switch_translation_tables_el1)
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    isb
    ldp     x29, x30, [sp], #16
    ret
END_FUNC(switch_translation_tables_el1)
