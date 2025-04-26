        NAME    "sep_cad"
        ORG     0100H
        jmp     main

linea   DB      81 DUP (0)  ;Arreglo de cadena
t_linea DB      0           ;Tamaño de cadena
salir   DB      0           ;Bandera para terminar un ciclo
datos   DW      10 DUP (0)  ;arreglo de datos.
opers   DB      5  DUP (0) 
base    DB      16
NvaLine DB      0dh,0ah 
msg1    DB      "Dame el nombre del archivo. usa el formato 8.3",0dH,0aH
msg2    DB      "Escribe una linea, maximo 80 caracteres",0dH,0aH
msg3    DB      "Presiona <ESC> PARA SALIR",0dH,0aH
msg4    DB      "s",0dH,0aH
msge01  DB      "Funcion No Valida",0dh,0aH
msge02  DB      "Archivo No Encontrado",0dH,0aH
msge03  DB      "Ruta No Valida",0dH,0aH
msge04  DB      "Handle No Disponible",0dH,0aH
msge05  DB      "Acceso Denegado",0dH,0aH
msge06  DB      "Handle no valido",0dH,0aH
msge07  DB      "Caracter no valido",0dH,0aH
msge08  DB      "s",0dh,0aH
msge09  DB      "s",0dH,0aH
msge0A  DB      "s",0dH,0aH
msge0B  DB      "s",0dH,0aH
msge0C  DB      "s",0dH,0aH
msge0D  DB      "s",0dH,0aH
msge0E  DB      "s",0dH,0aH
msge0F  DB      "s",0dH,0aH
msge10  DB      "Excede el número de caracteres",0dH,0aH
msge11  DB      "s",0dH,0aH
tmsge01 DW      msge02 - offset msge01
tmsge02 DW      msge03 - offset msge02
tmsge03 DW      msge04 - offset msge03
tmsge04 DW      msge05 - offset msge04
tmsge05 DW      msge06 - offset msge05
tmsge06 DW      msge07 - offset msge06
tmsge07 DW      msge08 - offset msge07
tmsge08 DW      msge09 - offset msge08
tmsge09 DW      msge0A - offset msge09
tmsge0A DW      msge0B - offset msge0A
tmsge0B DW      msge0C - offset msge0B
tmsge0C DW      msge0D - offset msge0C
tmsge0D DW      msge0E - offset msge0D
tmsge0E DW      msge0F - offset msge0E
tmsge0F DW      msge10 - offset msge0F
       
leecad: push    di
        push    si
        push    cx 
        push    ax 
        mov     [t_linea],cl
ntecla: jcxz    enc
        mov     ah,0
        int     16H
        mov     [si],al
        inc     si
        dec     cx
        cmp     al,1BH
        jne     sigue
        mov     [salir],1
        jmp     FINCAD
sigue:  cmp     al,0DH
        je      FINCAD
        cmp     al,08H
        je      borra
        mov     ah,0EH
        int     10H
        jmp     ntecla
borra:  dec     si
        dec     si
        inc     cx
        inc     cx
        mov     ah,0eH
        int     10H
        mov     al,20H
        int     10H
        mov     al,08
        int     10H
        jmp     ntecla
enc:    lea     di,msge10  ;Excede el número de caracteres
        mov     cx,msge11 - offset msge10
        mov     dh,0
        mov     dl,0
        call    imprime
        mov     dh,03
	    mov     dl,0
	    mov     bh, 0
	    mov     ah, 2
	    int     10h
        lea     si,linea
        mov     cx,30
        call    limpia
        lea     di,msg2  ;Escribe una linea, maximo 80 caracteres
        mov     cx,msg3 - offset msg2
        mov     dh,1
        mov     dl,0
        call    imprime
        mov     dh,03
	    mov     dl,0
	    mov     bh, 0
	    mov     ah, 2
	    int     10h
	    call    BorraLinea
        mov     dh,03
	    mov     dl,0
	    mov     bh, 0
	    mov     ah, 2
	    int     10h
        lea     si,linea
        mov     cx,30
        jmp     ntecla
FINCAD: dec     si
        mov     [si],0
        mov     ah,0eH
        mov     al,0dH
        int     10H
        mov     al,0aH
        int     10H
        sub     [t_linea],cl
        pop     ax
        pop     cx
        pop     si
        pop     di 
        ret    
             
imprime:
       	push    bx
       	push    ax
       	push    es
       	mov     al,1
    	mov     bh,0
    	mov     bl,0011_1011b
    	push    cs
    	pop     es
    	mov     bp,di
    	mov     ah,13h
    	int     10h
    	pop     es
    	pop     ax
    	pop |   bx
    	ret
    	
BorraLinea:
        push    ax
        push    bx
        push    cx
        mov     cx,80
        mov     al,32
        mov     bh,0
        mov     ah,0aH
        int     10H
        pop     cx
        pop     bx
        pop     ax
        ret 
        
limpia: push    si
        push    cx
l_lim:  mov     [si],0
        inc     si
        loop    l_lim
        pop     cx
        pop     si
        ret	        

asc2num:
        sub     al,48
        cmp     al,9
        jle     f_asc
        sub     al,7
        cmp     al,15
        jle     f_asc
        sub     al,32
f_asc:  ret        

main:   
        xor     ax,ax
        xor     dx,dx
        mov     cx,30    ;cx debe tener el tamaño de la cadena para la funcion leecad
        lea     si,linea ;Arreglo en el que se almacenara la cadena.
        call    leecad
        lea     di,datos
        lea     dx,opers
        mov     al,[si]
        cmp     al,0
        je      fin
        call    asc2num
        cmp     al,0fh
        ja      c_err ;Error de caracter.
        mov     [di],ax
nvocar: inc     si
        mov     al,[si]
        test    al,0FFh
        je      fin
        call    asc2num
        cmp     al,0fh
        ja      leeop
        push    dx
        push    ax
        mov     ax,[di]
        mov     bl,[base]
        mul     bx
        mov     [di],ax
        pop     ax
        pop     dx
        add     [di],ax
        jmp     nvocar
leeop:  push    di
        mov     di,dx
        mov     al,[si]
        cmp     al,'*'
        je      op0
op1:    cmp     al,'/'
        je      op0
op2:    cmp     al,'-'
        je      op0
op3:    cmp     al,'+'
        jne     c_err
op0:    mov     [di],al
        inc     di
        mov     dx,di
        pop     di
        inc     di
        inc     di
        jmp     nvocar
c_err:  push    di
        lea     di,msge07  ;Caracter no valido
        mov     cx,msge07 - offset msge06
        mov     dh,5
        mov     dl,0
        call    imprime
        pop     di
        
fin:        
        xor     ax,ax
        int     20h
        
