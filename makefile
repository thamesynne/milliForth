run:
	yasm -f bin -o sector.bin sector.asm -l sector.lst
	qemu-system-i386 -fda sector.bin

bochs:
	yasm -f bin -o sector.dsk -DFLOPPY -l sector.lst
	bochs -f sector.bx -q

emulate:
	qemu-system-i386 -fda sector.bin

with:
	yasm -f bin -o sector.bin sector.asm $(options)
	qemu-system-i386 -fda sector.bin

prep:
	yasm --preproc-only sector.S

sizecheck:
	yasm -f bin -o sector.bin sector.asm -D CHECKSIZE
	ls -la | grep sector.bin | awk '{print $$9":",$$5,"bytes"}'
	@yasm -f bin -o sector.bin sector.asm # rewrite with working .bin
