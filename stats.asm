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
TAM_REGISTRO    EQU 70  ; Actualizado: +2 bytes para almacenamiento separado
TAM_NOMBRE      EQU 21
TAM_APELLIDO1   EQU 21
TAM_APELLIDO2   EQU 21
OFFSET_NOTA     EQU 63  ; TAM_NOMBRE + TAM_APELLIDO1 + TAM_APELLIDO2 = 21+21+21 = 63

; Definir estructura para almacenamiento de notas separadas
NOTA_INT_SIZE   EQU 2   ; DW para parte entera (0-100)
NOTA_FRAC_SIZE  EQU 4   ; DD para parte decimal (0-99999)

; --- Datos de prueba (5 estudiantes) ---
NumEstudiantesRegistrados DB 5

EstudiantesData:
    ; Estudiante 1: Nota 85.12345
    DB 'Juan$'             ; 5 bytes
    DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    DB 'Perez$'            ; 6 bytes  
    DB 15 DUP(0)           ; 15 bytes -> Total: 21 bytes
    DB 'Lopez$'            ; 6 bytes
    DB 15 DUP(0)           ; 15 bytes -> Total: 21 bytes
    DW 85                  ; 2 bytes - Parte entera
    DD 12345               ; 4 bytes - Parte decimal
    DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

    ; Estudiante 2: Nota 69.99999 (Reprobado)
    DB 'Maria$'            ; 6 bytes
    DB 15 DUP(0)           ; 15 bytes -> Total: 21 bytes
    DB 'Gomez$'            ; 6 bytes
    DB 15 DUP(0)           ; 15 bytes -> Total: 21 bytes
    DB 'Ruiz$'             ; 5 bytes
    DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    DW 69                  ; 2 bytes - Parte entera
    DD 99999               ; 4 bytes - Parte decimal
    DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

    ; Estudiante 3: Nota 95.00000 (Maxima)
    DB 'Carlos$'           ; 7 bytes
    DB 14 DUP(0)           ; 14 bytes -> Total: 21 bytes
    DB 'Sanchez$'          ; 8 bytes
    DB 13 DUP(0)           ; 13 bytes -> Total: 21 bytes
    DB 'Diaz$'             ; 5 bytes
    DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    DW 95                  ; 2 bytes - Parte entera
    DD 0                   ; 4 bytes - Parte decimal
    DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

    ; Estudiante 4: Nota 50.50000 (Minima)
    DB 'Ana$'              ; 4 bytes
    DB 17 DUP(0)           ; 17 bytes -> Total: 21 bytes
    DB 'Martinez$'         ; 9 bytes
    DB 12 DUP(0)           ; 12 bytes -> Total: 21 bytes
    DB 'Soto$'             ; 5 bytes
    DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    DW 50                  ; 2 bytes - Parte entera
    DD 50000               ; 4 bytes - Parte decimal
    DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

    ; Estudiante 5: Nota 70.00000 (Aprobado)
    DB 'Luis$'             ; 5 bytes
    DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    DB 'Hernandez$'        ; 10 bytes
    DB 11 DUP(0)           ; 11 bytes -> Total: 21 bytes
    DB 'Vega$'             ; 5 bytes
    DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    DW 70                  ; 2 bytes - Parte entera
    DD 0                   ; 4 bytes - Parte decimal
    DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

; --- Variables para almacenar resultados ---
notaMaxima      DW 0    ; Parte entera
notaMaxima_frac DD 0    ; Parte decimal
notaMinima      DW 0    ; Parte entera  
notaMinima_frac DD 0    ; Parte decimal
promedioGeneral DW 0    ; Parte entera
promedio_frac   DD 0    ; Parte decimal
aprobados       DW 0
reprobados      DW 0

; --- Mensajes para la salida ---
msgMaxima       DB 13, 10, 'Nota Maxima: $'
msgMinima       DB 13, 10, 'Nota Minima: $'
msgPromedio     DB 13, 10, 'Promedio: $'
msgAprobados    DB 13, 10, 'Aprobados: $'
msgReprobados   DB 13, 10, 'Reprobados: $'
newLine         DB 13, 10, '$'

; --- Variables temporales ---
temp_decimal    DD 0

