section .rodata
    newline db 10  ; the char for /n
section .data
    Infile  dd 0    ; File  for stdin
    Outfile dd 1    ; File  for stdout

section .bss
    char_buf resb 1   ; a reserve for the char well read

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
    call encode        ; activate the encoder!
    mov eax, 1         ; sys_exit: eax = 1 
    mov ebx, 0         ; ebx = 0: good run
    int 0x80           
    
encode:
    push ebp                ; save before stats
    mov ebp, esp            ; save pointer to the stack

encode_loop:
    ; sys_read
    mov eax, 3              ; sys_read: eax=3
    mov ebx, [Infile]       ; where to read: ebx
    mov ecx, char_buf       ; read to buffer and then to the wanted saved space
    mov edx, 1              ; length
    int 0x80                ; activate

    ; if(length=0)
    cmp eax, 0              ; how many we read
    jz end_encode           ; if 0 we jump to end

    ; sys_write
    mov eax, 4              ; sys_write: eax=4
    mov ebx, [Outfile]      ; target: ebx
    mov ecx, char_buf       ; pointer to buffer
    mov edx, 1              ; length
    int 0x80                ; activate

    jmp encode_loop         ; next round in loop

end_encode:
    mov esp, ebp            ; restore stack pointer
    pop ebp                 ; restore ebp
    ret                     ; return to main