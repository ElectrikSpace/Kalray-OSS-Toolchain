# Kalray OSS Toolchain

Clone the required upstream repositories:
`./clone_repos.sh`

Build everything and run the hello-world test:
`./build_all.sh`
Or run these build scripts separately, in order: `./build_binutils.sh`, `./build_gcc.sh`, `./build_newlib.sh`, `./build_qemu.sh`.

The hello-world test is in `tests/`; run it with `make -C tests run`.
