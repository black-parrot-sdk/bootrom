SECTIONS
{
    . = 0x0000;
    .text.start    : ALIGN(8) { *(.text.start)    }
    .cce_ucode_bin : ALIGN(8) { *(.cce_ucode_bin) }
}
