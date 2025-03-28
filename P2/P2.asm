name "holamundo" 

org 100h

;--------------------------------------------------
; Modo de video y colores
  
    mov al, 1                ; Modo video
    mov bh, 0                
    mov bl, 0011_1001b       ; Color

;--------------------------------------------------
; Print datos 
 

; Nombre
    mov cx, msg2 - msg1      ; Longitud de msg1
    mov dl, 20               ; Posicion
    mov dh, 11               ; Posicion
    mov bp, offset msg1      ; Direccion
    mov ah, 13h              ; Print
    int 10h

; Codigo 
    mov cx, msg3 - msg2      
    mov dl, 9                
    mov dh, 13               
    mov bp, offset msg2      
    mov ah, 13h
    int 10h

; NRC
    mov cx, finprog - msg3   
    mov dl, 7                
    mov dh, 15               
    mov bp, offset msg3      
    mov ah, 13h
    int 10h

;--------------------------------------------------
; Registros                 
                        ; MI CODIGO (32b/ 16+16) 0000110100011011 0110100100101011
                        
    mov dx, 0D1Bh       ; 16 bits + CODIGO
    mov cx, 692Bh       ; 16 bits - CODIGO

                        ; NRC (32b/ 16+16) 0000000000000011 1001110010110010  
    mov bx, 0003h       ; 16 bits + NRC 
    mov ax, 3CB2h       ; 16 bits - NRC 
    
    mov sp, 0FFF8h      ; SP

;--------------------------------------------------
;FIN       

    mov ah, 0
    int 16h             ; INPUT  
    mov ax, 3CB2h       ; Asegurar que AX contiene el NRC antes de salir
    int 20h             ; FIN


msg1    db "Nombre: Carlos Alberto Mariscal Romo"
msg2    db "Codigo: 219804747"
msg3    db "NRC: 210898"
finprog:
