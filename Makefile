
RISCV_GCC ?= $(CROSS_COMPILE)gcc
RISCV_OBJCOPY ?= $(CROSS_COMPILE)objcopy

.PHONY: clean

RISCV_CFLAGS ?= -march=rv64im -mabi=lp64 -mcmodel=medany -static -nostdlib -nostartfiles
bootrom.riscv: cce_ucode.o
	$(RISCV_GCC) $(RISCV_CFLAGS) bootrom.S $^ -I$(@D) -o $@ -Tlink.ld -static -Wl,--no-gc-sections

.PRECIOUS: cce_ucode.o

# Currently only one bootrom is generated at a time
COH_PROTO ?= mesi
cce_ucode.o:
	$(RISCV_OBJCOPY) -I binary -O elf64-littleriscv -B riscv $(BP_SDK_UCODE_DIR)/$(COH_PROTO).bin $@ --strip-all --rename-section .data=.cce_ucode_bin --add-symbol cce_ucode_bin=.cce_ucode_bin:0

clean:
	@rm -f bootrom.riscv
	@rm -f cce_ucode.o

