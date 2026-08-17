org 0x0900

mov si, message
call print
jmp $

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

message db "Program 1!!!", 13, 10, 0
times 1024-($-$$) db 0 ; pad to 1kb, because our kernel loads 2 sectors = 1024 bytes.


