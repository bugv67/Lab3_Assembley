section .rodata
    newline db 10  ; the char for /n
section .data
    Infile  dd 0    ; File  for stdin (default)
    Outfile dd 1    ; File  for stdout (default)
    KeyPointer  dd 0    ; encoder key: +V
    CurrKeyPtr  dd 0    ; current position in the key

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

    ; check if +V aka the encode key
    mov edx, [edi]          ; current argv
    cmp byte [edx], '+'     ; if(argv[0][0]==+)
    jne check_minus
    cmp byte [edx+1], 'V'   ; if(argv[0][1]==V)
    jne check_minus
    
    ; is key!!
    add edx, 2              ;  skip the +v
    mov [KeyPointer], edx   ; save
    mov [CurrKeyPtr], edx   
    jmp finished_arg_check

check_minus:
    ; sys open: eax=5, ebx=filename, ecx=flags, edx=mode
    cmp byte [edx], '-'
    jne finished_arg_check
    cmp byte [edx+1], 'i'   ; check for -i{fileName}
    je handle_infile
    cmp byte [edx+1], 'o'   ; check for -o{fileName}
    je handle_outfile
    jmp finished_arg_check

handle_infile:
    add edx, 2              ; skip "-i" to get the filename pointer
    mov eax, 5              ; sys_open
    mov ebx, edx            ; ebx = filename string
    mov ecx, 0              ; ecx = O_RDONLY
    mov edx, 0              ; edx = mode (not needed for reading)
    int 0x80                ; activate sys_open
    mov [Infile], eax       ; save the returned file descriptor to Infile
    jmp finished_arg_check

handle_outfile:
    add edx, 2              ; skip "-o" to get the filename pointer
    mov eax, 5              ; sys_open
    mov ebx, edx            ; ebx = filename string
    mov ecx, 0x241          ; ecx = O_WRONLY | O_CREAT | O_TRUNC
    mov edx, 420            ; edx = permissions (0644 in octal)
    int 0x80                ; activate sys_open
    mov [Outfile], eax      ; save the returned file descriptor to Outfile

finished_arg_check:
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
   jle end_encode           ; if 0 or negative, we are done (end of file or error)

    ; ----  encryption logic ----
    mov edx, [KeyPointer]
    cmp edx, 0              ; check if key=!null
    jz skip_encryption      ; if no key, just print as is

    mov ebx, [CurrKeyPtr]   ; get current running key pointer
    mov cl, [ebx]           ; read the current key byte
    
    cmp cl, 0               ; check if we reached end of key string (\0)
    jnz shift
    
    ; wrap around to the beginning of the key
    mov ebx, [KeyPointer]
    mov cl, [ebx]
    mov [CurrKeyPtr], ebx

shift:
    sub cl, '0'             ; convert key char to numerical shift value
    mov al, [char_buf]      ; get the char we read from stdin
    
    ; check if it's a lowercase letter!!!
    cmp al, 'a'             ; smaller then 'a'
    jl skip_encryption      ; if so, it's not a lowercase letter - skip encryption and print as is
    cmp al, 'z'             
    jg skip_encryption      

    add al, cl              ; apply encryption shift
    mov [char_buf], al      ; save encrypted char back to buffer
    inc dword [CurrKeyPtr]  ; advance key pointer for next char

skip_encryption:
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