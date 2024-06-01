boot:
	nasm -f bin boot.asm -o boot.bin
	truncate boot.bin --size 512
