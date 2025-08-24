; ============================================================
; main.asm — Punto de entrada. Llama al menu y despacha opciones.
; Compila y linkea junto con menu.asm (modelo SMALL).
; ============================================================

.MODEL SMALL
.STACK 100h                    ; Pila razonable para programa DOS clasico

.DATA
        ; Muestra mensajes de cada opcion seleccionada
msg1        db 13,10,'[Stub] Ingresar calificaciones seleccionado.',13,10,'$'
msg2        db 13,10,'[Stub] Mostrar estadisticas seleccionado.',13,10,'$'
msg3        db 13,10,'[Stub] Buscar estudiante por indice seleccionado.',13,10,'$'
msg4        db 13,10,'[Stub] Ordenar calificaciones seleccionado.',13,10,'$'
pressAny    db 'Presione cualquier tecla para volver al menu...',13,10,'$'

.CODE
EXTRN Menu_Print:NEAR, Menu_ReadChoice:NEAR   ; Importa rutinas del menu

start:
    ; Inicializa el segmento de datos
    mov  ax, @DATA
    mov  ds, ax

MainLoop:
    call Menu_Print          ; Pinta menu y prompt
    call Menu_ReadChoice     ; Devuelve AL=1..5

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
    jmp  MainLoop            ; Defensa: no deberia suceder

; --- Opciones (solo mensajes de ejemplo; aqui iria tu logica) ---
Opt1: ; Ingresar calificaciones
    mov  dx, OFFSET msg1
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

Opt2: ; Mostrar estadisticas
    mov  dx, OFFSET msg2
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

Opt3: ; Buscar estudiante por indice
    mov  dx, OFFSET msg3
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

Opt4: ; Ordenar calificaciones
    mov  dx, OFFSET msg4
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn

WaitAndReturn:
    mov  dx, OFFSET pressAny
    mov  ah, 09h
    int  21h

    mov  ah, 07h             ; Espera una tecla sin eco (no requiere Enter)
    int  21h
    jmp  MainLoop

ExitProgram: ; Salida del programa
    mov  ax, 4C00h           ; Salir  del programa
    int  21h

END start
