NAME    P6
ORG     0100h

; —————— Datos ————————————————
BUFFER      DB  60 DUP(0)
NUMSTACK    DW  32 DUP(0)
OPSTACK     DB  32 DUP(0)
NUMPTR      DB  0
OPPTR       DB  0

msg_title   DB 'Nombre del alumno: Juan Perez',0Dh,0Ah,0
msg_instr   DB 'Ingrese ecuacion (max 60 chars, un digito, +-*/):',0Dh,0Ah,0
msg_err_inv DB 'Error: caracter invalido',0Dh,0Ah,0
msg_err_div DB 'Error: division por cero',0Dh,0Ah,0
msg_res     DB 'El resultado es: ',0

; —————— Código ————————————————
start:
    cli
    mov ax,cs
    mov ss,ax
    mov sp,0FFF8h
    sti

    mov si,OFFSET msg_title
    call print_str
    mov si,OFFSET msg_instr
    call print_str

    lea di,BUFFER
    mov cx,60
read_char:
    mov ah,0
    int 16h
    cmp al,0Dh
    je  read_done
    dec cx
    jz  overflow
    mov [di],al
    inc di
    mov ah,0Eh
    int 10h
    jmp read_char

overflow:
    mov si,OFFSET msg_err_inv
    call print_str
    jmp exit

read_done:
    mov byte ptr [di],0

    mov byte ptr NUMPTR,0
    mov byte ptr OPPTR,0

    lea si,BUFFER
parse_loop:
    mov al,[si]
    cmp al,0
    je  parse_done
    cmp al,'0'
    jb  check_op
    cmp al,'9'
    ja  check_op
    sub al,'0'
    call push_num
    inc si
    jmp parse_loop

check_op:
    cmp al,'+'
    je  is_op
    cmp al,'-'
    je  is_op
    cmp al,'*'
    je  is_op
    cmp al,'/'
    je  is_op
    mov si,OFFSET msg_err_inv
    call print_str
    jmp exit

is_op:
    call push_op
    inc si
    jmp parse_loop

parse_done:
end_loop:
    mov al,OPPTR
    cmp al,0
    je  show_result
    call apply_op
    jmp end_loop

show_result:
    call newline
    mov si,OFFSET msg_res
    call print_str
    mov bx,0
    mov ax,[NUMSTACK + bx*2]
    call write_signed
    jmp exit

; —————— Subrutinas ——————————

print_str:
    push ax
    push bx
.next_char:
    lodsb
    or al,al
    ; Si AL es 0, se termina
    cmp al,0
    jne .next_char  ; Mientras no sea 0, sigue imprimiendo
    pop bx
    pop ax
    ret

newline:
    mov al,0Dh
    mov ah,0Eh
    int 10h
    mov al,0Ah
    int 10h
    ret
; push_num: AL=[0–9], apila en NUMSTACK
push_num:
    push ax              ; Guardamos el valor de ax
    push cx              ; Guardamos el valor de cx
    
    mov ah,0
    mov bl,NUMPTR       ; Número de la pila
    mov cl,bl           ; Copiamos NUMPTR a cl
    mov ch,0            ; Limpiamos el byte alto
    mov bx,cx
    shl bx,1            ; bx = desplazamiento en bytes (multiplicamos por 2)

    lea si, NUMSTACK    ; Usamos si para obtener la dirección base de NUMSTACK
    add si, bx          ; Sumamos el desplazamiento de bx a si
    
    mov [si], ax        ; Guardamos el valor de ax en NUMSTACK[si]
    inc byte ptr NUMPTR ; Incrementamos el puntero de la pila
    
    pop cx               ; Recuperamos el valor de cx
    pop ax               ; Recuperamos el valor de ax
    ret

