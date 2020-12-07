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
;  --- x86_64 nasm assembly: file management example ---

; >> This program creates a file and
; writes a line of text to it using
; the OPEN syscall.

;  MOUNTING AND LINKING {{{
;   
;  $ yasm -g dwarf2 -felf64 file.asm -o temp.o 
;  $ ld temp.o -o file 
;  $ rm temp.o
;  
;  (the "-g dwarf2" can be changed to just "-g" on nasm,
;  or removed if debugging is not needed)
;
; }}}

global _start

section .text

_start: nop

        ; prompt user for file name
        mov rax, SYS_WRITE
        mov rdi, FD_STDOUT
        mov rsi, str_pname
        mov rdx, len_pname
        syscall

        ; read file name
        mov rax, SYS_READ
        mov rdi, FD_STDIN
        mov rsi, str_name
        mov rdx, len_name
        syscall
        
        ; locate line feed 
cname:  xor rax, rax
        mov bl, 10
.loop:  mov cl, byte[rax + str_name]
        cmp bl, cl
        je  dellf
        inc rax
        jmp .loop

        ; remove line feed
dellf:  mov byte[rax + str_name], byte 0

        ; create file 
        mov rax, SYS_OPEN
        mov rdi, str_name
        mov rsi, O_FLAGS
        mov rdx, S_MODE 
        syscall
        mov [fd_new], rax

        ; prompt user for text to write
        mov rax, SYS_WRITE
        mov rdi, FD_STDOUT
        mov rsi, str_pline
        mov rdx, len_pline
        syscall

        ; read text
        mov rax, SYS_READ
        mov rdi, FD_STDIN
        mov rsi, str_line
        mov rdx, len_line
        syscall

        ; locate line feed 
cline:  xor rdx, rdx
        mov bl, 10
.loop:  mov cl, byte[rdx + str_line]
        cmp bl, cl
        je write
        inc rdx
        jmp .loop

        ; write to file
write:  mov rax, SYS_WRITE
        mov rdi, [fd_new]
        mov rsi, str_line
        syscall

        ; exit program
        mov rax, SYS_EXIT
        xor rdi, rdi
        syscall


section .data
    
    ; syscalls
    SYS_READ:   equ 0
    SYS_WRITE:  equ 1
    SYS_OPEN:   equ 2
    SYS_EXIT:   equ 60

    ; stdio file descriptors
    FD_STDIN:   equ 0
    FD_STDOUT:  equ 1

    ; flags for OPEN
    O_FLAGS:    equ 00010101
    ;;;;;;;;
    ; made by or'ing the flags:
    ; O_WRONLY | O_CREAT  | O_TRUNC
    ; 00000001 | 00000100 | 00010000

    ; mode for OPEN (linux default)
    S_MODE:     equ 644o
    ;;;;;;;
    ; made by or'ing the flags:
    ; S_IROTH  | S_IRGRP  | S_IRUSR  | S_IWUSR
    ;   004o   |   040o   |   200o   |   400o
    
    ; presets for input max length
    len_name:   equ 255
    len_line:   equ 255


    ; prompts for file:
    
    ; >> name
    str_pname:  db " enter file name (max 255 characters)"
                db 10, " >> "
    len_pname:  equ $ - str_pname
    
    ; >> content
    str_pline:  db " enter line of text to write (max 255 characters)"
                db 10, " >> "
    len_pline:  equ $ - str_pline


section .bss

    str_name:   resb len_name
    str_line:   resb len_line
    fd_new:     resq 1

; USING OPEN AS CREAT {{{
;
; >> Some places in c documantation
; indicate that the CREAT syscall
; should not be used and is only kept
; for compatibility with older 
; code. Trying to replicate it's 
; behavior with the more generalized
; OPEN syscall might be challenging
; as documentation is unclear in some 
; aspects. 
;
; >> There are 2 things to keep
; in mind: the flags, and the mode.
; The *flags* dictate the behavior of
; the syscall itself and are passed
; through rsi. The *mode* is used
; when the O_CREAT flag is set,
; dictates information about the file
; to be created, such as permissions.
; Mode shoud be placed in rdx.
;
; >> To find the numeric values of the
; flags, you may try to print them
; with a c program or hunt them in the 
; system files. In my system, they
; are 10101, in decimal base, to match
; CREAT. More about that on the data
; section comments.
;
; >> The mode can be found in the
; docs, but it might not be clear that
; those are octal numbers. To get
; the same behavior as the touch
; command in linux, 644o should work.
;
; }}}
