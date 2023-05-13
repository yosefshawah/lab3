section .data
    message db 'hello world', 0xA
section .text
    global _start
_start:
    mov     eax, 4          ; system call for "write"
    mov     ebx, 1          ; file descriptor for stdout
    mov     ecx, message    ; message to write
    mov     edx, 12         ; message length 12 inlcuding \n = 0xA.
    int     0x80            ; call kernel

    mov     eax, 1          ; system call for "exit"
    xor     ebx, ebx        ; return code 0
    int     0x80            ; call kernel
