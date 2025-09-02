; =====================================================================
; MODULO: ESTADISTICAS (stats.asm)
; =====================================================================
; Este archivo contiene las subrutinas para calcular estadisticas
; sobre los datos de los estudiantes.
; Utiliza una estructura de datos de prueba para validacion.
; =====================================================================

org 100h

; ============================================================
;   ESTRUCTURA DE DATOS Y VARIABLES PARA ESTADISTICAS
; ============================================================
.DATA

; --- Definicion de la estructura (consistente con main.asm) ---
MAX_ESTUDIANTES EQU 15
TAM_REGISTRO    EQU 68
TAM_NOMBRE      EQU 21
TAM_APELLIDO1   EQU 21
TAM_APELLIDO2   EQU 21
OFFSET_NOTA     EQU TAM_NOMBRE + TAM_APELLIDO1 + TAM_APELLIDO2 ; 63

; --- Datos de prueba (5 estudiantes) ---
NumEstudiantesRegistrados DB 5

EstudiantesData:
    ; Estudiante 1: Nota 85.12345
    DB 'Juan$'
    DB 16 DUP(0)
    DB 'Perez$'
    DB 15 DUP(0)
    DB 'Lopez$'
    DB 15 DUP(0)
    DD 8512345
    DB 0 ; Padding

    ; Estudiante 2: Nota 69.99999 (Reprobado)
    DB 'Maria$'
    DB 15 DUP(0)
    DB 'Gomez$'
    DB 15 DUP(0)
    DB 'Ruiz$'
    DB 16 DUP(0)
    DD 6999999
    DB 0 ; Padding

    ; Estudiante 3: Nota 95.00000 (Maxima)
    DB 'Carlos$'
    DB 14 DUP(0)
    DB 'Sanchez$'
    DB 13 DUP(0)
    DB 'Diaz$'
    DB 16 DUP(0)
    DD 9500000
    DB 0 ; Padding

    ; Estudiante 4: Nota 50.50000 (Minima)
    DB 'Ana$'
    DB 17 DUP(0)
    DB 'Martinez$'
    DB 12 DUP(0)
    DB 'Soto$'
    DB 16 DUP(0)
    DD 5050000
    DB 0 ; Padding

    ; Estudiante 5: Nota 70.00000 (Aprobado)
    DB 'Luis$'
    DB 16 DUP(0)
    DB 'Hernandez$'
    DB 11 DUP(0)
    DB 'Vega$'
    DB 16 DUP(0)
    DD 7000000
    DB 0 ; Padding

; --- Variables para almacenar resultados ---
notaMaxima      DD 0
notaMinima      DD 0
promedioGeneral DD 0
aprobados       DW 0
reprobados      DW 0

; --- Mensajes para la salida ---
msgMaxima       DB 13, 10, 'Nota Maxima: $'
msgMinima       DB 13, 10, 'Nota Minima: $'
msgAprobados    DB 13, 10, 'Aprobados: $'
msgReprobados   DB 13, 10, 'Reprobados: $'
newLine         DB 13, 10, '$'

; --- Constantes ---
NOTA_APROBACION DD 7000000
DIVISOR_FLOAT   DW 10000
; Para la parte fraccional, usaremos 10000 y manejaremos el ultimo digito.
; Emu8086 tiene limitaciones con divisiones de 32 bits.


; ============================================================
;   CODIGO DE PRUEBA PRINCIPAL
; ============================================================
.CODE
start:
    mov ax, @DATA
    mov ds, ax

    ; --- Ejecutar calculos estadisticos ---
    call Stats_CalcularMaxMin
    ; call Stats_CalcularPromedio ; El promedio aun no se implementa completamente
    call Stats_ContarAprobadosReprobados
    ; --- Fin del programa de prueba ---
    mov ah, 4Ch
    int 21h

; ============================================================
;   SUBRUTINAS DE CALCULO ESTADISTICO
; ============================================================

