;     _   ___ _____ 
;    (_) /   |  _  |
;     _ / /| | |/' |
;    | / /_| |  /| |
;    | \___  \ |_/ /
;    | |   |_/\___/ 
;   _/ |            
;  |__/             
;
;  j40     : 11399628#USP
;  made_in : Sao_Carlos, SP, BR, 2020_12
;
;  --- x86_64 nasm assembly: Hello World! ---

; >> This program writes "Hello, World!" to
; stdout.


global _start


section .text

_start:

    ; write message to stdout 
    mov rax, SYS_WRITE
    mov rdi, FD_STDOUT 
    mov rsi, str_msg 
    mov rdx, len_msg
    syscall

    ; exit program
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall


section .data

    ;syscalls
    SYS_WRITE:  equ 1
    SYS_EXIT:   equ 60

    ;file descriptor
    FD_STDOUT:  equ 1

    ; the message
    str_msg:    db "Hello, World!", 10
    len_msg:    equ $ - str_msg 
