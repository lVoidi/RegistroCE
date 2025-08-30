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
msgSalida    db 13,10,'Gracias por usar Registro CE. Hasta luego!',13,10,'$'

; ============================================================
;   DATOS DE BUSCAR INDICE
; ============================================================

msgIngIndice   db 13,10,'Ingrese el indice del estudiante (1-15): $'
msgFueraRango  db 13,10,'[ERROR] Indice fuera de rango.',13,10,'$'
msgResultado   db 13,10,'Estudiante: $'
msgNota        db 13,10,'Nota: $'
newline        db 13,10,'$'
estudiantes db 0
msgListaVacia db 13,10,'Lista vacia$',13,10,'$'

; ============================================================
;   CODIGO PRINCIPAL (MAIN)
; ============================================================
.CODE

start:
    mov  ax, @DATA
    mov  ds, ax

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
    je   Opt5
    jmp  MainLoop

Opt1:
    mov  dx, OFFSET msg1 ;Ingresio de calificaciones
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

Opt2:
    mov  dx, OFFSET msg2 ;Mostrar estadisticas
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

Opt3:
    mov  dx, OFFSET msg3 ;Buscar estudiante por indice
    mov  ah, 09h
    int  21h
    call Buscar_Estudiante
    jmp  WaitAndReturn

Opt4:
    mov  dx, OFFSET msg4 ;Ordenar calificaciones
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

Opt5:
    mov  dx, OFFSET msgSalida ;Salir
    mov  ah, 09h
    int  21h
    jmp  ExitProgram

WaitAndReturn: ;Esperar tecla y volver al menu
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

Menu_ReadChoice PROC NEAR ;Leer opcion del menu
    push dx
ReadLoop:
    mov  ah, 01h
    int  21h             ; leer tecla, resultado en AL

    cmp  al, '1'
    jb   Invalid
    cmp  al, '5'
    ja   Invalid

    sub  al, '0'         ; convierte '1'..'5' en 1..5
    xor  ah, ah          ; AX = 1..5
    pop  dx
    ret                  ; devuelve con AL=opcion
Invalid:
    mov  dx, OFFSET msgInvalido
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET prompt
    mov  ah, 09h
    int  21h
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

    ; --- Verificar si lista vacía ---
    mov bx, OFFSET estudiantes
    mov al, [bx]
    cmp al, 0          ; si está vacía
    je ListaVacia
    cmp al, '$'        ; o si tiene solo terminador
    je ListaVacia

    ; --- Pedir índice ---
    mov dx, OFFSET msgIngIndice
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'
    mov bl, al         ; guardar índice ingresado

    cmp bl, 1
    jb FueraRango
    cmp bl, 15
    ja FueraRango

    dec bl             ; índice base 0
    mov si, bx         ; contador de desplazamiento
    mov bx, OFFSET estudiantes

NextStudent:
    cmp si, 0
    je FoundStudent
SkipLoop:
    mov al, [bx]
    cmp al, '$'
    je EndOfRecord
    inc bx
    jmp SkipLoop

EndOfRecord:
    inc bx             ; saltar '$' (terminador de nombre)
    ; aquí podría venir la nota como texto hasta otro '$'
    ; saltamos la nota también
SkipNota:
    mov al, [bx]
    cmp al, '$'
    je SkipNotaDone
    inc bx
    jmp SkipNota
SkipNotaDone:
    inc bx
    dec si
    jmp NextStudent

FoundStudent:
    ; Mostrar mensaje resultado
    mov dx, OFFSET msgResultado
    mov ah, 09h
    int 21h

    ; Mostrar nombre y apellidos hasta '$'
ShowName:
    mov al, [bx]
    cmp al, '$'
    je AfterName
    mov dl, al
    mov ah, 02h
    int 21h
    inc bx
    jmp ShowName

AfterName:
    inc bx             ; saltar '$'

    ; Mostrar mensaje nota
    mov dx, OFFSET msgNota
    mov ah, 09h
    int 21h

    ; Mostrar nota hasta '$'
ShowNota:
    mov al, [bx]
    cmp al, '$'
    je Fin
    mov dl, al
    mov ah, 02h
    int 21h
    inc bx
    jmp ShowNota

FueraRango:
    mov dx, OFFSET msgFueraRango
    mov ah, 09h
    int 21h
    jmp Fin

ListaVacia:
    mov dx, OFFSET msgListaVacia
    mov ah, 09h
    int 21h
    jmp Fin

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

; ============================================================
;   FIN DEL PROGRAMA
; ============================================================
END start
; ============================================================

