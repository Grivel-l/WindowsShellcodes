global main

section .text
  main:
    mov rcx, k32Name
    call getLDTE          ; rax = Kernel32 Image directory
    mov rcx, rax
    mov rdx, functionName
    mov r8, functionNameLen
    call getFunction
    int3
  getFunction:
    push rbp
    push rbx
    push rdi
    push rsi
    push r12
    mov r10, [rax + 0x30] ; dll base address
    mov r9, r10
    add r9, 0x3c          ; r9 = RVA of PE signature
    mov r11, r10
    add r11d, [r9d]       ; IMAGE_NT_HEADERS
    add r11, 0x88         ; IMAGE_DATA_DIRECTORY - First one is export table
    mov r9, r10
    add r9d, [r11d]       ; r9 = IMAGE_EXPORT_DIRECTORY
    mov r12, r10
    add r12d, [r11d]       ; r12 = IMAGE_EXPORT_DIRECTORY
    mov r11, r10
    add r11d, [r9d + 0x20]  ; Array of RVA containing functions' name
    mov rbx, 0
    loop2:
      mov r9, r10
      add r9d, [r11d + ebx * 0x4]
      mov rsi, r9
      mov rdi, rdx
      mov rbp, r8
      strcmp:
        cmpsb
        jne next2
        dec rbp
        ; TODO Maybe bug here, should I check EOF ?
        cmp rbp, 0
        je retAddr
        jmp strcmp
      next2:
        inc rbx
        jmp loop2
    retAddr:
      mov r9, r10
      add r9d, [r12d + 0x24]
      mov rax, r10
      add r10d, [r9d]
      add rbx, rbx
      add r10, rbx
      add r10, rbx
      add r10, rbx
      add r10, rbx
      mov r9, r10
      add r9d, [r12d + 0x1c]
      add eax, [r9d]
    pop r12
    pop rsi
    pop rdi
    pop rbx
    pop rbp
    ret
  getLDTE:
    push rdi
    push rsi
    mov rax, [gs:0x60]    ; PEB
    mov rax, [rax + 0x18] ; PPEB_LDR_DATA
    mov rax, [rax + 0x10] ; LIST_ENTRY/LDR_DATA_TABLE_ENTRY argv[0]
    mov rax, [rax]
    loop1:
      mov esi, [rax + 0x60] ; BaseDLLName->Buffer
      mov edi, ecx
      mov rdx, k32Len
      strcmpW:
        cmpsw
        jne next
        dec rdx
        ; TODO Maybe bug here, should I check EOF ?
        cmp rdx, 0
        je done
        jmp strcmpW
        next:
          mov rax, [rax]
          jmp loop1
    done:
      pop rsi
      pop rdi
      ret

section .data
  k32Name db "K", 0, "E", 0, "R", 0, "N", 0, "E", 0, "L", 0, "3", 0, "2", 0, ".", 0, "d", 0, "l", 0, "l", 0
  k32Len equ ($ - k32Name) / 2
  functionName db "LoadLibraryA", 0
  functionNameLen equ $ - functionName
