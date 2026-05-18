section .rodata
    newline db 10  ; the char for /n

section .text
    global main
    extern strlen  ; helper

main:  ; prints all args to strout
    push ebp                ; save before stats
    mov ebp ,esp            ; save pointer to the stack

    mov esi , [ ebp+8 ]     ; argc\length = [ ebp+8 ]
    mov edi ,[ ebp+12 ]     ; argv

    print_loop:
    cmp esi, 0              ; check if esi is 0
    jz end_loop             ; if 0 we jump to end

    ;else contine             
    push dword [edi]        ; save currnt pinter to the stack
    call strlen             ; call helper returning length
    add esp, 4              ; 
    mov edx ,eax           ;sys_write - edx (length), ecx (pointer), ebx(target-1), eax (what to do- write)
    mov ecx ,[edi]
    mov ebx ,1
    mov eax ,4
    int 0x80                ; activate

; printing now /n
    mov edx, 1         
    mov ecx, newline   
    mov ebx, 1        
    mov eax, 4       
    int 0x80          

    ; next round in loop
    add edi, 4         ; move pointer to the next argv
    dec esi            ; esi--
    jmp print_loop     ; jump to the start

end_loop:
    mov eax, 1         ; sys_exit: eax = 1 
    mov ebx, 0         ; ebx = 0: good run
    int 0x80           




