; to compile: nasm -f elf32 task0b.s -o task0b.o
;             ld -m elf_i386 task0b.o -o task0b
;             ./task0b  


section .data     
    msg db 'hello world', 10   ; one byte
    len equ $ - msg


section .text
    global _start  ; starting point

_start:
    mov eax, 4                      ; definig sys write
    mov ebx, 1                      ; destination
    mov ecx, msg                    ; adress of the info
    mov edx, len                    ; how much to print

    int 0x80       ; excute! need to defin how to exit

    mov eax, 1
    mov ebx, 0
    int 0x80        ; ecutting exit!