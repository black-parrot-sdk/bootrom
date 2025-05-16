
WITH_MARCH ?= rv64gc
WITH_MABI ?= lp64d

RISCV_GCC ?= $(CROSS_COMPILE)gcc
RISCV_OBJCOPY ?= $(CROSS_COMPILE)objcopy
RISCV_OBJDUMP ?= $(CROSS_COMPILE)objdump

.PHONY: clean

RISCV_CFLAGS ?= -march=$(WITH_MARCH) -mabi=$(WITH_MABI) -mcmodel=medany -static -nostdlib -nostartfiles
bootrom.%.riscv: bootrom.S cce_ucode.%.bin
	$(RISCV_GCC) -o $@ $(RISCV_CFLAGS) -DCOH_PROTO_$* $< -I$(@D) -Tlink.ld -static -Wl,--no-gc-sections

bootrom.none.riscv: bootrom.S
	$(RISCV_GCC) -o $@ $(RISCV_CFLAGS) -DCOH_PROTO_none $< -I$(@D) -Tlink.ld -static -Wl,--no-gc-sections

# can override COH_PROTO to generate for a single protocol
COH_PROTO ?= ei msi mesi moesif hybrid none
ALL_CCE_UCODE_BIN = $(addprefix cce_ucode., $(addsuffix .bin, $(COH_PROTO)))
ALL_BOOTROM_RISCV = $(addprefix bootrom., $(addsuffix .riscv, $(COH_PROTO)))
ALL_BOOTROM_DUMP = $(addprefix bootrom., $(addsuffix .dump, $(COH_PROTO)))

cce_ucode.%.bin: $(BP_SDK_UCODE_DIR)/%.bin
	$(RISCV_OBJCOPY) -I binary -O binary --reverse-bytes=8 $< $@

cce_ucode.none.bin:
	touch $@

bootrom.%.dump: bootrom.%.riscv
	$(RISCV_OBJDUMP) -D -t $< > $@

all: $(ALL_CCE_UCODE_BIN) $(ALL_BOOTROM_RISCV) $(ALL_BOOTROM_DUMP)

clean:
	@rm -f bootrom.*.riscv
	@rm -f bootrom.*.dump
	@rm -f cce_ucode.*.bin