; apply_op: desapila un operador y dos números, calcula y apila el resultado
apply_op:
    push ax bx cx dx si di    ; Guardamos los registros que usaremos

    ; Desapilar operador
    mov cl, OPPTR            ; Cargamos el puntero de la pila de operadores
    dec cl                    ; Decrementamos para obtener el operador actual
    mov al, [OPSTACK + cl]    ; Accedemos al operador usando cl como índice
    mov byte ptr OPPTR, cl    ; Actualizamos el puntero de la pila de operadores

    ; Desapilar el segundo número (num2)
    mov cl, NUMPTR            ; Cargamos el puntero de la pila de números
    dec cl
    mov bx, cl
    shl bx, 1                 ; Calculamos el desplazamiento para acceder a NUMSTACK
    lea si, NUMSTACK          ; Cargamos la dirección base de NUMSTACK
    add si, bx                ; Sumamos el desplazamiento de NUMSTACK + bx
    mov ax, [si]              ; Cargamos el valor de NUMSTACK en ax (num2)

    ; Actualizamos el puntero de la pila de números
    mov byte ptr NUMPTR, cl

    ; Desapilar el primer número (num1)
    mov cl, NUMPTR
    dec cl
    mov bx, cl
    shl bx, 1                 ; Calculamos el desplazamiento para acceder a NUMSTACK
    lea si, NUMSTACK          ; Cargamos la dirección base de NUMSTACK
    add si, bx                ; Sumamos el desplazamiento de NUMSTACK + bx
    mov dx, [si]              ; Cargamos el valor de NUMSTACK en dx (num1)

    ; Actualizamos el puntero de la pila de números
    mov byte ptr NUMPTR, cl

    ; Realizamos la operación según el operador (al está cargado con el operador)
    cmp al, '+'               ; Verificamos si es una suma
    je  do_add
    cmp al, '-'               ; Verificamos si es una resta
    je  do_sub
    cmp al, '*'               ; Verificamos si es una multiplicación
    je  do_mul
    cmp al, '/'               ; Verificamos si es una división
    je  do_div
    jmp .push_result           ; Si no es ninguno de los anteriores, saltamos al final

do_add:
    add dx, ax                ; Realizamos la suma (dx = num1 + num2)
    jmp .push_result

do_sub:
    sub dx, ax                ; Realizamos la resta (dx = num1 - num2)
    jmp .push_result

do_mul:
    imul dx, ax               ; Realizamos la multiplicación (dx = num1 * num2)
    jmp .push_result

do_div:
    cmp ax, 0                 ; Verificamos si el divisor es cero
    je  .div_zero
    cwd                       ; Sign-extend ax to dx:ax (para división con signo)
    idiv ax                   ; Dividimos dx:ax entre ax (resultado en ax, residuo en dx)
    jmp .push_result

.div_zero:
    mov si, OFFSET msg_err_div
    call print_str
    jmp exit

.push_result:
    ; Apilamos el resultado en NUMSTACK
    mov cl, NUMPTR            ; Cargamos el puntero de la pila de números
    mov bl, cl
    shl bl, 1                 ; Calculamos el desplazamiento para acceder a NUMSTACK
    lea si, NUMSTACK          ; Cargamos la dirección base de NUMSTACK
    add si, bl                ; Sumamos el desplazamiento de NUMSTACK + bx
    mov [si], dx              ; Guardamos el resultado en NUMSTACK

    inc byte ptr NUMPTR       ; Incrementamos el puntero de la pila de números

    pop di si dx cx bx ax      ; Restauramos los registros y regresamos
    ret


write_signed:
    push ax
    push bx
    push cx
    push dx
    cmp ax,0
    jge .positive
    neg ax
    mov al,'-'
    mov ah,0Eh
    int 10h
.positive:
    xor cx,cx
.loop1:
    xor dx,dx
    mov bx,10
    div bx
    push dx
    inc cx
    or ax,ax
    jnz .loop1
.loop2:
    pop dx
    add dl,'0'
    mov ah,0Eh
    mov al,dl
    int 10h
    dec cx
    jnz .loop2

    pop dx
    pop cx
    pop bx
    pop ax
    ret

exit:
    mov ah,0
    int 20h
