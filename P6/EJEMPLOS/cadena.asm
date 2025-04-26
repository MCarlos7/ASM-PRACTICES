        NAME    "Cad"
        ORG     0100H
setup:        
        mov ax, 1003h
        mov bx, 0
        int 10h
        jmp     main

ecuaci  DB      30  dup (0) 
msge1   DB      "Excede el numero de caracteres",0aH,0dH
msgend:

main:        
        lea     si,ecuaci
        mov     cx,30
ntecla: dec     cx
        jz      enc
        mov     ah,0
        int     16H
        mov     [si],al
        inc     si
        cmp     al,0DH
        je      FINCAD
        mov     ah,0EH
        int     10H
        cmp     al,08H
        jne     ntecla
borra:  dec     si
        inc     cx
        mov     ah,0EH
        mov     al,20H
        int     16H
        jmp     ntecla
FINCAD: mov     al,0aH
        int     10H
        mov     al,0dH
        int     10H 
        mov     ah,0
        int     20H

enc:    
        push    di
        push    cx
        lea     di,msge1
        mov     cx,msgend - offset msge1
        call    imprime
        pop     cx
        pop     di
        jmp     FINCAD
        
imprime:
       	push    bx
       	push    dx
       	mov     al,1
    	mov     bh,0
    	mov     bl,0011_1011b
    	mov     dl,10
    	mov     dh,7
    	push    cs
    	pop     es
    	mov     bp,di
    	mov     ah,13h
    	int     10h
    	pop     dx
    	pop     bx
    	ret        

                      