; ============================================================
;   PROYECTO: MENU DE ESTUDIANTES
;   Compatible con emu8086
;   Estructura modular (main + menu + buscarIndice)
; ============================================================

org 100h

; ============================================================
;   DATOS DEL MAIN
; ============================================================
.DATA
msg1        db 13,10,'[Stub] Ingresar calificaciones seleccionado.',13,10,'$'
msg2        db 13,10,'[Stub] Mostrar estadisticas seleccionado.',13,10,'$'
msg3        db 13,10,'[Stub] Buscar estudiante por indice seleccionado.',13,10,'$'
msg4        db 13,10,'[Stub] Ordenar calificaciones seleccionado.',13,10,'$'
pressAny    db 13,10,'Presione cualquier tecla para volver al menu...',13,10,'$'

; ============================================================
;   DATOS DEL MENU
; ============================================================
menuTitle   db 13,10, '=== MENU PRINCIPAL ===',13,10,'$'
Calificaciones db '1) Ingresar calificaciones.',13,10,'$'
Estadisticas   db '2) Mostrar estadisticas.',13,10,'$'
Buscar         db '3) Buscar estudiante por indice.',13,10,'$'
Ordenar        db '4) Ordenar calificaciones.',13,10,'$'
Salir          db '5) Salir.',13,10,'$'
prompt         db 'Seleccione una opcion [1-5]: $'
msgInvalido    db 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'

; ============================================================
;   DATOS DE BUSCAR INDICE
; ============================================================

msgIngIndice   db 13,10,'Ingrese el indice del estudiante (1-15): $'
msgFueraRango  db 13,10,'[ERROR] Indice fuera de rango.',13,10,'$'
msgResultado   db 13,10,'Estudiante: $'
msgNota        db 13,10,'Nota: $'
newline        db 13,10,'$'

; ============================================================
;   CODIGO PRINCIPAL (MAIN)
; ============================================================
.CODE

start:
    ;mov  ax, @DATA
   ; mov  ds, ax

MainLoop:
    call Menu_Print
    call Menu_ReadChoice

    cmp  al, 1
    je   Opt1
    cmp  al, 2
    je   Opt2
    cmp  al, 3
    je   Opt3
    cmp  al, 4
    je   Opt4
    cmp  al, 5
    je   ExitProgram
    jmp  MainLoop

Opt1:
    mov  dx, OFFSET msg1
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

Opt2:
    mov  dx, OFFSET msg2
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

Opt3:
    mov  dx, OFFSET msg3
    mov  ah, 09h
    int  21h
    call Buscar_Estudiante
    jmp  WaitAndReturn

Opt4:
    mov  dx, OFFSET msg4
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

WaitAndReturn:
    mov  dx, OFFSET pressAny
    mov  ah, 09h
    int  21h

    mov  ah, 07h
    int  21h
    jmp  MainLoop

ExitProgram:
    mov  ah, 4Ch
    mov  al, 00h
    int  21h

; ============================================================
;   MODULO: MENU
; ============================================================

Menu_Print PROC NEAR
    push ax
    push dx

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

    cmp  al, '1'
    jb   Invalid
    cmp  al, '5'
    ja   Invalid

    sub  al, '0'
    xor  ah, ah
    ret

Invalid:
    push ax
    push dx
    mov  dx, OFFSET msgInvalido
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET prompt
    mov  ah, 09h
    int  21h
    pop  dx
    pop  ax
    jmp  ReadLoop
Menu_ReadChoice ENDP

; ============================================================
;   MODULO: BUSCAR INDICE
; ============================================================

Buscar_Estudiante PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si

    mov dx, OFFSET msgIngIndice
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'
    mov bl, al

    cmp bl, 1
    jb FueraRango
    cmp bl, 15
    ja FueraRango

    dec bl              ; índice base 0
    mov si, bx

    ;mov bx, OFFSET estudiantes
NextStudent:
    cmp si, 0
    je  FoundStudent
SkipLoop:
    mov al, [bx]
    inc bx
    cmp al, '$'
    jne SkipLoop
    inc bx              ; saltar nota
    dec si
    jmp NextStudent

FoundStudent:
    mov dx, OFFSET msgResultado
    mov ah, 09h
    int 21h

    mov dx, bx
    mov ah, 09h
    int 21h

SkipToNota:
    mov al, [bx]
    inc bx
    cmp al, '$'
    jne SkipToNota

    mov dx, OFFSET msgNota
    mov ah, 09h
    int 21h

    mov al, [bx]
    call PrintNumber
    jmp Fin

FueraRango:
    mov dx, OFFSET msgFueraRango
    mov ah, 09h
    int 21h

Fin:
    mov dx, OFFSET newline
    mov ah, 09h
    int 21h

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Buscar_Estudiante ENDP

; ---- Imprimir número (0-255) ----
PrintNumber PROC NEAR
    push ax
    push bx
    push cx
    push dx

    xor ah, ah
    mov bl, 10
    xor cx, cx

DivideLoop:
    xor dx, dx
    div bl
    push dx
    inc cx
    cmp al, 0
    jne DivideLoop

PrintLoop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop PrintLoop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintNumber ENDP

; ============================================================
;   FIN DEL PROGRAMA
; ============================================================
END start
; ============================================================

