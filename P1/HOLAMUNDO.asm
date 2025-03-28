name "holamundo"

org 100h

	mov al, 1          ;Modo video
	mov bh, 0          ;Pagina de video
	mov bl, 0011_1001b ;Colores
	
	;////////////////////////////////////////////// 
	mov cx, msg2 - offset msg1 ; calcula el tamaño del mensaje. 
	mov dl, 20        ; Posicion
	mov dh, 11       ; Posicion  
	    
	mov bp, offset msg1  ;Apunta a msj1
	mov ah, 13h          ;Print cadena txt mode 
	int 10h              ;Llamada a print
	
	;////////////////////////////////////////////// 
	mov cx, msg3 - offset msg2  ;Calcula la longitud de msg2 y la almacena en CX
	mov dl, 9           ; Posicion
	mov dh, 13           ; Posicion  
	
	mov bp, offset msg2 ; Print
	mov ah, 13h
	int 10h 
	
	;////////////////////////////////////////////// 
	mov cx, msgend - offset msg3  ;Calcula la longitud de msg2 y la almacena en CX
	mov dl, 7           ; Posicion
	mov dh, 15           ; Posicion  
	
	mov bp, offset msg3 ; Print
	mov ah, 13h
	int 10h
	           
	           
	           
	           
	jmp msgend           ; Salto a la etiqueta msgend
                         
	
msg1    db "Hola Mensaje 1"
msg2    db "Carlos Alberto Mariscal Romo 219804747 "  
msg3    db "/\/\/\/\/\/\/\/\/\//\/\/\/\/\/\/\/\//\/\/\/\"

msgend:
        mov ah,0
        int 16h     ; Input teclado
        int 20h     ; Finalizacion
        