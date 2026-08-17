org 0x7c00
bits 16

load_kernel:
 cli
 xor ax, ax
 mov ds, ax
 mov ax, 0x0050
 mov es, ax
 xor bx, bx
 mov [boot_drive], dl
 sti
 mov si, loadmsg
 call print
 
 mov ah, 2
 mov al, 2
 mov ch, 0
 mov cl, 2
 mov dh, 0
 mov dl, [boot_drive]
 int 0x13
 jc disk_error
 jmp 0x0050:0x0000

disk_error:
 mov si, errormsg
 call print
.halt:
 cli
 hlt
 jmp .halt

print:
 mov ah, 0x0e
 mov al, [si]
 cmp al, 0
 je .done
 inc si
 int 0x10
 jmp print
.done:
 ret

errormsg db "Uh oh no", 13, 10, 0
loadmsg db "Loading kernel", 13, 10, 0
boot_drive db 0
times 510-($-$$) db 0
dw 0xAA55 