; --- Constantes ---
NOTA_APROBACION     DW 70       ; Parte entera de nota de aprobación
NOTA_APROBACION_FRAC DD 0       ; Parte decimal de nota de aprobación
DIVISOR_FLOAT       DW 10000


; ============================================================
;   CODIGO DE PRUEBA PRINCIPAL
; ============================================================
.CODE
start:
    mov ax, @DATA
    mov ds, ax

    ; --- Ejecutar calculos estadisticos ---
    call DebugEstudiantes  ; Nueva función de debug
    call DebugDirecto      ; Acceso directo a cada nota
    call Stats_CalcularMaxMin
    call Stats_CalcularPromedio ; Ahora el promedio está implementado completamente
    call Stats_ContarAprobadosReprobados
    
    ; --- Imprimir resultados ---
    call ImprimirResultados
    
    ; --- Fin del programa de prueba ---
    mov ah, 4Ch
    int 21h

; ============================================================
;   SUBRUTINAS DE CALCULO ESTADISTICO
; ============================================================

; ------------------------------------------------------------
; DebugEstudiantes: Imprime todas las notas para verificar acceso
; ------------------------------------------------------------
DebugEstudiantes PROC
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Imprimir el OFFSET_NOTA primero
    mov dl, 'O'
    mov ah, 02h
    int 21h
    mov dl, ':'
    mov ah, 02h
    int 21h
    mov ax, OFFSET_NOTA
    call ImprimirNumero
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Imprimir TAM_REGISTRO
    mov dl, 'T'
    mov ah, 02h
    int 21h
    mov dl, ':'
    mov ah, 02h
    int 21h
    mov ax, TAM_REGISTRO
    call ImprimirNumero
    mov dx, OFFSET newLine
    mov ah, 09h
    int 21h
    
    mov cl, [NumEstudiantesRegistrados]
    xor ch, ch
    
    mov si, OFFSET EstudiantesData
    add si, OFFSET_NOTA
    
    mov dl, 'N'
    mov ah, 02h
    int 21h
    mov dl, ':'
    mov ah, 02h
    int 21h
    
DebugLoop:
    ; Imprimir offset actual
    mov dl, '['
    mov ah, 02h
    int 21h
    mov ax, si
    call ImprimirNumero
    mov dl, ']'
    mov ah, 02h
    int 21h
    
    ; Imprimir parte entera
    mov ax, [si]
    call ImprimirNumero
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Imprimir parte decimal
    mov ax, [si+2]
    call ImprimirDecimal
    
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    add si, TAM_REGISTRO
    loop DebugLoop
    
    mov dx, OFFSET newLine
    mov ah, 09h
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DebugEstudiantes ENDP

; ------------------------------------------------------------
; DebugDirecto: Accede directamente a cada nota sin bucles
; ------------------------------------------------------------
DebugDirecto PROC
    push ax
    push si
    
    mov dl, 'D'
    mov ah, 02h
    int 21h
    mov dl, ':'
    mov ah, 02h
    int 21h
    
    ; Estudiante 1
    mov si, OFFSET EstudiantesData
    add si, 63      ; Hardcoded offset
    mov ax, [si]
    call ImprimirNumero
    mov dl, '.'
    mov ah, 02h
    int 21h
    mov ax, [si+2]
    call ImprimirDecimal
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Estudiante 2  
    mov si, OFFSET EstudiantesData
    add si, 133     ; 63 + 70 = 133
    mov ax, [si]
    call ImprimirNumero
    mov dl, '.'
    mov ah, 02h
    int 21h
    mov ax, [si+2]
    call ImprimirDecimal
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Estudiante 3
    mov si, OFFSET EstudiantesData
    add si, 203     ; 63 + 70*2 = 203
    mov ax, [si]
    call ImprimirNumero
    mov dl, '.'
    mov ah, 02h
    int 21h
    mov ax, [si+2]
    call ImprimirDecimal
    
    mov dx, OFFSET newLine
    mov ah, 09h
    int 21h
    
    pop si
    pop ax
    ret
DebugDirecto ENDP

