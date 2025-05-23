/*
 * The bootrom loads the CCE ucode and the processor configuration and switches to the program for execution
 */

// Sentinel value for CCE ucode
#define CCE_INSTR_END 0xFFFFFFFFFFFFFFFF

// Configuration parameters
#define CFG_CCE_MODE_ADDR    0x00200608
#define CFG_DCACHE_MODE_ADDR 0x00200408
#define CFG_ICACHE_MODE_ADDR 0x00200208

#define CFG_CCE_UCODE_BASE_ADDR 0x00208000

#define CFG_CORE_OFFSET 24

#define _INCBIN(x) .incbin #x

.section .bootrom.text
.globl _start
_start:
    // Clear out the registers, useful for avoiding x-prop and for bare-metal
    //   programs
    li x0, 0
    li x1, 0
    li x2, 0
    li x3, 0
    li x4, 0
    li x5, 0
    li x6, 0
    li x7, 0
    li x8, 0
    li x9, 0
    li x10, 0
    li x11, 0
    li x12, 0
    li x13, 0
    li x14, 0
    li x15, 0
    li x16, 0
    li x17, 0
    li x18, 0
    li x19, 0
    li x20, 0
    li x21, 0
    li x22, 0
    li x23, 0
    li x24, 0
    li x25, 0
    li x26, 0
    li x27, 0
    li x28, 0
    li x29, 0
    li x30, 0
    li x31, 0

    // Read hartid to set offset for tile-level configurations
    csrr t6, mhartid
    slli t6, t6, CFG_CORE_OFFSET

#ifndef COH_PROTO_none
    // Copy CCE microcode from bootrom to CCE instruction RAM
    // TODO: Do not need to do this copy if there's not a programmable
    //    CCE. Should first query platform data
    la t0, cce_ucode_bin
    li t1, CFG_CCE_UCODE_BASE_ADDR
    or t1, t1, t6
    li t2, CCE_INSTR_END
load_ucode:
    lwu t3, 0(t0)
    lwu t4, 4(t0)
    slli t5, t4, 32
    or t5, t5, t3
    sd t5, 0(t1)
    addi t0, t0, 8
    addi t1, t1, 8
    bne t5, t2, load_ucode
#endif

    // Load the configuration data for the core. This switches the cache modes
    //   to enable coherent, cached memory requests
load_config:
    li t0, 1

    // First switch the CCE mode so that we don't accidentally send cached
    //   requests before they can be handled
    li t1, CFG_CCE_MODE_ADDR
    or t1, t1, t6
    sw t0, 0(t1)

    // Then enable D$ and I$ (order doesn't really matter)
    li t1, CFG_DCACHE_MODE_ADDR
    or t1, t1, t6
    sw t0, 0(t1)

    li t1, CFG_ICACHE_MODE_ADDR
    or t1, t1, t6
    sw t0, 0(t1)

    // Fence to make sure configuration is set before continuing
    fence
    // Fence I$ to make sure we start fetching from cached mode
    fence.i
    // NOP for padding
    nop

    // Set up the debug mode exit to DRAM base address
    li t0, 0x80000000
    csrw dpc, t0
    csrwi dcsr, 0x3

    // Zero out used registers
    li t0, 0
    li t1, 0
    li t2, 0
    li t3, 0
    li t4, 0
    li t5, 0
    li t6, 0

    dret
// Should not get here
halt:
    j halt


.section .bootrom.data
.balign 8
cce_ucode_bin:
#if defined(COH_PROTO_ei)
_INCBIN(cce_ucode.ei.bin)
#elif defined(COH_PROTO_msi)
_INCBIN(cce_ucode.msi.bin)
#elif defined(COH_PROTO_mesi)
_INCBIN(cce_ucode.mesi.bin)
#elif defined(COH_PROTO_moesif)
_INCBIN(cce_ucode.moesif.bin)
#elif defined(COH_PROTO_hybrid)
_INCBIN(cce_ucode.hybrid.bin)
#endif

