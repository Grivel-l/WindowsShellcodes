global main

section .text
  main:
    mov rax, [gs:0x60]    ; Get PEB
    mov rax, [rax + 0x18] ; ->PPEB_LDR_DATA
    mov rax, [rax + 0x10] ; ->LIST_ENTRY argv[0].exe
    mov rax, [rax]        ; LIST_ENTRY ntdll.dll
    mov rax, [rax]        ; LIST_ENTRY kernel32.dll
    mov rax, [rax + 0x30] ; kernel32.dll base address
    mov rbx, rax
    add rbx, 0x3c
    mov rcx, rax
    add ecx, [ebx]        ; Signature here
    int3
