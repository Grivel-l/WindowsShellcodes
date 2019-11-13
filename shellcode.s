global main

section .text
  main:
    mov rax, [gs:0x60]    ; PEB
    mov rax, [rax + 0x18] ; PPEB_LDR_DATA
    mov rax, [rax + 0x10] ; LIST_ENTRY argv[0].exe
    mov rax, [rax]        ; LIST_ENTRY ntdll.dll
    mov rax, [rax]        ; LIST_ENTRY kernel32.dll
    mov rbx, [rax + 0x60]
    mov rax, [rax + 0x30] ; kernel32.dll base address
    mov rbx, rax
    add rbx, 0x3c
    mov rcx, rax
    add ecx, [ebx]        ; IMAGE_NT_HEADERS
    mov rbx, rcx
    add rbx, 0x88         ; IMAGE_DATA_DIRECTORY - First one is export table
    mov rdx, rax
    add edx, [ebx]        ; IMAGE_EXPORT_DIRECTORY
    mov edx, [edx + 0x20]
    mov rcx, rax
    add ecx, edx          ; Array of RVA containing functions names
    mov rdx, rax
    add edx, [ecx]        ; Array of DLL functions names
    int3
