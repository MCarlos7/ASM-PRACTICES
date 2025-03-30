name "P4"                        
org 100h   

;--------------------------------------------------
; Modo de video y colores
  
    mov al, 1                ; Modo video
    mov bh, 0                
    mov bl, 0000_1001b       ; Color
              
;--------------------------------------------------
; PRINT

; nombre
    mov bp, offset nombre
    mov cx, nombre_T
    mov dl, 10       ; Columna
    mov dh, 2        ; Fila
    mov ah, 13h
    int 10h

; entrada
    mov bp, offset entrada
    mov cx, entrada_T
    mov dl, 10
    mov dh, 4
    mov ah, 13h
    int 10h

; salida (resultado)
    mov bp, offset salida
    mov cx, salida_T
    mov dl, 10
    mov dh, 6
    mov ah, 13h
    int 10h                                         
;--------------------------------------------------
; Espera de tecla
    mov ah, 0
    int 16h          ; Espera de tecla
    
;--------------------------------------------------
; C�lculo de potencia (Base^Exponente)

    mov ax, [Base]    ; Cargar Base en AX
    xor dx, dx        ; Limpiar DX (Base es de 16 bits)
    mov cl, [Exp]     ; Cargar el exponente (8 bits) en CL
    mov ch, 0
    mov [Res], ax     ; Inicializar Res con Base
    mov [Res+2], dx

    dec cx          ; Se resta 1 (si exp=1, CX queda en 0 y se salta el bucle)
    cmp cx, 0
    je fin_calculo

loop_potencia:
    push cx              ; Guardar contador
    mov ax, [Res]        ; Obtener el resultado actual (16 bits)
    mov [D1], ax         ; Factor 1 = resultado actual
    mov ax, [Base]       ; Factor 2 = Base
    mov [D2], ax
    call mult            ; Multiplicar D1 * D2
    mov ax, [P0]         ; Actualizar resultado parcial
    mov dx, [P0+2]
    mov [Res], ax
    mov [Res+2], dx
    pop cx               ; Restaurar contador
    loop loop_potencia   ; Repetir CX veces

fin_calculo:
           
;--------------------------------------------------
;Subrutina de multiplicacion de 16x16 bits      

mult:   
    push ax        ; Guardar estado de AX
    push bx        ; Guardar estado de BX
    push cx        ; Guardar estado de CX
    push dx        ; Guardar estado de DX
    mov ax, [D1]   ; Cargar D1 en AX
    mov dx, [D2]   ; Cargar D2 en DX
    mul dx         ; Multiplicar AX * DX, resultado en DX:AX
    mov [P0], ax   ; Guardar parte baja en P0
    mov [P0+2], dx ; Guardar parte alta en P0+2
    pop dx         ; Restaurar DX
    pop cx         ; Restaurar CX
    pop bx         ; Restaurar BX
    pop ax         ; Restaurar AX
    ret            ; Retornar de la subrutina 
   
;--------------------------------------------------
; Ajuste final de la pila: SP debe ser FFF8h
    mov sp, 0FFF8h   
                                               
;--------------------------------------------------
; Espera de tecla y fin del programa
    mov ah, 0
    int 16h          ; Espera de tecla
    int 20h          ; Finaliza el programa
                           
;--------------------------------------------------
; DATOS

; Variables

Base    dw 0      ; Entrada de 16 bits
Exp     db 0      ; Entrada de 8 bits
Res     dd 0      ; Resultado de 32 bits en big-endian 

D1      dw 0      ; Variable temporal
D2      dw 0                                            

P0      dd 0      ; Variable para resultados parciales

; Texto
nombre    db "Alumno: Carlos Alberto  Sec: D06", 0 
entrada   db "Introduce Base (16 bits, Big-Endian) y Exponente (8 bits)", 0
salida    db "Resultado (32 bits, Big-Endian):", 0   
fin:

nombre_T  = entrada - nombre
entrada_T = salida - entrada 
salida_T  = fin - salida

end
  