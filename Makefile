
RISCV_GCC ?= $(CROSS_COMPILE)gcc
RISCV_OBJCOPY ?= $(CROSS_COMPILE)objcopy

.PHONY: clean

RISCV_CFLAGS ?= -march=rv64gc -mabi=lp64d -mcmodel=medany -static -nostdlib -nostartfiles
bootrom.riscv: bootrom.S cce_ucode.bin
	$(RISCV_GCC) -o $@ $(RISCV_CFLAGS) $< -I$(@D) -Tlink.ld -static -Wl,--no-gc-sections

# Currently only one bootrom is generated at a time
COH_PROTO ?= mesi

cce_ucode.bin: $(BP_SDK_UCODE_DIR)/$(COH_PROTO).bin
	$(RISCV_OBJCOPY) -I binary -O binary --reverse-bytes=8 $< $@

clean:
	@rm -f bootrom.riscv
	@rm -f cce_ucode.bin
	@rm -f cce_ucode.mem

