section .text

global _start
_start:
        jmp    usage
    starting:
        pop     rcx
        call    openFile
        xor     r12, r12    ; counter
        mov     rbx, 1 ; last char
    nextBuffer:
        call    readBuffer
        mov     r13, rax
        test    r13, r13 ; length
        jle     outputResult
        xor     rdi, rdi ; i
    .buffer_loop:
        cmp     rdi, r13
        je      nextBuffer
        mov     al, [buffer + rdi] ; new char
        movzx   rcx, al
        call    isSpace     ; if (changed && wasSpace)
        cmp     rax, rbx
        je      .continue
        test    rbx, rbx
        jz      .continue
        inc     r12
    .continue:
        inc     rdi
        mov     rbx, rax
        jmp     .buffer_loop

    outputResult:
        mov     rcx, r12
        call    printUint64
    end:
        call    closeFile

        mov     rax, 60
        xor     rdi, rdi
        syscall

usage:
        pop     rax
        cmp     rax, 2
        jne     error_wrongUsage
        pop     rax
        jmp     starting

; rcx   filename
openFile:
        mov     rax, 2
        mov     rdi, rcx
        xor     rsi, rsi
        xor     rdx, rdx
        syscall
        cmp     rax, 0
        jl      error_CantOpenFile
        mov     [fileHandle], rax
        ret

closeFile:
        mov     rax, [fileHandle]
        cmp     rax, 0
        jl      .return
        mov     rax, 3
        mov     rdi, [fileHandle]
        syscall
    .return:
        ret

; rdi   name
readBuffer:
        mov     rax, 0
        mov     rdi, [fileHandle]
        mov     rsi, buffer
        mov     rdx, [bufferLength]
        syscall
        ret

; ecx char
isSpace:
        xor     rax, rax
        cmp     ecx, 9
        jl      .return
        cmp     ecx, 13
        jle     .true
        cmp     ecx, 32
        je      .true
        jmp     .return
    .true:
        mov     eax, 1
        jmp     .return
    .return:
        ret


; rcx = number
; write number to stdout
printUint64:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10

    mov rax, rcx
    mov r12, -0x1
    mov r13, 0x0a
    .loop:
        xor rdx, rdx
        div r13
        add rdx, '0'
        mov [rbp + r12], dl
        dec r12
        cmp rax, 0
        jne .loop

    inc r12
    lea rcx, [rbp + r12]
    neg r12
    mov rdx, r12
    call printBuffer

    mov rsp, rbp
    pop rbp
    ret


; rcx = text
; rdx = length
printBuffer:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, rcx
    syscall
    cmp     rax, rdx
    jne     write_fail

    push    byte 0x0a
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, rsp
    mov     rdx, 1
    syscall
    add     rsp, 8
    ret


write_fail:
read_fail:
    mov rcx, error_IO
    mov rdx, [error_IO_len]
    jmp error

error_CantOpenFile:
    mov rcx, message_CantOpenFile
    mov rdx, [message_CantOpenFile_len]
    jmp error

error_wrongUsage:
    mov rcx, message_wrongUsage
    mov rdx, [message_wrongUsage_len]
    jmp error


; rcx = message
; rdx = length
error:
    mov rax, 1
    mov rdi, 2
    mov rsi, rcx
    syscall
    jmp end

section .rodata
error_NotNumber:                db "It's not a number",0x0a
error_NotNUmber_len:            dq $ - error_NotNumber
error_IO:                       db "An IO error occured",0x0a
error_IO_len:                   dq $ - error_IO
message_CantOpenFile:           db "Can't open file",0x0a
message_CantOpenFile_len:       dq $ - message_CantOpenFile
message_wrongUsage:             db "Usage: wordstat <input file>",0x0a
message_wrongUsage_len:         dq $ - message_wrongUsage
bufferLength                    dq 1024

section .data
fileHandle                      dq -1

section .bss
buffer                  resb 1024