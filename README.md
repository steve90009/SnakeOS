# SnakeOS
This is a simple bootloader that plays the game Snake.
To build the program on Linux, run ```make``` or run the command
```
nasm -f bin boot.asm -o boot.bin
```
When building without ```make```, you should also run the command
```
truncate --size 512 boot.bin
```
to truncate the file to 512 bytes, as the BIOS only loads these.
To run the bootloader you can use qemu.
```
qemu-system-x86_64 -drive file=boot.bin,format=raw,index=0,media=disk
```
You should also be able to use any other VM but I only tested using qemu.
It should also be possible to actually boot from this program but this is also untested.
