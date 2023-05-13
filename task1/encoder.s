section .data
    argc: dd 0
    argv: dd 0
    argvLength: dd 0
    inFile: dd 0
    outFile: dd 1
    counter: dd 0
    myChar: db 0
    newline: db 0xA
    errorMessage: db "Unable to open file!", 0xA

section .text
global main
extern strlen
main:
setArgumentsVariables:
    mov eax, dword[esp + 8]       ;[esp + 8] contains argv
    mov dword[argv], eax        ;set global variable to equal argv
    mov eax, dword[esp + 4]       ;[esp + 4] contains argc
    mov dword[argc], eax        ;set global variable to equal argc

printArguments:
    startLoop:
        mov ecx, dword[argv]            ;ecx = char** argv
        mov edi, dword[counter]         ;edi = current index
        mov ecx, dword[ecx + edi * 4]   ;ecx = argv[i]
    getArgvLength:
        push ecx                        ;pushing strlen argument
        call strlen                     ;strlen(argv[i])
        pop ecx                         ;retrieve argv[i]
        mov dword[argvLength], eax        ;set global variable to be the return value from strlen
    printArgv:
        mov eax, 0x4                    ;preparing system call: sys_write
        mov ebx, 1                      ;stdout
        mov edx, dword[argvLength]        ;edx = strlen(argv[i])
        int 0x80                        ;call system call
    printNewLine:
        mov eax, 0x4                    ;preparing system call: sys_write
        mov ebx, 1                      ;stdout
        mov ecx, newline                ;printing buffer
        mov edx, 1                      ;new line is just 1 byte
        int 0x80                        ;call system call
    checkArgv:
        mov ecx, dword[argv]            ;ecx = char**  argv
        mov ecx, dword[ecx + edi * 4]   ;ecx = argv[i]
        cmp word[ecx], "-i"             ;comparing the first 2 bytes with -i (compare argv[i])
        je openInput                   ;if equal, open input file
        cmp word[ecx], "-o"             ;comparing the first 2 bytes with -o (compare argv[i])
        je openOutput                  ;if equal, open output file
    continuedLoop:
        add dword[counter], 1           ;increment the counter
        mov edi, dword[counter]         ;edi = index counter
        cmp edi, dword[argc]            ;comparing index counter with argc
        jne startLoop                  ;if not equal, continue the loop
    jmp encoder                         ; go to encoder
openInput:
    mov eax, 0x5                    ;preparing system call: sys_open
    mov ebx, ecx                    ;in check_argc, ecx had the argument, now ebx has it
    add ebx, 2                      ;ebx = argv[i] + 2 (ignore the -i)
    mov ecx, 0                      ;open for writing
    int 0x80                        ;call system_call
    cmp eax, -1                     ;check for error
    jle error                        ;jump if equal to -1 (open failed)
    mov dword[inFile], eax          ;save opened file in global variable
    jmp continuedLoop              ;continue the loop
openOutput:
    mov eax, 0x5                    ;preparing system call: sys_open
    mov ebx, ecx                    ;in check_argc, ecx had the argument, now ebx has it
    add ebx, 2                      ;ebx = argv[i] + 2 (ignore the -i)
    mov ecx, 1101o                   ;open for writing, create new file if it doesn't exist & delete content from the file if it exists
    mov edx, 777o                   ;Create new file for read/write/execute
    int 0x80                        ;call system call
    cmp eax, -1                     ;check for error              
    jle error
    mov dword[outFile], eax         ;save opened file in global variable
    jmp continuedLoop              ;continue the loop
encoder:
    getChar:
        mov eax, 0x3                ;prepare system call: sys_write
        mov ebx, dword[inFile]      ;read from inFile, default is stdin unless we have -i
        mov ecx, myChar             ;save the char into the global variable
        mov edx, 1                  ;only read one byte
        int 0x80                    ;call system call
    checkRead:
        cmp eax, 0                  ;check if sys_read returned 0 for EOF or -1 for error
        jle exit                    ;finish the program
    compareChar:
        cmp byte[myChar], 'A'       ;Compare the char we read with 'A'
        jl printChar               ;jump if less than 'A'  like modulo
        cmp byte[myChar], 'z'       ;Compare the char we read with 'z'
        jg printChar               ;jump if greater than 'z'
    encodeChar:
        add byte[myChar], 1         ;encoder the char
    printChar:
        mov eax, 0x4                ;prepare system call: sys_write
        mov ebx, dword[outFile]     ;print to outFile, default is stdout unless we have -o
        mov ecx, myChar             ;print char
        mov edx, 1                  ;It's one char, so size is 1
        int 0x80                    ;call system call
        jmp encoder                 ;continue loop

error:
    popad
    mov eax, 0x4                    ;prepare system call: sys_write
    mov ebx, 2                      ;stderr
    mov ecx, errorMessage              ;buffer to print
    mov edx, 17                     ;buffer length
    int 0x80                        ;call system call
    jmp exitFail                   ;exit because of error

exit:
    mov eax, 0x1                    ;sys_exit
    mov ebx, 0                      ;exit code for success
    int 0x80

exitFail:
    mov eax, 0x1                    ;sys_exit
    mov ebx, 01                      ;exit code for failure
    int 0x80
