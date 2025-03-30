include 'emu8086.inc'

org 0100h
jmp inicio

nombre  db  "Nombre: Carlos Alberto Mariscal Romo", 0Dh, 0Ah, "$"
mensaje db  "Ingrese un numero hexadecimal de 4 digitos: $"
resultado db "Resultado en BCD: $"
cadnum  db  5 dup(?)
n32     db  4 dup(?)
b       db  ?
bcd     db  8 dup('$')
DEFINE_GET_STRING
DEFINE_PRINT_STRING

numbyte:
        call asc2num
        mov  bl, 16
        mul  bl
        mov  [b], al
        inc  di
        mov  al, [di]
        call asc2num
        add  al, [b]
        mov  [b], al
        ret

asc2num:
        sub  al, 48
        cmp  al, 9
        jle  f_asc
        sub  al, 7
        cmp  al, 15
        jle  f_asc
        sub  al, 32
f_asc:  ret

hex_to_bcd:
        mov ax, 0
        mov cx, 4
        lea si, n32
        mov di, 6
        mov bx, 10
        lea bp, bcd
    convert_loop:
        mov dx, 0
        mov al, [si]
        div bx
        add ah, 30h
        mov [bp + di], ah
        dec di
        mov al, dl
        div bx
        add ah, 30h
        mov [bp + di], ah
        dec di
        mov al, dl
        add al, 30h
        mov [bp + di], al
        dec di
        inc si
        loop convert_loop
        mov byte ptr [bp + 7], '$'  ; Terminador de cadena
        ret

inicio:
        mov sp, 0FFF8h   ; Ajustar el SP según el requisito
        
        lea dx, nombre
        call print_string
        mov ah, 02h
        mov dl, 0Dh
        int 21h
        mov dl, 0Ah
        int 21h

        lea dx, mensaje
        call print_string

        lea di, cadnum
        mov dx, 5
        call get_string

        lea di, cadnum
        lea si, n32
        mov cx, 4
    conv_loop:
        mov  al, [di]
        call numbyte
        mov  al, [b]
        mov  [si], al
        inc  si
        inc  di
        loop conv_loop
        
        call hex_to_bcd

        mov ah, 02h
        mov dl, 0Dh
        int 21h
        mov dl, 0Ah
        int 21h

        lea dx, resultado
        call print_string
        lea dx, bcd
        call print_string
        
        mov ah, 02h
        mov dl, 0Dh
        int 21h
        mov dl, 0Ah
        int 21h

        int  20h   ; Finaliza el programa

END
