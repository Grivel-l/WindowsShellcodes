global main

section .text
  main:
    ; rax = IMAGE_DATA_DIRECTORY
    ; rbx = k32 base adress
    ; rcx = k32 header
    mov rcx, k32Name
    call getLDTE
    int3
    mov rax, [rax]        ; LIST_ENTRY/LDR_DATA_TABLE_ENTRY ntdll.dll
    mov rax, [rax]        ; LIST_ENTRY/LDR_DATA_TABLE_ENTRY kernel32.dll
    mov rbx, [rax + 0x30] ; kernel32.dll base address
    mov rcx, rbx
    add rcx, 0x3c         ; rcx = lstnew
    mov rax, rbx          ; rax = k32 base address
    add eax, [ecx]        ; IMAGE_NT_HEADERS
    add rax, 0x88         ; IMAGE_DATA_DIRECTORY - First one is export table
    mov rsi, rbx
    add esi, [eax]        ; rsi = IMAGE_EXPORT_DIRECTORY
    mov esi, [esi + 0x20] ; rsi = Addres of RVA to RVA containing functions names
    mov rdi, rbx
    add edi, esi          ; RVA of array containing functions names
    int3
  getLDTE:
    mov rax, [gs:0x60]    ; PEB
    mov rax, [rax + 0x18] ; PPEB_LDR_DATA
    mov rax, [rax + 0x10] ; LIST_ENTRY/LDR_DATA_TABLE_ENTRY argv[0]
    mov rax, [rax]
    loop:
      mov esi, [rax + 0x60] ; BaseDLLName->Buffer
      mov edi, ecx
      mov rdx, k32Len
      strcmpW:
        cmpsw
        jne next
        dec rdx
        cmp rdx, 0
        je done
        jmp strcmpW
        next:
          mov rax, [rax]
          jmp loop
    done:
      ret

section .data
  k32Name db "K", 0, "E", 0, "R", 0, "N", 0, "E", 0, "L", 0, "3", 0, "2", 0, ".", 0, "d", 0, "l", 0, "l", 0
  k32Len equ ($ - k32Name) / 2
