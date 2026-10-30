ROOT      := $(abspath ..)
ARCH      ?= kv3-1
TARGET    ?= kvx-elf
TOOLCHAIN ?= $(ROOT)/install-$(ARCH)

CC   := $(TOOLCHAIN)/bin/$(TARGET)-gcc
QEMU := $(TOOLCHAIN)/bin/qemu-system-kvx

CFLAGS  ?= -O2
LDFLAGS += -Wl,--no-warn-rwx-segments

.PHONY: all run clean

all: hello.elf

hello.elf: hello.c dtb_space.c
	$(CC) -march=$(ARCH) $(CFLAGS) $^ -o $@ $(LDFLAGS)

run: hello.elf
	@test "$(ARCH)" = kv3-1 || { echo 'qemu only supports kv3-1'; exit 1; }
	$(QEMU) -nographic -semihosting -kernel $<

clean:
	rm -f hello.elf
