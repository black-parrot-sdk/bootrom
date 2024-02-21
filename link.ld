
SECTIONS
{
    . = 0x110000;
    .bootrom.text : {
        *(.bootrom.text);
        . = 0x400;
    } = 0xff

    .bootrom.data : {
        *(.bootrom.data);
        . = 0x800;
    } = 0xff
}
