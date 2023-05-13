NASM := nasm
GCC := gcc
LD := ld

NASM_FLAGS := -f elf32
GCC_FLAGS := -m32 -Wall -ansi -c -nostdlib -fno-stack-protector
LD_FLAGS := -m elf_i386

all: task2

task2: start.o main.o util.o
	$(LD) $(LD_FLAGS) start.o main.o util.o -o task2

start.o: start.s
	$(NASM) $(NASM_FLAGS) start.s -o start.o

main.o: main.c util.h
	$(GCC) $(GCC_FLAGS) main.c -o main.o

util.o: util.c util.h
	$(GCC) $(GCC_FLAGS) util.c -o util.o

clean:
	rm -f start.o main.o util.o task2
