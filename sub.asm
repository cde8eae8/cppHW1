; ; read numebr1
; ;   read chars
; ;   chars -> number
; ; read number2
; ; sub

section .text

global _start
_start:
        mov     rcx, 128
        lea     rdx, [rcx*8]
        neg     rdx
        lea     rsp, [rsp + rdx]        ; 128 long long per number
        mov     rdi, rsp
        lea     rsp, [rsp + rdx]        ; 128 long long per number
        call    read_number
        ; call    write_long
        mov     r13, rdi
        mov     rcx, 128
        mov     rdi, rsp
        mov     rcx, 128
        call    read_number
        mov     rsi, r13
        mov     rcx, 128
        ; xchg    rsi, rdi
        call    less
        test    rax, rax
        jz      .subtract
        call    print_minus
        xchg    rsi, rdi
        ; call    set_zero
        ; mov     [rdi], rax
    .subtract:
        xchg    rsi, rdi
        call    sub_long_long
        call    write_long
        lea     rsp, [rsp + rcx * 8]
        lea     rsp, [rsp + rcx * 8]

    exit:
        mov     rax, 60
        xor     rdi, rdi
        syscall

print_minus:
        push    rdi
        push    rsi
        push    rcx
        dec     rsp
        mov     byte [rsp], '-'
        mov     rsi, rsp
        mov     rax, 1
        mov     rdi, 1
        mov     rdx, 1
        syscall
        inc     rsp
        pop     rcx
        pop     rsi
        pop     rdi

; rdi   number1
; rsi   number2
; rcx   length
; number1 < number2
less:
        push    rdi
        push    rsi
        push    rcx
        xor     rbp, rbp
        sub     rcx, 8
    .loop:
        mov     rax, [rdi + rcx]
        mov     rbx, [rsi + rcx]
        cmp     rax, rbx
        ja      .true
        jb      .return
        cmp     rcx, 0
        je      .return
        sub     rcx, 8
        jmp     .loop

    .true:
        mov     rbp, 1
    .return:
        mov     rax, rbp
        pop     rcx
        pop     rsi
        pop     rdi
    ret

; rdi buffer
; rcx length
; changed nothing
set_zero:
        push    rdi
        push    rcx
    .loop:
        test    rcx, rcx
        je     .end
        mov     QWORD [rdi], 0
        add     rdi, 8
        dec     rcx
        jmp     .loop
    .end:
        pop     rcx
        pop     rdi
        ret

; rdi buffer
; rcx length
read_number:
        call    set_zero
        mov     rbx, rdi
        mov     r10,  rcx
    .loop:
        call    read_char
        cmp     rax, 0x0a
        je      .end
        sub     rax, '0'
        cmp     rax, 0
        jl      InputError_wrongDigit
        cmp     rax, 9
        jg      InputError_wrongDigit

        mov     rdi, rbx    ; rdi = buffer
        mov     rcx, r10    ; rcx = len
        mov     rsi, 10
        mov     r9, rdi     ; r9 = buffer
        call    mul_short
        mov     rsi, rax
        call    add_short
        jmp .loop
        mov     rcx, r10
    .end:
        ret

; rdi long number
; rcx length
; rsi short number
; r9  result buffer
; change rax, r8, rdx
mul_short:
        push    rcx
        push    rbx
        push    rdi
        push    rax
        push    r9

        xor     r8, r8
    .loop:
        test    rcx, rcx
        je     .end
        mov     rax, rsi
        mov     rbx, [rdi]
        mul     rbx     ; rdx:rax = rsi * [rdi]
        add     rax, r8
        adc     rdx, 0  ; with carry
        mov     r8, rdx ; save carry
        mov     [r9], rax

        add     rdi, 8
        add     r9, 8
        dec     rcx
        jmp     .loop
    .end:
        pop     r9
        pop     rax
        pop     rdi
        pop     rbx
        pop     rcx
        ret


