org 100h     

.DATA

Bienvenida     db 13,10, 'Bienvenidos a RegistroCE:',13,10,'$' 
Digite         db 13,10, 'Digite:',13,10,'$'
Calificaciones db '1.Ingresar calificaciones',13,10,'$'
Estadisticas   db '2) Mostrar estadisticas.',13,10,'$'
Buscar         db '3) Buscar estudiante por indice.',13,10,'$'
Ordenar        db '4) Ordenar calificaciones.',13,10,'$'
Salir          db '5) Salir.',13,10,'$'
msgInvalid     db 13,10,'Entrada Invalida',13,10,'$'
msg2           db 13,10,'Promedio: Maxima: Minima: Aprobados: Reprobados$',13,10
msg3           db 13,10,'Indice$',13,10
msg4           db 13,10,'Calicifaciones$',13,10

msgSalir       db 13,10,'Gracias por usar Registro CE',13,10,'$'
inMenu         db 1      ; 1 = en menu principal, 0 = en una opcion
    
.CODE
start:
MainLoop:
    call Menu_Print
    call Menu_Leer_Tecla   ; retorna el numero en AX

    cmp ax, 1
    je opcion1
    cmp ax, 2
    je opcion2
    cmp ax, 3
    je opcion3
    cmp ax, 4
    je opcion4
    cmp ax, 5
    je opcion5
    jmp MainLoop

opcion1:
    ;Estamos dentro de una funcion (al presionar 5 nos devolvemos 
    ;al menu (igual para 2, 3, 4))
    mov inMenu, 0
    mov ah, 09h
    int 21h
    ; Este loop espera la entrada del usuario para retornarlo al menu
    call WaitForReturn
    jmp MainLoop

opcion2:
    mov inMenu, 0
    mov dx, OFFSET msg2
    mov ah, 09h
    int 21h
    call WaitForReturn
    jmp MainLoop

opcion3:
    mov inMenu, 0
    mov dx, OFFSET msg3
    mov ah, 09h
    int 21h
    call WaitForReturn
    jmp MainLoop

opcion4:
    mov inMenu, 0
    mov dx, OFFSET msg4
    mov ah, 09h
    int 21h
    call WaitForReturn
    jmp MainLoop

opcion5:
    cmp inMenu, 1
    je FinalizarPrograma    ; Si estamos en menu principal, salir del programa
    ; Si estamos en una opcion, volver al menu
    mov inMenu, 1
    jmp MainLoop

FinalizarPrograma:
    mov dx, OFFSET msgSalir
    mov ah, 09h
    int 21h
    mov ah, 4Ch       ; Terminar programa
    int 21h


WaitForReturn PROC NEAR
    push ax
WaitLoop:
    mov ah, 01h       ; Leer caracter
    int 21h
    cmp al, '5'       ; Si se teclea 5, vuelve al menu
    
    je RegresarAlMenu
    jmp WaitLoop      ; Esperar hasta que presione 5

RegresarAlMenu:
    mov inMenu, 1     ; Marcar que estamos de vuelta en el menu
    pop ax
    ret
WaitForReturn ENDP

Menu_Print PROC NEAR
    push ax
    push dx
    
    mov dx, OFFSET Bienvenida
    mov ah, 09h
    int 21h
    mov dx, OFFSET Digite
    mov ah, 09h
    int 21h

    mov dx, OFFSET Calificaciones
    mov ah, 09h
    int 21h

    mov dx, OFFSET Estadisticas
    mov ah, 09h
    int 21h

    mov dx, OFFSET Buscar
    mov ah, 09h
    int 21h

    mov dx, OFFSET Ordenar
    mov ah, 09h
    int 21h

    mov dx, OFFSET Salir
    mov ah, 09h
    int 21h

    pop dx
    pop ax
    ret
Menu_Print ENDP

Menu_Leer_Tecla PROC NEAR
ReadLoop:
    mov ah, 01h ; Leer caracter
    int 21h

    cmp al, '1'
    jb Invalid
    cmp al, '5'
    ja Invalid

    sub al, '0' ; convertir ASCII a numero
    xor ah, ah
    mov ax, ax      
    ret

Invalid:
    push ax
    push dx
    mov dx, OFFSET msgInvalid
    mov ah, 09h
    int 21h

    pop dx
    pop ax
    jmp ReadLoop
Menu_Leer_Tecla ENDP

