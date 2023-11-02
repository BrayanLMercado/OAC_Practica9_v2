nasm -f elf p9.asm
ld -m elf_i386 -s -o p9 p9.o libpc_io.a
./p9
