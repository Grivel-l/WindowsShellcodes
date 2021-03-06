[bits 64]

section .text
  main:
    sub rsp, 0x28
    call init
    sub rax, $
    mov r15, rax            ; $rip
    mov rcx, r15
    add rcx, k32Name
    mov rdx, 11
    call getLDTE
    mov r12, rax          ; r12 = Kernel32 Image directory
    mov rcx, rax
    mov rdx, r15
    add rdx, functionName
    mov r8, 15
    call getFunction
    mov r13, rax          ; r13 = GetProcAddress
    mov rcx, [r12d + 0x30]
    mov rdx, r15
    add rdx, loadLibrary
    call rax              ; Get LoadLibraryA
    mov r14, rax          ; r14 = LoadLibraryA
    mov rcx, r15
    add rcx, user
    call rax              ; Load user32.dll
    mov rcx, rax
    mov rdx, r15
    add rdx, msgBox
    mov rax, r13
    call rax              ; Get MessageBoxA
    xor rcx, rcx
    mov rdx, r15
    add rdx, msg
    xor r8, r8
    xor r9, r9            ; MB_OK
    call rax              ; Call MessageBoxA
    add rsp, 0x28
    jmp end               ; Jmp where additionnal code is added during compilation
  getFunction:
    push rbp
    push rbx
    push rdi
    push rsi
    push r12
    push r13
    mov r10, [rcx + 0x30] ; dll base address
    mov r9, r10
    add r9, 0x3c          ; r9 = RVA of PE signature
    mov r9d, [r9]
    mov r11, r10
    add r11, r9       ; IMAGE_NT_HEADERS
    add r11, 0x88         ; IMAGE_DATA_DIRECTORY - First one is export table
    mov r11d, [r11]
    mov r9, r10
    add r9, r11      ; r9 = IMAGE_EXPORT_DIRECTORY
    mov r12, r9           ; r12 = IMAGE_EXPORT_DIRECTORY
    mov r11, r10
    mov r9d, [r9 + 0x20]
    add r11, r9  ; Array of RVA containing functions' name
    mov rbx, 0
    loop2:
      mov r9, r10
      mov esi, [r11 + rbx * 0x4]
      add r9, rsi
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
      mov r13d, [r12 + 0x24]
      add r9, r13
      mov bx, [r9 + rbx * 2]
      mov r9, r10
      mov r13d, [r12 + 0x1c]
      add r9, r13   ; Array of RVAs
      mov r13, r10
      mov r9d, [r9 + rbx * 4]
      add r13, r9
      mov rax, r13
    pop r13
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
    mov rax, [rax + 0x20] ; LIST_ENTRY/LDR_DATA_TABLE_ENTRY argv[0]
    mov rax, [rax]
    mov rax, [rax]
    sub rax, 0x10
    pop rdi
    pop rsi
    ret
    ; TODO Why segfault on NTDLL.dll
    loop1:
      mov esi, [rax + 0x60] ; BaseDLLName->Buffer
      mov edi, ecx
      mov r8, rdx
      strcmpW:
        cmpsw
        jne next
        dec r8
        ; TODO Maybe bug here, should I check EOF ?
        cmp r8, 0
        je done
        jmp strcmpW
        next:
          mov rax, [rax]
          jmp loop1
    done:
      pop rsi
      pop rdi
      ret
    init:
      mov rax, [rsp]
      ret

section .data
  k32Name db "K", 0, "E", 0, "R", 0, "N", 0, "E", 0, "L", 0, "3", 0, "2", 0, ".", 0, "d", 0, "l", 0, "l", 0
  functionName db "GetProcAddress", 0
  user db "user32.dll", 0
  loadLibrary db "LoadLibraryA", 0
  msg db "HelloWorld", 0
  msgBox db "MessageBoxA", 0
  end
