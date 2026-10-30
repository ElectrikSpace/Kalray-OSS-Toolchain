# Hello world test

Minimal `printf` program built with the open source kvx toolchain and run on
`qemu-system-kvx`.

- `hello.c`: prints `Hello, kvx!`.
- `dtb_space.c`: reserves a `.dtb` section; QEMU patches its device tree
  there and refuses to boot ELFs without enough room.

## Usage

```sh
make        # build hello.elf
make run    # run it on qemu (expects "Hello, kvx!")
make clean
```

Variables (defaults in parentheses):

- `ARCH` (`kv3-1`): core architecture (`kv3-1` or `kv3-2`). The kvx QEMU only
  emulates kv3-1, so `make run` only works with `ARCH=kv3-1`.
- `TARGET` (`kvx-elf`): toolchain triplet.
- `TOOLCHAIN` (`../install-$(ARCH)`): prefix holding the toolchain and QEMU,
  as produced by `../build_all.sh`.

QEMU is run with `-semihosting`, needed for `printf` output.
