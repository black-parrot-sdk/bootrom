# TODO: remove
#BP_SDK_DIR = ..
#BP_RTL_DIR = ../../black-parrot
#BP_TOOLS_DIR = ../../black-parrot-tools
#include ../Makefile.common
# end remove

WITH_MARCH ?= rv64gc
WITH_MABI ?= lp64d

RISCV_GCC ?= $(CROSS_COMPILE)gcc
RISCV_OBJCOPY ?= $(CROSS_COMPILE)objcopy

.PHONY: clean

RISCV_CFLAGS ?= -march=$(WITH_MARCH) -mabi=$(WITH_MABI) -mcmodel=medany -static -nostdlib -nostartfiles
bootrom.%.riscv: bootrom.S cce_ucode.%.bin
	@echo $*
	$(RISCV_GCC) -o $@ $(RISCV_CFLAGS) -DCOH_PROTO=COH_PROTO_$* $< -I$(@D) -Tlink.ld -static -Wl,--no-gc-sections

# can override COH_PROTO to generate for a single protocol
COH_PROTO ?= ei msi mesi moesif hybrid
ALL_CCE_UCODE_BIN = $(addprefix cce_ucode., $(addsuffix .bin, $(COH_PROTO)))
ALL_BOOTROM_RISCV = $(addprefix bootrom., $(addsuffix .riscv, $(COH_PROTO)))

cce_ucode.%.bin: $(BP_SDK_UCODE_DIR)/%.bin
	$(RISCV_OBJCOPY) -I binary -O binary --reverse-bytes=8 $< $@

all: $(ALL_BOOTROM_RISCV)

clean:
	@rm -f bootrom.*.riscv
	@rm -f cce_ucode.*.bin

