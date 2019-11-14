global main

section .text
  main:
    mov rcx, k32Name
    call getLDTE          ; rax = Kernel32 Image directory
    mov rcx, rax
    mov rdx, functionName
    mov r8, functionNameLen
    call getFunction
  getFunction:
    mov r10, [rax + 0x30] ; dll base address
    mov r9, r10
    add r9, 0x3c          ; r9 = RVA of PE signature
    mov r11, r10
    add r11d, [r9d]       ; IMAGE_NT_HEADERS
    add r11, 0x88         ; IMAGE_DATA_DIRECTORY - First one is export table
    mov r9, r10
    add r9d, [r11d]
    mov r9d, [r9d + 0x20] ; r9 = Addres of RVA to RVA containing functions names
    mov r11, r10
    add r11d, r9d         ; RVA of array containing functions names
    int3
  getLDTE:
    push rdi
    push rsi
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
      pop rsi
      pop rdi
      ret

section .data
  k32Name db "K", 0, "E", 0, "R", 0, "N", 0, "E", 0, "L", 0, "3", 0, "2", 0, ".", 0, "d", 0, "l", 0, "l", 0
  k32Len equ ($ - k32Name) / 2
  functionName db "AddAtomA", 0
  functionNameLen equ $ - functionName