; ------------------------------------------------------------
; Stats_CalcularMaxMin: Calcula la nota maxima y minima.
; Resultados en: notaMaxima/notaMaxima_frac, notaMinima/notaMinima_frac
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
    mov ax, [si]                       ; Parte entera
    mov [notaMaxima], ax
    mov [notaMinima], ax
    
    mov ax, [si+2]                     ; Parte decimal (low word)
    mov dx, [si+4]                     ; Parte decimal (high word)  
    mov [notaMaxima_frac], ax
    mov [notaMaxima_frac+2], dx
    mov [notaMinima_frac], ax
    mov [notaMinima_frac+2], dx

    dec cx ; Ya procesamos el primero, ahora N-1 restantes
    jz MaxMin_End

MaxMin_Loop:
    add si, TAM_REGISTRO ; Siguiente estudiante

    ; Comparar con notaMaxima
    mov ax, [si]                       ; Parte entera actual
    cmp ax, [notaMaxima]
    ja MaxMin_SetMax
    jb MaxMin_CheckMin
    
    ; Si partes enteras son iguales, comparar partes decimales
    mov bx, [si+2]                     ; Parte decimal actual (low word)
    mov dx, [si+4]                     ; Parte decimal actual (high word)
    
    cmp dx, [notaMaxima_frac+2]        ; Comparar high words
    ja MaxMin_SetMax
    jb MaxMin_CheckMin
    cmp bx, [notaMaxima_frac]          ; Comparar low words
    ja MaxMin_SetMax

MaxMin_CheckMin:
    ; Comparar con notaMinima
    mov ax, [si]                       ; Parte entera actual
    cmp ax, [notaMinima]
    jb MaxMin_SetMin
    ja MaxMin_Next
    
    ; Si partes enteras son iguales, comparar partes decimales
    mov bx, [si+2]                     ; Parte decimal actual (low word)
    mov dx, [si+4]                     ; Parte decimal actual (high word)
    
    cmp dx, [notaMinima_frac+2]        ; Comparar high words
    jb MaxMin_SetMin
    ja MaxMin_Next
    cmp bx, [notaMinima_frac]          ; Comparar low words
    jb MaxMin_SetMin
    jmp MaxMin_Next

MaxMin_SetMax:
    ; Actualizar máximo (partes entera y decimal)
    mov ax, [si]                       ; Parte entera
    mov [notaMaxima], ax
    
    mov ax, [si+2]                     ; Parte decimal (low word)
    mov dx, [si+4]                     ; Parte decimal (high word)
    mov [notaMaxima_frac], ax
    mov [notaMaxima_frac+2], dx
    jmp MaxMin_CheckMin

MaxMin_SetMin:
    ; Actualizar mínimo (partes entera y decimal)
    mov ax, [si]                       ; Parte entera
    mov [notaMinima], ax
    
    mov ax, [si+2]                     ; Parte decimal (low word)
    mov dx, [si+4]                     ; Parte decimal (high word)
    mov [notaMinima_frac], ax
    mov [notaMinima_frac+2], dx

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
; Resultado en: promedioGeneral/promedio_frac
; ------------------------------------------------------------
Stats_CalcularPromedio PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov cl, [NumEstudiantesRegistrados]
    xor ch, ch
    cmp cx, 0
    je Promedio_End

    ; Guardar numero de estudiantes para la division
    mov bx, cx

    ; Acumuladores separados para parte entera y decimal
    xor ax, ax      ; Suma parte entera
    xor dx, dx      ; Suma parte decimal (32 bits en DI:DX)
    xor di, di
    
    mov si, OFFSET EstudiantesData
    add si, OFFSET_NOTA

Promedio_Loop:
    ; Sumar parte entera
    add ax, [si]
    
    ; Sumar parte decimal (32 bits)
    add dx, [si+2]      ; Low word
    adc di, [si+4]      ; High word
    
    add si, TAM_REGISTRO
    loop Promedio_Loop

    ; Dividir suma de partes enteras por número de estudiantes
    xor dx, dx          ; Limpiar DX para división 16-bit
    div bx              ; AX = parte entera del promedio
    mov [promedioGeneral], ax
    
    ; Para la parte decimal, necesitamos dividir DI:DX por BX
    ; Primero movemos DI:DX a DX:AX para usar nuestra rutina de división
    mov ax, dx
    mov dx, di
    call Div32By16      ; Divide DX:AX por BX, resultado en DX:AX
    
    mov [promedio_frac], ax
    mov [promedio_frac+2], dx

