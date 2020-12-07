global _start

section .text

_start: nop

        mov rax, SYS_EXECVE
        mov rdi, sh
        mov rsi, argv
        mov rdx, 0 
        syscall

section .data

SYS_EXECVE:     equ 59
SYS_WRITE:      equ 1
SYS_EXIT:       equ 60

FD_STDOUT:      equ 1

sh:             db "/bin/sh", 0
arg0:           db "sh", 0
arg1:           db "-c", 0
arg2:           db "echo hello there; ./test", 0
argv:           dq arg0, arg1, arg2, 0

