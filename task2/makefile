# הגדרות קומפילציה ל-32 ביט ללא ספריות סטנדרטיות
CC = gcc
CFLAGS = -m32 -fno-pie -Wall -nostdlib -fno-stack-protector
ASM = nasm
ASMFLAGS = -f elf32


all: task2

task2: main.o start.o util.o
	$(CC) $(CFLAGS) -o task2 main.o start.o util.o

main.o: main.c
	$(CC) $(CFLAGS) -c -o main.o main.c

util.o: util.c
	$(CC) $(CFLAGS) -c -o util.o util.c

start.o: start.s
	$(ASM) $(ASMFLAGS) -o start.o start.s

clean:
	rm -f *.o task2