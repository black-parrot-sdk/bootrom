SECTIONS
{
    . = 0x0000;
    .text.start    : ALIGN(8) { *(.text.start)    }
    .data          : ALIGN(8) { *(.data)          }
}