Promedio_End:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Stats_CalcularPromedio ENDP

; ------------------------------------------------------------
; Div32By16: Rutina para dividir un operando de 32 bits (DX:AX)
; entre un divisor de 16 bits (BX) y obtener un cociente de 32 bits.
; Entrada:
;    Dividendo: DX:AX
;    Divisor: BX
; Salida:
;    Cociente en DX:AX
; ------------------------------------------------------------
Div32By16 PROC
    push cx
    push si
    push di
    push bp

    ; Inicializar el cociente (32 bits) en DI:SI y el resto (16 bits) en BP.
    xor di, di      ; Cociente alto = 0
    xor si, si      ; Cociente bajo = 0
    xor bp, bp      ; Resto = 0

    mov cx, 32      ; Número de iteraciones = 32 bits

DivLoop:
    ; Desplazar el cociente a la izquierda para dejar lugar a un bit
    shl si, 1
    rcl di, 1

    ; Desplazar el dividendo (DX:AX) a la izquierda; el bit más
    ; significativo se coloca en CF.
    shl ax, 1
    rcl dx, 1

    ; Desplazar el resto (BP) a la izquierda e incorporar CF en LSB.
    rcl bp, 1

    ; Si el resto es mayor o igual que el divisor, se resta y se
    ; fija el bit menos significativo del cociente.
    cmp bp, bx
    jb NoSub
    sub bp, bx
    inc si          ; Fija el LSB del cociente
NoSub:
    loop DivLoop

    ; Mover el cociente (almacenado en DI:SI) a DX:AX (resultado)
    mov ax, si
    mov dx, di

    pop bp
    pop di
    pop si
    pop cx
    ret
Div32By16 ENDP

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
    ; Comparar parte entera primero
    mov ax, [si]                       ; Parte entera actual
    cmp ax, [NOTA_APROBACION]
    ja Contar_Aprobado                 ; Si parte entera > 70, aprobado
    jb Contar_Reprobado                ; Si parte entera < 70, reprobado
    
    ; Si partes enteras son iguales (70), comparar partes decimales
    mov bx, [si+2]                     ; Parte decimal actual (low word)
    mov dx, [si+4]                     ; Parte decimal actual (high word)
    
    ; Comparar con parte decimal de nota de aprobación (que es 0)
    cmp dx, [NOTA_APROBACION_FRAC+2]   ; Comparar high words
    ja Contar_Aprobado
    jb Contar_Reprobado
    cmp bx, [NOTA_APROBACION_FRAC]     ; Comparar low words
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

; ------------------------------------------------------------
; ImprimirResultados: Imprime todas las estadísticas calculadas
; ------------------------------------------------------------
ImprimirResultados PROC
    push ax
    push dx
    
    ; Imprimir nota máxima
    mov dx, OFFSET msgMaxima
    mov ah, 09h
    int 21h
    
    mov ax, [notaMaxima]
    call ImprimirNumero
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    mov ax, [notaMaxima_frac]
    ; No necesitamos dx ya que los valores son < 99999
    call ImprimirDecimal
    
    ; Imprimir nota mínima
    mov dx, OFFSET msgMinima
    mov ah, 09h
    int 21h
    
    mov ax, [notaMinima]
    call ImprimirNumero
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    mov ax, [notaMinima_frac]
    ; No necesitamos dx ya que los valores son < 99999
    call ImprimirDecimal
    
    ; Imprimir promedio
    mov dx, OFFSET newLine
    mov ah, 09h
    int 21h
    
    mov dx, OFFSET msgPromedio
    mov ah, 09h
    int 21h
    
    mov ax, [promedioGeneral]
    call ImprimirNumero
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    mov ax, [promedio_frac]
    ; No necesitamos dx ya que los valores son < 99999
    call ImprimirDecimal
    
    ; Imprimir aprobados
    mov dx, OFFSET msgAprobados
    mov ah, 09h
    int 21h
    
    mov ax, [aprobados]
    call ImprimirNumero
    
    ; Imprimir reprobados
    mov dx, OFFSET msgReprobados
    mov ah, 09h
    int 21h
    
    mov ax, [reprobados]
    call ImprimirNumero
    
    mov dx, OFFSET newLine
    mov ah, 09h
    int 21h
    
    pop dx
    pop ax
    ret
