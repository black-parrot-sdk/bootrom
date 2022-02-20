SECTIONS
{
    . = 0x00000;
    .text.start    : ALIGN(8)      { KEEP(*(.text.start)) }
    .data          : ALIGN(8)      { KEEP(*(.data))       }
    .cce_ucode_bin : ALIGN(8)      { KEEP(*(.cce_ucode_bin)) }
}
