
.MODEL SMALL
.STACK 100h

.DATA
msg1        db 13,10,'[Stub] Ingresar calificaciones seleccionado.',13,10,'$'
msg2        db 13,10,'[Stub] Mostrar estadisticas seleccionado.',13,10,'$'
msg3        db 13,10,'[Stub] Buscar estudiante por indice seleccionado.',13,10,'$'
msg4        db 13,10,'[Stub] Ordenar calificaciones seleccionado.',13,10,'$'
pressAny    db 13,10,'Presione cualquier tecla para volver al menu...',13,10,'$'

.CODE

extern Menu_Print:NEAR
extern Menu_ReadChoice:NEAR
extern Buscar_Estudiante:NEAR

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

END start

