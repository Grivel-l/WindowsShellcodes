global main

section .text
  main:
    mov rax, [fs:0x30]    ; Get PEB
    mov rax, [rax + 0x0c] ; PEB->PEB_DATA
    mov rax, [rax + 0x14] ; ->InMemoryOrderModuleList
    mov rax, [rax]        ; ntdll.dll
    mov rax, [rax]        ; kernel32.dll
    mov rax, [rax + 0x10] ; kernel32.dll base address
    jmp $
