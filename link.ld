SECTIONS
{
    . = 0x0000;
    .text.start : { *(.text.start) }
    .cce_ucode_bin : { *(.cce_ucode_bin) }
}