; rdi long number
; rcx length
; rsi short number
; change rsi
add_short:
        push    rcx
        push    rbx
        push    rdi
        clc
        xor     rbx, rbx
    .loop:
        test    rcx, rcx
        je     .end
        add     [rdi], rsi
        adc     rbx, 0
        mov     rsi, rbx
        xor     rbx, rbx
        add     rdi, 8
        dec     rcx
        jmp     .loop
    .end:
        pop     rdi
        pop     rbx
        pop     rcx
        ret

; rdi first number
; rsi second number
; rdi > rsi
; rcx length
; result in rdi
sub_long_long:
    push    rcx
    push    rdi

    clc
    .loop:
    mov     rax, [rdi]
    mov     rbx, [rsi]
    sbb     [rdi], rbx

    lea     rdi, [rdi + 8]
    lea     rsi, [rsi + 8]
    dec     rcx
    jne     .loop

    pop     rdi
    pop     rcx
    ret

; rdi first number
; rsi second number
; rcx length
; result in rdi
add_long_long:
    push    rcx
    push    rdi
    push    rbx

    clc
    .loop:
    mov     rax, [rdi]
    mov     rbx, [rsi]
    adc     [rdi], rbx

    lea     rdi, [rdi + 8]
    lea     rsi, [rsi + 8]
    dec     rcx
    jne     .loop

    pop     rbx
    pop     rdi
    pop     rcx
    ret


; check errors and return next digit from stdin in rax
; change rax, rdi, rsi, rdx
read_char:
        push    rdi
        push    rcx
        sub     rsp, 1
        xor     rax, rax
        xor     rdi, rdi
        mov     rsi, rsp
        mov     rdx, 1
        syscall

        test    rax, rax
        ; jl      IOError_read
        jg      .continue
        mov     rax, 0x0a   ; return new line if eof reached
        jmp     .end

    .continue:
        xor     rax, rax
        mov     al, [rsp]
    .end:
        add     rsp, 1
        pop     rcx
        pop     rdi
        ret


; write long number to stdout
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
write_long:
                push            rax
                push            rcx
                ; ...
                push            rdi
                push            rsi
                push            rbx
                push            rdx
                push            r10
                push            r11
                push            r12
                push            r13
                push            rbp


                mov             rax, 20
                mul             rcx
                mov             rbp, rsp
                sub             rsp, rax

                mov             rsi, rbp

.loop:
                mov             rbx, 10
                call            div_long_short
                add             rdx, '0'
                dec             rsi
                mov             [rsi], dl
                call            is_zero
                jnz             .loop

                mov             rdx, rbp
                sub             rdx, rsi
                call            print_string


                mov             rsp, rbp

                pop             rbp
                pop             r13
                pop             r12
                pop             r11
                pop             r10
                pop             rdx
                pop             rdx
                pop             rsi
                ; ...
                pop             rdi
                pop             rcx
                pop             rax
                ret


; print string to stdout
;    rsi -- string
;    rdx -- size
print_string:
                push            rax

                mov             rax, 1
                mov             rdi, 1
                syscall

                dec             rsp
                mov             byte [rsp], 0x0a
                mov             rsi, rsp
                mov             rax, 1
                mov             rdi, 1
                mov             rdx, 1
                syscall
                inc             rsp

                pop             rax
                ret


; divides long number by a short
;    rdi -- address of dividend (long number)
;    rbx -- divisor (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    quotient is written to rdi
;    rdx -- remainder
div_long_short:
                push            rdi
                push            rax
                push            rcx

                lea             rdi, [rdi + 8 * rcx - 8]
                xor             rdx, rdx

.loop:
                mov             rax, [rdi]
                div             rbx
                mov             [rdi], rax
                sub             rdi, 8
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rax
                pop             rdi
                ret

InputError_wrongDigit:
    mov rax, 1
    mov rdi, 2
    mov rsi, error_invalidNumber
    mov rdx, error_invalidNumber_len
    syscall
    jmp exit



; checks if a long number is a zero
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
; result:
;    ZF=1 if zero
is_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep scasq

                pop             rcx
                pop             rdi
                pop             rax
                ret


section         .rodata
error_invalidNumber:
                db              "Invalid number",0x0a
error_invalidNumber_len: equ             $ - error_invalidNumber
