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
    
    bl      clean_and_invalideate_dcache

    bl      invalidate_icache

    disable_mmu sctlr_el1,x9
    
    ldr     x9, =MAIR(0x00, MT_DEVICE_nGnRnE) | \
                 MAIR(0x04, MT_DEVICE_nGnRE) | \
                 MAIR(0x0c, MT_DEVICE_GRE) | \
                 MAIR(0x44, MT_NORMAL_NC) | \
                 MAIR(0xff, MT_NORMAL) | \
                 MAIR(0xaa, MT_NORMAL_WT)
    msr     mair_el1, x9

    ldr     x10, =TCR_TxSZ(48) | TCR_IRGN_WBWA | TCR_ORGN_WBWA | TCR_TG0_4K | TCR_TG1_4K | TCR_ASID16 | TCR_ISH
    mrs     x9, ID_AA64MMFR0_EL1
    bfi     x10, x9, #32, #3
    msr     tcr_el1, x10

    ldr     x9, =kernel_boot_level_0_table
    ldr     x9, [x9]
    msr     ttbr0_el1, x9
    ldr     x9, =kernel_boot_level_0_table
    ldr     x9, [x9]
    msr     ttbr1_el1, x9
    isb

    tlbi    vmalle1is
    dsb     ish
    isb


    enable_mmu sctlr_el1,x9

    adrp    x8, arm_vector_table
    msr     vbar_el1, x8

    ldp     x29, x30, [sp], #16
    ret
END_FUNC(switch_translation_tables_el1)