ImprimirResultados ENDP

; ------------------------------------------------------------
; ImprimirNumero: Imprime un número de 16 bits en decimal
; Entrada: AX = número a imprimir
; ------------------------------------------------------------
ImprimirNumero PROC
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10
    mov cx, 0
    
    ; Si el número es 0, imprimir directamente
    cmp ax, 0
    jne ConvertirLoop
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp ImprimirNum_End
    
ConvertirLoop:
    cmp ax, 0
    je ImprimirDigitos
    
    xor dx, dx
    div bx          ; AX = cociente, DX = resto
    
    add dl, '0'     ; Convertir dígito a ASCII
    push dx         ; Guardar dígito en stack
    inc cx          ; Contar dígitos
    
    jmp ConvertirLoop
    
ImprimirDigitos:
    cmp cx, 0
    je ImprimirNum_End
    
    pop dx          ; Recuperar dígito
    mov ah, 02h     ; Imprimir carácter
    int 21h
    
    dec cx
    jmp ImprimirDigitos
    
ImprimirNum_End:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ImprimirNumero ENDP

; ------------------------------------------------------------
; ImprimirDecimal: Imprime parte decimal (5 dígitos con ceros iniciales)
; Entrada: DX:AX = número decimal a imprimir (máximo 99999)
; ------------------------------------------------------------
ImprimirDecimal PROC
    push ax
    push bx
    push cx
    push dx
    
    ; Solo necesitamos AX ya que el máximo es 99999 (cabe en 16 bits)
    mov bx, 10
    mov cx, 5       ; Exactamente 5 dígitos
    
    ; Stack para almacenar dígitos
ImprimirDec_Loop:
    xor dx, dx      ; Limpiar DX para división
    div bx          ; AX = cociente, DX = resto
    
    add dl, '0'     ; Convertir resto a ASCII
    push dx         ; Guardar dígito
    
    dec cx
    cmp cx, 0
    jg ImprimirDec_Loop
    
    ; Imprimir los 5 dígitos desde el stack
    mov cx, 5
ImprimirDec_Print:
    pop dx
    mov ah, 02h
    int 21h
    dec cx
    cmp cx, 0
    jg ImprimirDec_Print
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ImprimirDecimal ENDP

; ------------------------------------------------------------
; NormalizeGrade: Normaliza una nota si la parte decimal >= 100000
; Entrada: SI apunta a la nota (parte entera primero, luego decimal)
; ------------------------------------------------------------
NormalizeGrade PROC
    push ax
    push dx
    push bx
    
    ; Cargar parte decimal completa (32 bits)
    mov ax, [si+2]      ; Low word de parte decimal
    mov dx, [si+4]      ; High word de parte decimal
    
    ; Comparar con 100000 usando comparación de 32 bits
    ; 100000 = 0x186A0
    cmp dx, 1           ; Comparar high word con 1
    ja Normalize_Adjust ; Si high word > 1, definitivamente >= 100000
    jb Normalize_Done   ; Si high word < 1, definitivamente < 100000
    
    ; Si high word = 1, comparar low word con 0x86A0 (34464)
    cmp ax, 34464       ; 0x86A0 = 34464
    jb Normalize_Done   ; Si < 34464, entonces < 100000
    
Normalize_Adjust:
    ; Ajustar: incrementar parte entera, restar 100000 de parte decimal
    inc WORD PTR [si]   ; Incrementar parte entera
    
    ; Restar 100000 (0x186A0) de DX:AX
    sub ax, 34464       ; Restar low part de 100000
    sbb dx, 1           ; Restar high part de 100000 con borrow
    
    ; Guardar resultado
    mov [si+2], ax      ; Guardar low word ajustado
    mov [si+4], dx      ; Guardar high word ajustado
    
Normalize_Done:
    pop bx
    pop dx
    pop ax
    ret
NormalizeGrade ENDP

END start
