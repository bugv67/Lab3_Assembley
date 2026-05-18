# All targets to build when running just 'make'
all: task1a

# ==================== TASK 1a+b (Assembly Encoder) ====================
task1a: start.o task1a.o util.o
	ld -m elf_i386 start.o task1a.o util.o -o task1a

task1a.o: task1a.s
	nasm -f elf32 task1a.s -o task1a.o


# ==================== TASK 0 (C Arguments Printer) ====================

task0: start.o main.o util.o
	ld -m elf_i386 start.o main.o util.o -o task0

main.o: main.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector main.c -o main.o

start.o: start.s
	nasm -f elf32 start.s -o start.o


util.o: util.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o

clean:
	rm -f *.o task0 task1a