; ------------------------------------------------------------
; Stats_CalcularMaxMin: Calcula la nota maxima y minima.
; Resultados en: notaMaxima (DD), notaMinima (DD)
; ------------------------------------------------------------
Stats_CalcularMaxMin PROC
    push ax
    push bx
    push cx
    push si
    push dx

    mov cl, [NumEstudiantesRegistrados] ; CX = numero de estudiantes
    xor ch, ch
    cmp cx, 0
    je MaxMin_End

    mov si, OFFSET EstudiantesData     ; SI apunta al primer estudiante
    add si, OFFSET_NOTA                ; Apuntar a la primera nota

    ; Inicializar max y min con la primera nota
    mov ax, [si]
    mov dx, [si+2]
    mov [notaMaxima], ax
    mov [notaMaxima+2], dx
    mov [notaMinima], ax
    mov [notaMinima+2], dx

    dec cx ; Ya procesamos el primero, ahora N-1 restantes
    jz MaxMin_End

MaxMin_Loop:
    add si, TAM_REGISTRO ; Siguiente estudiante

    ; Comparar con notaMaxima (DX:AX = nota actual)
    mov ax, [si]
    mov dx, [si+2]
    
    ; if (DX:AX > notaMaxima)
    cmp dx, [notaMaxima+2]
    ja MaxMin_SetMax
    jb MaxMin_CheckMin
    cmp ax, [notaMaxima]
    ja MaxMin_SetMax

MaxMin_CheckMin:
    ; Comparar con notaMinima (DX:AX = nota actual)
    ; if (DX:AX < notaMinima)
    cmp dx, [notaMinima+2]
    jb MaxMin_SetMin
    ja MaxMin_Next
    cmp ax, [notaMinima]
    jb MaxMin_SetMin
    jmp MaxMin_Next

MaxMin_SetMax:
    mov [notaMaxima], ax
    mov [notaMaxima+2], dx
    jmp MaxMin_CheckMin

MaxMin_SetMin:
    mov [notaMinima], ax
    mov [notaMinima+2], dx

MaxMin_Next:
    loop MaxMin_Loop

MaxMin_End:
    pop dx
    pop si
    pop cx
    pop bx
    pop ax
    ret
Stats_CalcularMaxMin ENDP

; ------------------------------------------------------------
; Stats_CalcularPromedio: Calcula el promedio general.
; Resultado en: promedioGeneral (DD)
; ------------------------------------------------------------
Stats_CalcularPromedio PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov cl, [NumEstudiantesRegistrados]
    xor ch, ch
    cmp cx, 0
    je Promedio_End

    ; Guardar numero de estudiantes para la division
    mov bx, cx

    ; Sumador de 64 bits (en BX:CX:DX:AX) - usaremos solo 32 bits por ahora
    xor ax, ax
    xor dx, dx
    
    mov si, OFFSET EstudiantesData
    add si, OFFSET_NOTA

Promedio_Loop:
    ; Sumar nota actual a DX:AX
    add ax, [si]
    adc dx, [si+2]
    
    add si, TAM_REGISTRO
    loop Promedio_Loop

    ; DX:AX contiene la suma total. 
    ; AQUI IRIA UNA RUTINA DE DIVISION 32-bits / 16-bits.
    ; Por ahora, dejamos la suma en promedioGeneral para verificar.
    ; div bx ; Esto daria un error de overflow porque el cociente no cabe en AX
    
    mov [promedioGeneral], ax
    mov [promedioGeneral+2], dx

Promedio_End:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Stats_CalcularPromedio ENDP

; ------------------------------------------------------------
; Stats_ContarAprobadosReprobados: Cuenta aprobados y reprobados.
; Resultados en: aprobados (DW), reprobados (DW)
; ------------------------------------------------------------
Stats_ContarAprobadosReprobados PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov cl, [NumEstudiantesRegistrados]
    xor ch, ch
    cmp cx, 0
    je Contar_End

    xor ax, ax
    mov [aprobados], ax
    mov [reprobados], ax

    mov si, OFFSET EstudiantesData
    add si, OFFSET_NOTA

Contar_Loop:
    mov ax, [si]
    mov dx, [si+2]

    ; if (DX:AX >= NOTA_APROBACION)
    cmp dx, [NOTA_APROBACION+2]
    jb Contar_Reprobado
    ja Contar_Aprobado
    cmp ax, [NOTA_APROBACION]
    jb Contar_Reprobado

Contar_Aprobado:
    inc WORD PTR [aprobados]
    jmp Contar_Next

Contar_Reprobado:
    inc WORD PTR [reprobados]

Contar_Next:
    add si, TAM_REGISTRO
    loop Contar_Loop

Contar_End:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Stats_ContarAprobadosReprobados ENDP

END start
