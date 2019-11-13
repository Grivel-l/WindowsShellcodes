global main

section .text
  main:
    ; rax = IMAGE_DATA_DIRECTORY
    ; rbx = k32 base adress
    ; rcx = k32 header
    mov rax, [gs:0x60]    ; PEB
    mov rax, [rax + 0x18] ; PPEB_LDR_DATA
    mov rax, [rax + 0x10] ; LIST_ENTRY/LDR_DATA_TABLE_ENTRY argv[0]
    mov rax, [rax]        ; LIST_ENTRY/LDR_DATA_TABLE_ENTRY ntdll.dll
    mov rax, [rax]        ; LIST_ENTRY/LDR_DATA_TABLE_ENTRY kernel32.dll
    mov rbx, [rax + 0x30] ; kernel32.dll base address
    mov rcx, rbx
    add rcx, 0x3c         ; rcx = lstnew
    mov rax, rbx          ; rax = k32 base address
    add eax, [ecx]        ; IMAGE_NT_HEADERS
    add rax, 0x88         ; IMAGE_DATA_DIRECTORY - First one is export table
    mov rdx, rbx
    add edx, [eax]        ; IMAGE_EXPORT_DIRECTORY
    mov edx, [edx + 0x20] ; Addres of names
    mov rsi, rbx
    add esi, edx          ; RVA of array containing functions names
    int3
