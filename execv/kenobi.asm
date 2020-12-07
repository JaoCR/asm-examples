; vim:fileencoding=utf-8:ft=nasm:foldmethod=marker
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
;  --- x86_64 nasm assembly: execve example ---

; >> This program executes a shell command
; that echoes a message and reexecutes the
; program. Infinitely loops untill <C-c>.
; Will not work as intended if called from 
; outside the program's directory.
; This strategy might be used to mask shell
; scripts as binaries.

;  MOUNTING AND LINKING {{{
;   
;  $ yasm -g dwarf2 -felf64 kenobi.asm -o temp.o 
;  $ ld temp.o -o kenobi 
;  $ rm temp.o
;  
;  (the "-g dwarf2" can be changed to just "-g" on nasm,
;  or removed if debugging is not needed)
;
; }}} 

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
arg2:           db "echo hello there; ./kenobi", 0
argv:           dq arg0, arg1, arg2, 0

