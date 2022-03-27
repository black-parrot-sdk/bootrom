SECTIONS
{
    . = 0x00000;
    .text.start    : ALIGN(8) { *(.text.start)    }
}
