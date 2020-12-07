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
;  --- x86_64 nasm assembly: stdio example ---

; >> This program captures a keypress and
; writes text to stdout depending on it.

;  MOUNTING AND LINKING {{{
;   
;  $ yasm -g dwarf2 -felf64 io.asm -o temp
;  $ ld temp -o io
;  $ rm temp
;  
;  (the "-g dwarf2" can be changed to just "-g" on nasm,
;  or removed if debugging is not needed)
;
; }}}

; WHERE I LEARNED {{{ 
;
; <https://stackoverflow.com/questions/32193374/wait-for-keypress-assembly-nasm-linux>
; <https://stackoverflow.com/questions/27365528/how-do-i-wait-for-a-keystroke-interrupt-with-a-syscall-on-linux>
;
; }}}

global _start

section .text

_start: nop

        ; read stdin termios
        mov rax, SYS_IOCTL
        mov rdi, FD_STDIN
        mov rsi, TCGETS
        mov rdx, termios
        syscall

        ; modify termios
        ; > allow read every byte input 
        or dword [termios+12], ~ICANON
        ; > disable echo input
        or dword [termios+12], ~ECHO

        ; submit new termios
        mov rax, SYS_IOCTL
        mov rdi, FD_STDIN
        mov rsi, TCSETS
        lea rdx, [rel termios]
        syscall

        ; read a character
        mov rax, SYS_READ
        mov rdi, FD_STDIN
        mov rsi, option
        mov rdx, 1
        syscall

        ; reset termios 
        or dword [termios+12], ICANON
        or dword [termios+12], ECHO
        mov rax, SYS_IOCTL
        mov rdi, FD_STDIN
        mov rsi, TCSETS
        mov rdx, termios
        syscall

        ; check option `
        xor rax, rax
        xor rbx, rbx
        mov al, byte[option]
        mov bl, "s"
        cmp al, bl 
        je _sim
        mov bl, "S"
        cmp al, bl 
        je _sim
        jmp _nao

        ; if s or S, write Sim
_sim:   mov rax, SYS_WRITE
        mov rdi, FD_STDOUT
        mov rsi, str_sim
        mov rdx, len_sim
        syscall
        jmp _exit

        ; else, write Nao
_nao:   mov rax, SYS_WRITE
        mov rdi, FD_STDOUT
        mov rsi, str_nao
        mov rdx, len_nao
        syscall

        ; exit program
_exit:  mov rax, SYS_EXIT
        xor rdi, rdi    
        syscall


section .data

    ; syscalls
    SYS_IOCTL:  equ 16
    SYS_READ:   equ 0
    SYS_WRITE:  equ 1
    SYS_EXIT:   equ 60

    ; file descriptors
    FD_STDIN:   equ 0
    FD_STDOUT:  equ 1

    ; ioctl commands
    TCGETS:     equ 21505
    TCSETS:     equ 21506

    ; termios canonical bit 
    ; (controls how we are allowed to read stdin)
    ICANON:     equ 1<<1
    
    ; termios echo bit
    ECHO:       equ 1<<3
   
    ; string variants to output
    str_sim:    db "Sim", 10, 0
    len_sim:    equ $ - str_sim

    str_nao:    db "Nao", 10, 0
    len_nao:    equ $ - str_nao

segment .bss

    ; the typed char is stored here
    option:     resb 1

    ; stdin configuration data 
    termios:    resb 36

;  HOW TO CAPTURE A KEYPRESS {{{
;
;  >> IOCTL is a syscall that we can use to
;  control the IO on our linux terminal. In
;  this case we get a data structure called 
;  termios, that holds some settings of the
;  io. Then, we modify 2 places in it, telling
;  it to allow us to read the stdin byte per
;  byte, and not to echo the pressed keys,
;  so that only our output is printed. Then
;  without needing to wait for a return press,
;  we capture the first key typed, and print
;  conditional output based on it.
;
;  }}}
