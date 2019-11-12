global main

section .text
  main:
    mov rax, [fs:0x30]    ; Get PEB
    mov rax, [rax + 0x14] ; ->PPEB_LDR_DATA
    mov rax, [rax + 0x20] ; ->LIST_ENTRY argv[0].exe
    mov rax, [rax]        ; LIST_ENTRY ntdll.dll
    mov rax, [rax]        ; LIST_ENTRY kernel32.dll
    mov rax, [rax + 0x30] ; kernel32.dll base address
    jmp $
