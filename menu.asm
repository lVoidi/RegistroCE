; ============================================================
; menu.asm - Modulo que implementa el menu principal.
; Diseñado para ser incluido en main.asm con INCLUDE.
; ============================================================

.DATA
menuTitle      db 13,10, '=== MENU PRINCIPAL ===',13,10,'$'
Calificaciones          db '1) Ingresar calificaciones.',13,10,'$'
Estadisticas         db '2) Mostrar estadisticas.',13,10,'$'
Buscar          db '3) Buscar estudiante por indice.',13,10,'$'
Ordenar          db '4) Ordenar calificaciones.',13,10,'$'
Salir          db '5) Salir.',13,10,'$'
prompt         db 'Seleccione una opcion [1-5]: $'
msgInvalid     db 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'

.CODE
; No se usa PUBLIC porque el código se inserta directamente

Menu_Print PROC NEAR
    push ax
    push dx
    
    ; Mostrar título del menú

    mov  dx, OFFSET menuTitle
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET Calificaciones  
    mov  ah, 09h 
    int  21h 

    mov  dx, OFFSET Estadisticas
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET Buscar
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET Ordenar
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET Salir
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET prompt
    mov  ah, 09h
    int  21h

    pop  dx 
    pop  ax 
    ret
Menu_Print ENDP

Menu_ReadChoice PROC NEAR
ReadLoop:
    mov  ah, 01h
    int  21h
    ; Convertir entrada a numero
    cmp  al, '1'
    jb   Invalid
    cmp  al, '5'
    ja   Invalid

    sub  al, '0'
    xor  ah, ah
    ret

Invalid:
; Manejar entrada invalida
    push ax
    push dx
    mov  dx, OFFSET msgInvalid
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET prompt
    mov  ah, 09h
    int  21h
    pop  dx
    pop  ax
    jmp  ReadLoop
Menu_ReadChoice ENDP
