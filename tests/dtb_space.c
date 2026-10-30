/* Reserve room in .dtb: qemu-system-kvx patches its device tree in here. */
__attribute__((section(".dtb"), aligned(0x100), used))
static char dtb_space[0x10000];
