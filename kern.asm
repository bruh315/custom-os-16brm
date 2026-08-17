org 0x500

PROGRAM_SECOND equ 6
PROGRAM_FIRST equ 4
PROGRAM_SIZE equ 2
PROGRAM_LOADADDR equ 0x0900

start:
 mov [boot_drive], dl
 call .clearcmd
 mov si, welcome
 call print

.repl:
 mov si, prompt
 call print
 
 mov si, input_buffer
 mov cx, 16
 call read_input
 
 mov si, input_buffer
 mov di, clearcmd
 call strcmp
 cmp al, 1
 je .clearcmd
 
 mov si, input_buffer
 mov di, infocmd
 call strcmp
 cmp al, 1
 je .infocmd

 mov si, input_buffer
 mov di, rebootcmd
 call strcmp
 cmp al, 1
 je .rebootcmd

 mov si, input_buffer
 mov di, loadfirstcmd
 call strcmp
 cmp al, 1
 je .loadfirstcmd

 mov si, input_buffer
 mov di, loadsecondcmd
 call strcmp
 cmp al, 1
 je .loadsecondcmd

 mov si, input_buffer
 call print
 jmp .repl

.loadfirstcmd:
 xor ax, ax
 mov es, ax
 mov ds, ax

 mov ah, 2
 mov al, PROGRAM_SIZE
 mov ch, 0
 mov cl, PROGRAM_FIRST ; since its our first progrma
 mov dh, 0
 mov dl, [boot_drive]
 mov bx, PROGRAM_LOADADDR
 
 int 0x13 ; call disk reader
 jc .progerror 
 
 jmp 0x0000:PROGRAM_LOADADDR

.loadsecondcmd:
 ; setup segment regs
 xor ax, ax
 mov es, ax
 mov ds, ax

 ; setup 0x13
 mov ah, 2
 mov al, PROGRAM_SIZE
 mov ch, 0
 mov cl, PROGRAM_SECOND
 mov dh, 0
 mov dl, [boot_drive]
 mov bx, PROGRAM_LOADADDR
 
 int 0x13
 jc .progerror
 
 jmp 0x0000:PROGRAM_LOADADDR

.progerror:
 mov si, progerrormsg
 call print
 jmp .repl

.clearcmd:
 mov ah, 0
 mov al, 3
 int 0x10
 jmp .repl

.infocmd:
 mov si, info
 call print
 jmp .repl

.rebootcmd:
 jmp 0x07C0:0000

strcmp:
 mov ah, [di]
 mov al, [si]

 cmp ah, 0
 je .end

 cmp al, 0
 je .neq

 cmp ah, al
 jne .neq

 inc di
 inc si

 jmp strcmp

.end:
 cmp al, 0
 je .equ
 jne .neq

.neq:
 mov al, 0
 ret

.equ:
 mov al, 1
 ret

read_input:
 sub cx, 1
 xor bx, bx

.read_loop:
 cmp cx, bx
 je .done

 mov ah, 0
 int 0x16

 cmp al, 13
 je .done

 cmp al, 8
 je .backspace

 mov [si], al
 mov ah, 0x0e
 int 0x10

 inc bx
 inc si
 jmp .read_loop

.done:
 mov [si], 0
 mov ah, 0x0e
 mov al, 13
 int 0x10
 mov al, 10
 int 0x10
 ret

.backspace:
 cmp bx, 0
 je .read_loop
 dec bx
 dec si
 mov ah, 0x0e
 mov al, 8
 int 0x10
 mov al, ' '
 int 0x10
 mov al, 8
 int 0x10
 jmp .read_loop

print:
 mov ah, 0x0e
 mov al, [si]
 cmp al, 0
 je .done
 int 0x10
 inc si
 jmp print

.done:
 ret

progerrormsg db "Error loading program, please try again!", 13, 10, 0
boot_drive db 0
loadfirstcmd db "load1", 0
loadsecondcmd db "load2", 0
clearcmd db "cls", 0
infocmd db "sysinfo", 0
rebootcmd db "reboot", 0
input_buffer times 16 db 0
info db "Kernel written in pure assembly, x86_16.", 13, 10, 0
welcome db "Welcome into assembly!", 13, 10, 0
prompt db "assembly > ", 0

times 1024-($-$$) db 0