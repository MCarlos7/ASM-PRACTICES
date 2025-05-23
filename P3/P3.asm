name "P3"                        
org 100h   

;--------------------------------------------------
; Modo de video y colores
  
    mov al, 1                ; Modo video
    mov bh, 0                
    mov bl, 0000_1001b       ; Color
    
;--------------------------------------------------
; Espera de tecla
    mov ah, 0
    int 16h          ; Espera de tecla
    
;--------------------------------------------------
; SUMA 


mov ax, 0          ; Inicializar AX en 0
mov dx, 0          ; Inicializar DX en 0 (para manejar el acarreo)

; Sumar el primer numero (direcciones 0x210 y 0x211)
mov ax, [0x210]    
add dx, ax         ; Sumar a DX:AX

; Sumar el segundo numero (direcciones 0x212 y 0x213)
mov ax, [0x212]    
adc dx, ax         ; Sumar con acarreo

; Sumar el tercer numero (direcciones 0x214 y 0x215)
mov ax, [0x214]    
adc dx, ax         

; Sumar el cuarto numero (direcciones 0x216 y 0x217)
mov ax, [0x216]    
adc dx, ax         

; Sumar el quinto numero (direcciones 0x218 y 0x219)
mov ax, [0x218]    
adc dx, ax         

; Guardar el resultado en formato little endian en 4 bytes
mov [0x220], dl    ; Byte menos significativo del resultado
mov [0x221], dh    ; Segundo byte
mov [0x222], al    ; Tercer byte (si hubo acarreo)
mov [0x223], ah    ; Cuarto byte (si hubo acarreo)

;--------------------------------------------------
; Ajuste final de la pila: SP debe ser FFF8h
    mov sp, 0FFF8h   
                                               
;--------------------------------------------------
; PRINT

; nombre
    mov bp, offset nombre
    mov cx, nombre_T
    mov dl, 10       ; Columna
    mov dh, 2        ; Fila
    mov ah, 13h
    int 10h

; direcciones de entrada
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
; Espera de tecla y fin del programa
    mov ah, 0
    int 16h          ; Espera de tecla
    int 20h          ; Finaliza el programa
                           
                           
;--------------------------------------------------
; DATOS

; Texto
nombre    db "Alumno: Carlos Alberto  Sec: D06", 0 
entrada    db "Entrada en memoria: 0210h, 0212h, 0214h, 0216h, 0218h", 0
salida    db "Salida almacenado en: 0220h", 0   
fin:

nombre_T = entrada - nombre
entrada_T = salida - entrada 
salida_T = fin - salida

end
                          