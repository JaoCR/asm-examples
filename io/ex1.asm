;; Simple Keyboard Reading in x86_64 assembly, using Linux syscalls
;;
;;        nasm -felf64 -o readKey64.o readKey64.asm
;;        ld readKey64.o -o readKey64
;;        ./readKey64
;;
;; Adaptation of original code from:
;;   https://stackoverflow.com/questions/32193374/wait-for-keypress-assembly-nasm-linux
;--------------------------------------------------------------------------


global _start

section .data
  orig: times 10000 db 0         ; reserve way more space than we need for TCGETS
  new:  times 10000 db 0
  char: db 0,0,0,0,0

 msg1: db "Reading Keyboard... push ENTER to finish",0ah,0
 msglen     equ $ - msg1
 msg2: db 0ah,"END.",0ah,0
 msg2len: equ $ - msg2

section .text

_start:
    mov rsi,msg1
    mov rax,1
    mov rdi,1
    mov rdx,msglen
    syscall

    ; fetch the current terminal settings
    mov rax, 16    ; __NR_ioctl
    mov rdi, 0     ; fd: stdin
    mov rsi, 21505 ; cmd: TCGETS
    mov rdx, orig  ; arg: the buffer, orig
    syscall

    ; again, but this time for the 'new' buffer
    mov rax, 16
    mov rdi, 0
    mov rsi, 21505
    mov rdx, new
    syscall

    ; change settings
    and dword [new+0], -1516    ; ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON)
    and dword [new+4], -2       ; ~OPOST
    and dword [new+12], -32844  ; ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN)
    and dword [new+8], -305     ; ~(CSIZE | PARENB)
    or  dword [new+8], 48        ; CS8

    ; set settings (with ioctl again)
    mov rax, 16    ; __NR_ioctl
    mov rdi, 0     ; fd: stdin
    mov rsi, 21506 ; cmd: TCSETS
    mov rdx, new   ; arg: the buffer, new
    syscall
.readchar:
    ; read a character
    mov rax, 0     ; __NR_read
    mov rdi, 0     ; fd: stdin
    mov rsi, char  ; buf: the temporary buffer, char
    mov rdx, 1     ; count: the length of the buffer, 1
    syscall
    mov rax,1      ; __NR_write
    mov rdi,1
    mov rdx,1
    syscall        ; sys_write(1, char, 1)   // RSI is still set to buf

    cmp byte[char],13
    jz .end
    jmp .readchar
.end:

    ; reset settings (with ioctl again)
    mov rax, 16    ; __NR_ioctl
    mov rdi, 0     ; fd: stdin
    mov rsi, 21506 ; cmd: TCSETS
    mov rdx, orig  ; arg: the buffer, orig
    syscall

    mov rsi,msg2
    mov rax,1
    mov rdi,1
    mov rdx,msg2len
    syscall            ; sys_write(1, msg2, msg2len)

    mov rax,60
    mov rdi,0
    syscall            ; sys_exit(0)
