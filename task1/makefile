NASM := nasm
GCC := gcc
LD := ld

NASM_FLAGS := -f elf32
GCC_FLAGS := -m32 -Wall -ansi -fno-stack-protector
LD_FLAGS := -m elf_i386

all: encoder

encoder: encoder.o util.o
	$(GCC) $(GCC_FLAGS) encoder.o util.o -o encoder

encoder.o: encoder.s
	$(NASM) $(NASM_FLAGS) encoder.s -o encoder.o

util.o: util.c util.h
	$(GCC) $(GCC_FLAGS) -c util.c -o util.o

clean:
	rm -f util.o encoder.o encoder
