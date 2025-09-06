; ============================================================
org 100h

; ============================================================
;   DATOS DEL MAIN
; ============================================================
.DATA
msg1        db 13,10,' Ingresar calificaciones seleccionado.',13,10,'$'
msg2        db 13,10,' Mostrar estadisticas seleccionado.',13,10,'$'
msg3        db 13,10,' Buscar estudiante por indice seleccionado.',13,10,'$'
msg4        db 13,10,' Ordenar calificaciones seleccionado.',13,10,'$'
msg6        db 13,10,' Mostrar todos los estudiantes seleccionado.',13,10,'$'
pressAny    db 13,10,'digite 5 para salir al menu principal',13,10,'$'

; ============================================================
;   DATOS DEL MENU
; ============================================================
menuTitle   db 13,10, '=== MENU PRINCIPAL ===',13,10,'$'
Calificaciones db '1) Ingresar calificaciones.',13,10,'$'
Estadisticas   db '2) Mostrar estadisticas.',13,10,'$'
Buscar         db '3) Buscar estudiante por indice.',13,10,'$'
Ordenar        db '4) Ordenar calificaciones.',13,10,'$'
Salir          db '5) Salir.',13,10,'$'
msgInvalido    db 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'
msgSalida    db 13,10,'Gracias por usar Registro CE ',13,10,'$'
msgPrompt      db 'Seleccione una opcion (1-5) y presione Enter: $'           
              
; ============================================================
;   DATOS DE LA OPCION1: INGRESAR CALIFICACIONES
; ============================================================             
; Implementacion de tablas de almacenamiento de datos de estudiantes y variables relacionadas
; Almacenamiento para 15 estudiantes maximo - 4 tablas separadas
FirstNameTable    db 315 dup(' ')                 ; 15 estudiantes * 21 bytes cada uno (20 chars + '$')
LastNameTable1    db 315 dup(' ')                 ; 15 estudiantes * 21 bytes cada uno (20 chars + '$')  
LastNameTable2    db 315 dup(' ')                 ; 15 estudiantes * 21 bytes cada unoh (20 chars + '$')
NotesTable        db 75 dup(' ')                  ; 15 estudiantes * 5 bytes cada uno (4 chars + '$')

studentCount      db 0                             ; Contador de estudiantes
inputBuffer       db 100 dup(0)                   ; (tengo que investigar esta linea)
msgStudentPrompt  db 13,10,'Por favor ingrese su estudiante o digite 9 para salir al menu principal',13,10,'$'
msgMaxStudents    db 13,10,'[ERROR] Maximo 15 estudiantes permitidos.',13,10,'$'
msgInvalidFormat  db 13,10,'[ERROR] Formato invalido. Use: Nombre Apellido1 Apellido2 Nota',13,10,'$'
msgNoStudents db 13,10,'No hay estudiantes registrados.',13,10,'$'

; ============================================================================
;   DATOS DE LA OPCCION2 Y OPCCION4: PARA LAS ESTADISTICAS Y EL ORDENAMIENTO
; ============================================================================

; --- DEFINICION DE LA ESTRUCTURA DE DATOS ---
; La estructura se alinea con la definida en main.asm y consiste en:
; 1. Registro de Estudiante (70 bytes totales):
;    - Nombre       (21 bytes): Cadena terminada en $, padding con 0s
;    - Apellido1    (21 bytes): Cadena terminada en $, padding con 0s
;    - Apellido2    (21 bytes): Cadena terminada en $, padding con 0s
;    - Nota         (7 bytes):
;      * Parte entera  (2 bytes): 0-100
;      * Parte decimal (4 bytes): 0-99999
;      * Padding       (1 byte)
; 
; NOTA: Todas las cadenas usan $ como terminador y se rellenan con 0s
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
NumEstudiantesRegistrados DB 0 ;Si se usan los precargados, usar 5

    EstudiantesData:DB MAX_ESTUDIANTES * TAM_REGISTRO DUP(0)
    ; Estudiante 1: Nota 85.12345
    ;DB 'Juan$'             ; 5 bytes
    ;DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    ;DB 'Perez$'            ; 6 bytes  
    ;DB 15 DUP(0)           ; 15 bytes -> Total: 21 bytes
    ;DB 'Lopez$'            ; 6 bytes
    ;DB 15 DUP(0)           ; 15 bytes -> Total: 21 bytes
    ;DW 85                  ; 2 bytes - Parte entera
    ;DD 12345               ; 4 bytes - Parte decimal
    ;DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

    ; Estudiante 2: Nota 69.99999 (Reprobado)
    ;DB 'Maria$'            ; 6 bytes
    ;DB 15 DUP(0)           ; 15 bytes -> Total: 21 bytes
    ;DB 'Gomez$'            ; 6 bytes
    ;DB 15 DUP(0)           ; 15 bytes -> Total: 21 bytes
    ;DB 'Ruiz$'             ; 5 bytes
    ;DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    ;DW 69                  ; 2 bytes - Parte entera
    ;DD 99999               ; 4 bytes - Parte decimal
    ;DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

    ; Estudiante 3: Nota 95.00000 (Maxima)
    ;DB 'Carlos$'           ; 7 bytes
    ;DB 14 DUP(0)           ; 14 bytes -> Total: 21 bytes
    ;DB 'Sanchez$'          ; 8 bytes
    ;DB 13 DUP(0)           ; 13 bytes -> Total: 21 bytes
    ;DB 'Diaz$'             ; 5 bytes
    ;DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    ;DW 95                  ; 2 bytes - Parte entera
    ;DD 0                   ; 4 bytes - Parte decimal
    ;DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

    ; Estudiante 4: Nota 50.50000 (Minima)
    ;DB 'Ana$'              ; 4 bytes
    ;DB 17 DUP(0)           ; 17 bytes -> Total: 21 bytes
    ;DB 'Martinez$'         ; 9 bytes
    ;DB 12 DUP(0)           ; 12 bytes -> Total: 21 bytes
    ;DB 'Soto$'             ; 5 bytes
    ;DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    ;DW 50                  ; 2 bytes - Parte entera
    ;DD 50000               ; 4 bytes - Parte decimal
    ;DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

    ; Estudiante 5: Nota 70.00000 (Aprobado)
    ;DB 'Luis$'             ; 5 bytes
    ;DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    ;DB 'Hernandez$'        ; 10 bytes
    ;DB 11 DUP(0)           ; 11 bytes -> Total: 21 bytes
    ;DB 'Vega$'             ; 5 bytes
    ;DB 16 DUP(0)           ; 16 bytes -> Total: 21 bytes
    ;DW 70                  ; 2 bytes - Parte entera
    ;DD 0                   ; 4 bytes - Parte decimal
    ;DB 0                   ; 1 byte - Padding -> Total registro: 70 bytes

; --- VARIABLES PARA ALMACENAR RESULTADOS ESTADISTICOS ---
; Estructura de almacenamiento para notas:
; - Parte entera (DW): Rango 0-100
; - Parte decimal (DD): Rango 0-99999

notaMaxima      DW 0    ; Parte entera de la nota mas alta
notaMaxima_frac DD 0    ; Parte decimal de la nota mas alta
notaMinima      DW 0    ; Parte entera de la nota mas baja
notaMinima_frac DD 0    ; Parte decimal de la nota mas baja
promedioGeneral DW 0    ; Parte entera del promedio
promedio_frac   DD 0    ; Parte decimal del promedio
aprobados       DW 0    ; Contador de estudiantes aprobados (nota >= 70)
reprobados      DW 0    ; Contador de estudiantes reprobados (nota < 70)

; --- Mensajes para la salida ---
msgMaxima       DB 13, 10, 'Nota Maxima: $'
msgMinima       DB 13, 10, 'Nota Minima: $'
msgPromedio     DB 13, 10, 'Promedio: $'
msgAprobados    DB 13, 10, 'Aprobados: $'
msgPorcAprobados DB ' (', '%)', '$'
msgReprobados   DB 13, 10, 'Reprobados: $'
msgPorcReprobados DB ' (', '%)', '$'
newLine         DB 13, 10, '$'

; --- Mensajes para ordenamiento ---
msgAscending    DB 13, 10, 'Estudiantes (orden: ascendente):', 13, 10, '$'
msgDescending   DB 13, 10, 'Estudiantes (orden: descendente):', 13, 10, '$'
msgNombre       DB 'Nombre: $'
msgApellido1    DB ', Apellido1: $'
msgApellido2    DB ', Apellido2: $'
msgNota         DB ', Nota: $'
msgSortOK       DB 13, 10, 'Validacion: Ordenamiento correcto.', 13, 10, '$'
msgSortError    DB 13, 10, 'Error: Ordenamiento incorrecto detectado.', 13, 10, '$'

; --- VARIABLES TEMPORALES PARA CALCULOS ---
temp_decimal    DD 0            ; Almacenamiento temporal para calcular decimales

; --- VARIABLES PARA EL ALGORITMO SELECTION SORT ---
; Variables de control y estado del ordenamiento:
sort_order      DB 0            ; Direccion del ordenamiento:
                               ; 0 = ascendente (menor a mayor)
                               ; 1 = descendente (mayor a menor)

; Buffers y variables temporales para el proceso de ordenamiento:
temp_buffer     DW 35 DUP(0)    ; Buffer para intercambio de registros
                               ; 70 bytes = 35 palabras para almacenar
                               ; temporalmente un registro completo

; Índices y contadores para Selection Sort:
temp_i          DW 0            ; indice del elemento actual (bucle externo)
temp_j          DW 0            ; indice de comparación (bucle interno)
temp_min_idx    DW 0            ; indice del elemento minimo/maximo encontrado

; --- CONSTANTES DEL SISTEMA ---
NOTA_APROBACION     DW 70       ; Nota mínima para aprobar (parte entera)
NOTA_APROBACION_FRAC DD 0       ; Parte decimal de la nota de aprobacion
DIVISOR_FLOAT       DW 10000    ; Divisor para calculos decimales (10^4)

; ============================================================
;   NOTAS SOBRE MANEJO DE NUMEROS DECIMALES
; ============================================================
; El sistema maneja números decimales de la siguiente forma:
; 1. La parte entera se almacena en un DW (0-100)
; 2. La parte decimal se almacena en un DD (0-99999)
; 3. Para mostrar decimales, se usan 5 dígitos después del punto
; 4. Ejemplo: 85.12345 se almacena como:
;    - Parte entera: 85 (DW)
;    - Parte decimal: 12345 (DD)
; ============================================================

; ============================================================
;   DATOS DE LA OPCCION3: BUSCAR INDICE
; ============================================================

msgIngIndice   db 13,10,'Ingrese el indice del estudiante (1-15) y presione Enter: $'
msgFueraRango  db 13,10,'[ERROR] Indice fuera de rango.',13,10,'$'
msgResultado   db 13,10,'Estudiante: $'
msgNotaI       db 13,10,'Nota: $'
estudiantes    db 0
msgListaVacia db 13,10,'Lista vacia $',13,10,'$'
space         db ' $'
dot           db '. $'

; ============================================================
;   CODIGO PRINCIPAL (MAIN)
; ============================================================
.CODE

start:
    mov  ax, @DATA
    mov  ds, ax

MainLoop:
    call Menu_Print
    call MenuLeerSeleccion

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
    ; Se implementa la funcionalidad de acceder a estudiante
    call Ingresar_Calificaciones
    jmp  MainLoop

Opt2:
    mov  dx, OFFSET msg2 ;Mostrar estadisticas
    mov  ah, 09h
    int  21h
    call Lista_EsVacia
    cmp  al, 1            ; AL == 1??
    je   MostrarListaVacia ;Si sii saltar a MostrarListaVacia
    ; Ejecutar cálculos estadisticos
    call DebugEstudiantes       ; Nueva funcion de debug
    call DebugDirecto           ; Acceso directo a cada nota
    call Stats_CalcularMaxMin   ; Calcular maximo y minimo
    call Stats_CalcularPromedio ; Calcular promedio
    call Stats_ContarAprobadosReprobados ; Contar aprobados y reprobados
    call ImprimirResultados     ; Imprimir resultados de estadísticas
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
    call Lista_EsVacia
    cmp  al, 1            ; AL = 1 (vacia)??
    je   MostrarListaVacia ; Si sii saltar a MostrarListaVacia
     
    mov al, 0           ; 0 = ascendente
    call OrdenarYMostrar
    mov dx, OFFSET newLine
    mov ah, 09h
    int 21h
    ; Ordenamiento descendente
    mov dx, OFFSET msgDescending ; Mensaje para orden descendente
    mov ah, 09h
    int 21h
    mov al, 1           ; 1 = descendente
    call OrdenarYMostrar
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

;Funcion de salida para el menu (5 + enter)
EsperarAlCinco:
    call LeerConEnter
    
    cmp  al, '5'           ; validacion de entrada
    je   RegresarAlMenu
    jmp  EsperarAlCinco

RegresarAlMenu:
    jmp  MainLoop

ExitProgram:
    mov  ah, 4Ch
    mov  al, 00h
    int  21h


; ---------------------------------------------------------
; Funcion: Lista_EsVacia
; Entrada : variable NumEstudiantesRegistrados (DB)
; Salida  : AL = 1 si está vacía
;           AL = 0 si no lo está
; ---------------------------------------------------------
Lista_EsVacia PROC
    mov al, NumEstudiantesRegistrados  ; cargar número de estudiantes
    cmp al, 0                          ; comparar con 0
    jne TieneDatos                     ; si no es 0, hay datos
    mov al, 1                          ; vacia entonces AL = 1
    ret
TieneDatos:
    mov al, 0                          ; no vacia entonces AL = 0
    ret
Lista_EsVacia ENDP

; ---------------------------------------------------------
; Funcion: MostrarListaVacia
; Muestra mensaje de lista vacia y salta a WaitAndReturn
; ---------------------------------------------------------
MostrarListaVacia:
    mov  dx, OFFSET msgListaVacia ; Mostrar mensaje de lista vacia
    mov  ah, 09h
    int  21h
    jmp  WaitAndReturn    ; Saltar a WaitAndReturn


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


    mov  dx, OFFSET msgPrompt
    mov  ah, 09h
    int  21h

    pop  dx
    pop  ax
    ret
Menu_Print ENDP

;validar entrada con la tecla Enter
MenuLeerSeleccion PROC NEAR
    push dx
ReadLoop:                  ;Loop, se espera a la letra enter para validar datos
    call LeerConEnter

    cmp  al, '1'
    jb   Invalid
    cmp  al, '6'
    ja   Invalid

    sub  al, '0'           ; convierte '1'..'6' en 1..6
    xor  ah, ah            ; AX = 1..6
    pop  dx
    ret                    ; devuelve con AL=opcion
Invalid:
    mov  dx, OFFSET msgInvalido
    mov  ah, 09h
    int  21h

    jmp  ReadLoop
MenuLeerSeleccion ENDP


LeerConEnter PROC NEAR
    push bx
    push dx
    
    mov  ah, 01h           
    int  21h               
    mov  bl, al            
    
EsperarEnter:
    mov  ah, 01h           ; Lectura y validacion de enter
    int  21h
    cmp  al, 13            
    jne  EsperarEnter
    
    mov  al, bl            ; Restauracion del caracter original
    
    pop  dx
    pop  bx
    ret          
    
LeerConEnter ENDP

; ============================================================
;   LEE UNA LINEA COMPLETA DE ENTRADA
; ============================================================
LeerLineaDeEntrada PROC NEAR
    push bx
    push cx
    push dx
    push si
    
    mov si, OFFSET inputBuffer
    mov cx, 0                    ; Contador de caracteres
    
LeerChar:
    mov ah, 01h                  ; Leer caracter con eco
    int 21h
    
    cmp al, 13                   ; Verificar Enter
    je FinDeEntrada
    cmp al, 8                    ; Verificar backspace
    je ManejarRetroceso
    
    cmp cx, 99                   ; Limite del buffer
    jae LeerChar
    
    mov [si], al                 ; Almacenar caracter
    inc si
    inc cx
    jmp LeerChar

ManejarRetroceso:
    cmp cx, 0                    ; Verificar si esta al inicio
    je LeerChar
    dec si
    dec cx
    mov byte ptr [si], 0         ; Limpiar caracter
    
    ; Tambien borrar de la pantalla
    mov dl, 8                    ; Backspace
    mov ah, 02h
    int 21h
    mov dl, ' '                  ; Espacio
    int 21h
    mov dl, 8                    ; Backspace de nuevo
    int 21h
    
    jmp LeerChar

FinDeEntrada:
    mov byte ptr [si], 0         ; Terminar con null
    
    ; Imprimir nueva linea despues de la entrada
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    ret
LeerLineaDeEntrada ENDP

; ============================================================
;   ANALIZAR Y ALMACENAR DATOS DE ESTUDIANTES
; ============================================================
Analizar_Almacenar_EstDatos PROC NEAR
    push bx
    push cx
    push dx
    push si
    push di
    
    mov si, OFFSET inputBuffer
    
    ; Calcular posicion en EstudiantesData
    mov al, [NumEstudiantesRegistrados]
    xor ah, ah
    mov bx, TAM_REGISTRO
    mul bx
    mov di, OFFSET EstudiantesData
    add di, ax
    
    ; Analizar Nombre (21 bytes)
    call AnalizarFieldAEstructura
    cmp al, 0
    je ParseError
    
    ; Rellenar los bytes restantes con 0
    mov cx, TAM_NOMBRE
    sub cx, bx
    jbe NoPad1
PadLoop1:
    mov byte ptr [di], 0
    inc di
    loop PadLoop1
NoPad1:
    
    ; Analizar Apellido 1 (21 bytes)
    call AnalizarFieldAEstructura
    cmp al, 0
    je ParseError
    
    mov cx, TAM_APELLIDO1
    sub cx, bx
    jbe NoPad2
PadLoop2:
    mov byte ptr [di], 0
    inc di
    loop PadLoop2
NoPad2:
    
    ; Analizar Apellido 2 (21 bytes)
    call AnalizarFieldAEstructura
    cmp al, 0
    je ParseError
    
    mov cx, TAM_APELLIDO2
    sub cx, bx
    jbe NoPad3
PadLoop3:
    mov byte ptr [di], 0
    inc di
    loop PadLoop3
NoPad3:
    
    ; Parse Grade (partes enteras y decimales)
    call ParseGrade
    cmp al, 0
    je ParseError
    
    mov al, 1                    ; Exito
    jmp AnalizisCompleto

ParseError:
    mov dx, OFFSET msgInvalidFormat
    mov ah, 09h
    int 21h
    mov al, 0                    ; Fracaso

AnalizisCompleto:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
Analizar_Almacenar_EstDatos ENDP

; ============================================================
;   Analizar el arreglo y almacenar (Nombre/Apellido)
;   Aceptar letras del alfabeto ASCCI A-Z / a-z
; ============================================================
AnalizarFieldAEstructura PROC NEAR
    push cx
    
    mov cx, 0                    ; contador de caracteres
    
    ; Saltar espacios iniciales
SaltarEspacios:
    mov al, [si]
    cmp al, 0                    ; Fin de la entrada
    je FieldError
    cmp al, ' '
    jne StartField
    inc si
    jmp SaltarEspacios
    
StartField:
    ; Copiar caracteres hasta encontrar un espacio o el final
CopyChar:
    mov al, [si]
    cmp al, 0                    ; Fin de la entrada
    je EndField
    cmp al, ' '                  ; Delimitador de espacio
    je EndField
    cmp al, '.'                  ; Punto (no valido en nombres)
    je FieldError

    ; Validacion: permitir solo letras A-Z / a-z
    cmp al, 'A'
    jb FieldError
    cmp al, 'Z'
    jbe AlmacenarChar
    cmp al, 'a'
    jb FieldError
    cmp al, 'z'
    jbe AlmacenarChar

    ; Si no esta en rango entonces error
    jmp FieldError

AlmacenarChar:
    mov [di], al                 ; almacenar caracter
    inc si
    inc di
    inc cx
    cmp cx, 20                   ; Max length 
    jb CopyChar
    
EndField:
    mov byte ptr [di], '$'       
    inc di
    inc cx
    mov bx, cx                   ; Retornar length
    cmp cx, 0                    ; Comprueba si tenemos caracteres
    je FieldError
    
    mov al, 1                    ; exito
    jmp FieldDone

FieldError:
    mov al, 0                    ; Error

FieldDone:
    pop cx
    ret
AnalizarFieldAEstructura ENDP

; ============================================================
;   Parse grade (partes enteras y decimales)
;   - Si no hay decimales, se asignan ceros
; ============================================================
ParseGrade PROC NEAR
    push bx
    push cx
    push dx
    push di
    
    ; Saltar a la parte de calificacion
GradeSkip:
    mov al, [si]
    cmp al, 0
    je GradeError
    cmp al, ' '
    jne InicioCalificacion
    inc si
    jmp GradeSkip
    
InicioCalificacion:
    ; Analizar la parte entera
    xor bx, bx                   ; Acumulador de enteros
    xor cx, cx                   ; Acumulador de decimales
    xor dx, dx                   ; Contador de digitos decimales
    
AnalizarEntero:
    mov al, [si]
    cmp al, 0
    je GradeEnd
    cmp al, '.'
    je ParseDecimal
    cmp al, ' '
    je GradeEnd
    
    ; Convertir digitos a numero
    sub al, '0'
    jb GradeError
    cmp al, 9
    ja GradeError
    
    mov ah, 0
    xchg ax, bx
    mov dx, 10
    mul dx
    add bx, ax
    inc si
    jmp AnalizarEntero
    
ParseDecimal:
    inc si                       ; Saltar el punto "."
    xor dx, dx                   ; Reinicio del contador de decimales
    
ParseDecimalLoop:
    mov al, [si]
    cmp al, 0
    je GradeEnd
    cmp al, ' '
    je GradeEnd
    
    ; Convertir dígito
    sub al, '0'
    jb GradeError
    cmp al, 9
    ja GradeError
    
    mov ah, 0
    push dx
    push ax
    mov ax, cx
    mov dx, 10
    mul dx
    mov cx, ax
    pop ax
    add cx, ax
    pop dx
    inc dx
    inc si
    cmp dx, 5                    ; Max 5 digitos admitidos en decimales
    jb ParseDecimalLoop
    
GradeEnd:
    ; Guardar parte entera (2 bytes)
    mov [di], bx
    add di, 2
    
    ; Si no se ingresa decimal se llena de ceros
    cmp dx, 0
    jne TieneDecimales

    mov ax, 0
    jmp AlmacenarDecimales

TieneDecimales:
    mov ax, cx
    cmp dx, 5                    
    je AlmacenarDecimales

    ; Escalar a 5 dígitos
    mov bx, 10
ScaleLoop:
    cmp dx, 5
    jae AlmacenarDecimales
    mul bx
    inc dx
    jmp ScaleLoop
    
AlmacenarDecimales:
    mov [di], ax                 ; Guardar parte decimal (4 bytes)
    mov word ptr [di+2], 0       
    mov al, 1                    ; exito
    jmp GradeDone

GradeError:
    mov al, 0                    ; Error

GradeDone:
    pop di
    pop dx
    pop cx
    pop bx
    ret
ParseGrade ENDP

; ============================================================
;   MODULO: INGRESAR CALIFICACIONES 
; ============================================================
Ingresar_Calificaciones PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di

InputLoop:
    ; Verifica si ya se registraron 15 estudiantes
    mov al, [NumEstudiantesRegistrados]
    cmp al, MAX_ESTUDIANTES
    jae MaxStudentsReached
    
    mov dx, OFFSET msgStudentPrompt
    mov ah, 09h
    int 21h
    
    ; Leer la linea de entrada
    call LeerLineaDeEntrada
    
    ; verifica si el usuario quiere volver al menu (con 9)
    mov si, OFFSET inputBuffer
    mov al, [si]
    cmp al, '9'          ; 
    je ExitToMenu        ; SALIR DIRECTAMENTE AL MENU
    
    ; Parse and store the input in EstudiantesData format
    call Analizar_Almacenar_EstDatos
    cmp al, 0                    ; Comprobar si el analisis fue exitoso
    je InputLoop                 ; Si falla, intentarlo de nuevo
                                                                                
    ; Increment student count
    inc [NumEstudiantesRegistrados]
    jmp InputLoop

MaxStudentsReached:
    mov dx, OFFSET msgMaxStudents
    mov ah, 09h
    int 21h

ExitToMenu:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Ingresar_Calificaciones ENDP


; ============================================================
;   MODULO: BUSCAR INDICE
; ============================================================

Buscar_Estudiante PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si

    ; --- Verificar si lista vacia ---
    mov al, [NumEstudiantesRegistrados]  ; Usar el contador de estudiantes
    cmp al, 0                            ; Si es 0, esta vacia
    je ListaVacia

    ; --- Pedir indice ---
    mov dx, OFFSET msgIngIndice
    mov ah, 09h
    int 21h

    ; Leer indice (asumiendo que ReadWithEnter devuelve un dígito en AL)
    call LeerConEnter
    sub al, '0'        ; Convertir de ASCII a valor numerico
    mov bl, al         ; Guardar indice ingresado

    ; Validar rango (1 a numero real de estudiantes)
    cmp bl, 1
    jb FueraRango
    mov al, [NumEstudiantesRegistrados]  ; Usar contador real
    xor ah, ah
    cmp bl, al          ; Comparar con el numero real
    ja FueraRango
    

    ; Calcular desplazamiento al registro del estudiante
    dec bl             ; indice base 0
    mov ax, 70         ; Tamanno de cada registro (70 bytes)
    mul bl             ; AX = indice * 70
    mov si, ax         ; Guardar desplazamiento en SI
    mov bx, OFFSET EstudiantesData
    add bx, si         ; BX apunta al inicio del registro del estudiante

    ; --- Mostrar mensaje de resultado ---
    mov dx, OFFSET msgResultado
    mov ah, 09h
    int 21h

    ; --- Mostrar nombre (21 bytes, hasta '$') ---
MostrarNombre:
    mov al, [bx]
    cmp al, '$'
    je DespuesNombre
    mov dl, al
    mov ah, 02h
    int 21h
    inc bx
    jmp MostrarNombre

DespuesNombre:
    mov dx, OFFSET space ; Espacio entre nombre y apellido
    mov ah, 09h
    int 21h
    mov bx, OFFSET EstudiantesData
    add bx, si         ; Restaurar BX al inicio del registro
    add bx, 21         ; Saltar al inicio del apellido paterno

    ; --- Mostrar apellido paterno (21 bytes, hasta '$') ---
MostrarApellidoP:
    mov al, [bx]
    cmp al, '$'
    je DespuesApellidoP
    mov dl, al
    mov ah, 02h
    int 21h
    inc bx
    jmp MostrarApellidoP

DespuesApellidoP:
    mov dx, OFFSET space
    mov ah, 09h
    int 21h
    mov bx, OFFSET EstudiantesData
    add bx, si         ; Restaurar BX al inicio del registro
    add bx, 42         ; Saltar al inicio del apellido materno

    ; --- Mostrar apellido materno (21 bytes, hasta '$') ---
MostrarApellidoM:
    mov al, [bx]
    cmp al, '$'
    je DespuesApellidoM
    mov dl, al
    mov ah, 02h
    int 21h
    inc bx
    jmp MostrarApellidoM

DespuesApellidoM:
    mov dx, OFFSET newline
    mov ah, 09h
    int 21h
    mov bx, OFFSET EstudiantesData
    add bx, si         ; Restaurar BX al inicio del registro
    add bx, 63         ; Saltar al inicio de la nota (parte entera)

    ; --- Mostrar mensaje de nota ---
    mov dx, OFFSET msgNotaI
    mov ah, 09h
    int 21h

    ; --- Mostrar nota (parte entera, DW) ---
    mov ax, [bx]       ; Cargar parte entera (2 bytes)
    call PrintNumber   ; Convertir y mostrar número

    ; --- Mostrar punto decimal ---
    mov dx, OFFSET dot
    mov ah, 09h
    int 21h

    ; --- Mostrar nota (parte decimal, DD) ---
    add bx, 2          ; Saltar parte entera
    mov ax, [bx]       ; Cargar los 2 bytes bajos de la parte decimal
    call ImprimirDecimal ; Convertir y mostrar parte decimal

    jmp Fin

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

; --- Funcion auxiliar para imprimir un numero entero (AX) ---
PrintNumber PROC NEAR
    push ax
    push bx
    push cx
    push dx

    mov cx, 0          ; Contador de digitos
    mov bx, 10         ; Base 10

    ; Manejar caso especial: AX = 0
    cmp ax, 0
    jne DivideLoop
    mov dl, '0'        ; Si AX es 0, imprimir '0'
    mov ah, 02h
    int 21h
    jmp EndPrintNumber

DivideLoop:
    xor dx, dx         ; Limpiar DX para division
    div bx             ; AX = AX / 10, DX = resto
    add dl, '0'        ; Convertir resto a ASCII
    push dx            ; Guardar dígito
    inc cx             ; Incrementar contador
    cmp ax, 0          ; Quedan mas digitos??
    jne DivideLoop

PrintLoop:
    pop dx             ; Recuperar digito
    mov ah, 02h
    int 21h
    loop PrintLoop

EndPrintNumber:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintNumber ENDP



; ============================================================
;   MODULO: ESTADISTICAS
; ============================================================

; ============================================================
;   SUBRUTINAS DE CALCULO ESTADISTICO
; ============================================================
; Este modulo contiene las siguientes rutinas principales:
;
; 1. Stats_CalcularMaxMin:
;    - Encuentra las notas mas alta y baja
;    - Maneja tanto parte entera como decimal
;
; 2. Stats_CalcularPromedio:
;    - Calcula el promedio de todas las notas
;    - Maneja división con precisión decimal
;
; 3. Stats_ContarAprobadosReprobados:
;    - Cuenta estudiantes aprobados (>= 70.0)
;    - Cuenta estudiantes reprobados (< 70.0)
;
; 4. Rutinas de soporte:
;    - ImprimirResultados: Muestra estadísticas
;    - Div32By16: Division de 32 bits
;    - NormalizeGrade: Normalizacion de notas
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
    add si, 63      
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
; Stats_CalcularMaxMin: Calcula nota maxima y minima
; ------------------------------------------------------------
; DESCRIPCION:
;     Analiza todos los registros de estudiantes para encontrar
;     las notas mas alta y más baja, considerando tanto la parte
;     entera como la decimal de cada nota.
;
; SALIDA:
;     notaMaxima/notaMaxima_frac: Nota mas alta encontrada
;     notaMinima/notaMinima_frac: Nota mas baja encontrada
;
; ALGORITMO:
;     1. Inicializa max/min con la primera nota
;     2. Recorre todos los registros restantes:
;        - Compara parte entera
;        - Si son iguales, compara parte decimal
;        - Actualiza maximo/minimo segun corresponda
;
; MANEJO DE CASOS ESPECIALES:
;     - Si no hay estudiantes, mantiene valores en 0
;     - Si hay un solo estudiante, ese valor es max y min
;
; PRESERVA: todos los registros
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
    ; Actualizar maximo (partes entera y decimal)
    mov ax, [si]                       ; Parte entera
    mov [notaMaxima], ax
    
    mov ax, [si+2]                     ; Parte decimal (low word)
    mov dx, [si+4]                     ; Parte decimal (high word)
    mov [notaMaxima_frac], ax
    mov [notaMaxima_frac+2], dx
    jmp MaxMin_CheckMin

MaxMin_SetMin:
    ; Actualizar minimo (partes entera y decimal)
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
; Stats_CalcularPromedio: Calcula el promedio general
; ------------------------------------------------------------
; DESCRIPCION:
;     Calcula el promedio de las notas de todos los estudiantes,
;     manejando precisión decimal y evitando desbordamiento.
;
; SALIDA:
;     promedioGeneral: Parte entera del promedio
;     promedio_frac: Parte decimal del promedio (5 dígitos)
;
; ALGORITMO:
;     1. Suma separada de partes enteras y decimales
;     2. Manejo de 32 bits para parte decimal para evitar
;        pérdida de precision
;     3. División del total entre número de estudiantes
;     4. Normalización del resultado si es necesario
;
; PRECISION:
;     - Mantiene 5 dígitos decimales de precision
;     - Usa division de 32 bits para máxima precision
;
; MANEJO DE CASOS ESPECIALES:
;     - Si no hay estudiantes, retorna 0
;     - Maneja correctamente el redondeo
;
; PRESERVA: todos los registros
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
    ; Primero movemos DI:DX a DX:AX para usar nuestra rutina de division
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
; Div32By16: Division de precisión extendida
; ------------------------------------------------------------
; DESCRIPCIÓN:
;     Implementa division de numeros de 32 bits entre 16 bits,
;     proporcionando resultado de 32 bits. Esta rutina es critica
;     para mantener la precision en calculos decimales.
;
; ENTRADA:
;     DX:AX - Dividendo de 32 bits
;     BX    - Divisor de 16 bits
;
; SALIDA:
;     DX:AX - Cociente de 32 bits
;
; ALGORITMO:
;     Implementa división larga bit a bit:
;     1. Inicializa registros de trabajo
;     2. Realiza 32 iteraciones:
;        - Desplaza dividendo y cociente
;        - Compara y resta cuando es posible
;        - Construye resultado bit a bit
;
; PRECAUCIONES:
;     - No verifica división por cero
;     - Asume que el resultado cabe en 32 bits
;
; PRESERVA: todos los registros excepto DX:AX
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

    mov cx, 32      ; Numero de iteraciones = 32 bits

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
; Stats_ContarAprobadosReprobados: Cuenta aprobados y reprobados
; ------------------------------------------------------------
; DESCRIPCIÓN:
;     Analiza las notas de todos los estudiantes y los clasifica
;     como aprobados o reprobados según la nota de aprobación.
;
; CRITERIOS:
;     Aprobado: nota >= 70.00000
;     Reprobado: nota < 70.00000
;
; SALIDA:
;     aprobados: Numero de estudiantes aprobados
;     reprobados: Numero de estudiantes reprobados
;
; ALGORITMO:
;     1. Inicializa contadores en 0
;     2. Para cada estudiante:
;        - Compara parte entera con 70
;        - Si es igual, compara parte decimal
;        - Incrementa contador correspondiente
;
; MANEJO DE CASOS ESPECIALES:
;     - Nota exactamente 70.00000 se considera aprobado
;     - Si no hay estudiantes, ambos contadores quedan en 0
;
; PRESERVA: todos los registros
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
    
    ; Imprimir nota maxima
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
    
    ; Imprimir aprobados y su porcentaje
    mov dx, OFFSET msgAprobados
    mov ah, 09h
    int 21h
    
    mov ax, [aprobados]
    call ImprimirNumero

    ; Calcular porcentaje aprobados
    mov al, [NumEstudiantesRegistrados]
    xor ah, ah          ; AX = total estudiantes
    cmp ax, 0          ; Evitar división por cero
    je SinPorcentajes
    
    mov bx, ax         ; BX = total estudiantes
    mov ax, [aprobados]
    mov cx, 100        ; Multiplicar por 100 para porcentaje
    mul cx             ; DX:AX = aprobados * 100
    div bx             ; AX = (aprobados * 100) / total

    push ax            ; Guardar resultado
    mov dx, OFFSET msgPorcAprobados
    mov ah, 09h
    int 21h
    pop ax
    call ImprimirNumero
    
    ; Imprimir reprobados y su porcentaje
    mov dx, OFFSET msgReprobados
    mov ah, 09h
    int 21h
    
    mov ax, [reprobados]
    call ImprimirNumero

    ; Calcular porcentaje reprobados
    mov al, [NumEstudiantesRegistrados]
    xor ah, ah
    mov bx, ax
    mov ax, [reprobados]
    mov cx, 100
    mul cx
    div bx
    
    push ax
    mov dx, OFFSET msgPorcReprobados
    mov ah, 09h
    int 21h
    pop ax
    call ImprimirNumero

SinPorcentajes:    
    mov dx, OFFSET newLine
    mov ah, 09h
    int 21h
    
    pop dx
    pop ax
    ret
ImprimirResultados ENDP

; ------------------------------------------------------------
; ImprimirNumero: Imprime un número de 16 bits en decimal
; Entrada: AX = numero a imprimir
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
    
    add dl, '0'     ; Convertir digito a ASCII
    push dx         ; Guardar digito en stack
    inc cx          ; Contar digitos
    
    jmp ConvertirLoop
    
ImprimirDigitos:
    cmp cx, 0
    je ImprimirNum_End
    
    pop dx          ; Recuperar digito
    mov ah, 02h     ; Imprimir caracter
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
; ImprimirDecimal: Imprime parte decimal (5 digitos con ceros iniciales)
; Entrada: DX:AX = numero decimal a imprimir (maximo 99999)
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
    
    ; Imprimir los 5 digitos desde el stack
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
; NormalizarCalificacion: Normalizacion de notas
; ------------------------------------------------------------
NormalizarCalificacion PROC
    push ax
    push dx
    push bx
    
    ; Cargar parte decimal completa (32 bits)
    mov ax, [si+2]      ; Low word de parte decimal
    mov dx, [si+4]      ; High word de parte decimal
    
    ; Comparar con 100000 usando comparación de 32 bits
    ; 100000 = 0x186A0
    cmp dx, 1           ; Comparar high word con 1
    ja AjustarNormalizacion
    jb NormalizacionCompleta
    
    ; Si high word = 1, comparar low word con 0x86A0 (34464)
    cmp ax, 34464       ; 0x86A0 = 34464
    jb NormalizacionCompleta
    
AjustarNormalizacion:
    ; Ajustar: incrementar parte entera, restar 100000 de parte decimal
    inc WORD PTR [si]   ; Incrementar parte entera
    
    ; Restar 100000 (0x186A0) de DX:AX
    sub ax, 34464       ; Restar low part de 100000
    sbb dx, 1           ; Restar high part de 100000 con borrow
    
    ; Guardar resultado
    mov [si+2], ax      ; Guardar low word ajustado
    mov [si+4], dx      ; Guardar high word ajustado
    
NormalizacionCompleta:
    pop bx
    pop dx
    pop ax
    ret
NormalizarCalificacion ENDP

; ============================================================
;   MODULO: ORDENAR ESTUDIANTES
; ============================================================

; ============================================================
;   SUBRUTINAS DE ORDENAMIENTO - SELECTION SORT
; ============================================================
; Implementación del algoritmo Selection Sort para ordenar
; registros de estudiantes por nota.
;
; COMPONENTES PRINCIPALES:
;
; 1. SelectionSort:
;    - Implementa el algoritmo principal
;    - Maneja registros de 70 bytes
;    - Soporta orden ascendente y descendente
;
; 2. CompareElements:
;    - Compara dos registros de estudiantes
;    - Maneja comparación de notas con decimales
;
; 3. SwapElements:
;    - Intercambia dos registros completos
;    - Realiza intercambio byte a byte
;
; 4. Rutinas de soporte:
;    - ValidateSort: Verifica el ordenamiento
;    - DisplayStudent: Muestra datos de estudiante
;    - SetSortOrder: Configura direccion de ordenamiento
;
; COMPLEJIDAD:
; - Tiempo: O(n^2) donde n es el numero de estudiantes
; - Espacio: O(1) espacio adicional constante
; ============================================================

; ------------------------------------------------------------
; SelectionSort: Ordena los estudiantes por nota usando Selection Sort
; ------------------------------------------------------------
; DESCRIPCIÓN:
;     Implementa el algoritmo Selection Sort para ordenar registros
;     de estudiantes basándose en sus notas.
;
; ENTRADA:
;     sort_order (variable global):
;     - 0: Orden ascendente (menor a mayor)
;     - 1: Orden descendente (mayor a menor)
;
; MODIFICA:
;     - EstudiantesData: Registros ordenados segun el criterio
;     - Variables temporales: temp_i, temp_j, temp_min_idx
;
; ALGORITMO:
;     Para i = 0 hasta n-2:
;         min_idx = i
;         Para j = i+1 hasta n-1:
;             Si (orden_asc y A[j] < A[min_idx]) :
;                (orden_desc y A[j] > A[min_idx]):
;                 min_idx = j
;         Si min_idx != i:
;             Intercambiar A[i] y A[min_idx]
;
; PRESERVA: todos los registros (AX, BX, CX, DX, SI, DI)
; ------------------------------------------------------------
SelectionSort PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Validación: Si hay 0 o 1 estudiantes, no hay nada que ordenar
    mov al, [NumEstudiantesRegistrados]
    xor ah, ah
    cmp ax, 2
    jb Sort_End         ; Si < 2 estudiantes, salir
    
    ; Variables locales en stack (simuladas con variables globales para simplicidad)
    ; Bucle externo: i = 0 to n-2
    mov WORD PTR [temp_i], 0      ; i = 0
    
Sort_OuterLoop:
    ; Verificar condición del bucle externo
    mov ax, [temp_i]
    mov bl, [NumEstudiantesRegistrados]
    xor bh, bh
    dec bx                        ; BX = n-1  
    cmp ax, bx                    ; i >= n-1??
    jge Sort_End                  ; Si sii, terminar
    
    ; Inicializar: min_idx = i
    mov ax, [temp_i]
    mov [temp_min_idx], ax
    
    ; Bucle interno: j = i+1 to n-1
    mov ax, [temp_i]
    inc ax
    mov [temp_j], ax              ; j = i+1
    
Sort_InnerLoop:
    ; Verificar condicion del bucle interno  
    mov ax, [temp_j]
    mov bl, [NumEstudiantesRegistrados]
    xor bh, bh
    cmp ax, bx                    ; j >= n??
    jge Sort_InnerEnd             ; Si sii, terminar bucle interno
    
    ; Comparar elemento en min_idx con elemento en j
    call CompareElements          ; Resultado en AL
    
    ; Si encontramos un mejor elemento, actualizar min_idx
    mov ah, [sort_order]
    cmp ah, 0                     ; Ascendente??
    je Sort_CheckAsc
    
    ; Orden descendente: actualizar si current > min
    cmp al, 1                     ; elemento[j] > elemento[min_idx]??
    jne Sort_InnerNext
    jmp Sort_UpdateMin
    
Sort_CheckAsc:
    ; Orden ascendente: actualizar si current < min  
    cmp al, 2                     ; elemento[j] < elemento[min_idx]??
    jne Sort_InnerNext
    
Sort_UpdateMin:
    mov ax, [temp_j]
    mov [temp_min_idx], ax
    
Sort_InnerNext:
    inc WORD PTR [temp_j]         ; j++
    jmp Sort_InnerLoop
    
Sort_InnerEnd:
    ; Si min_idx != i, intercambiar elementos
    mov ax, [temp_min_idx]
    mov bx, [temp_i]
    cmp ax, bx
    je Sort_OuterNext             ; Si son iguales, no intercambiar
    
    call SwapElements
    
Sort_OuterNext:
    inc WORD PTR [temp_i]         ; i++
    jmp Sort_OuterLoop
    
Sort_End:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
SelectionSort ENDP

; ------------------------------------------------------------
; CompareElements: Compara las notas de dos estudiantes
; ------------------------------------------------------------
; DESCRIPCION:
;     Compara las notas de dos estudiantes considerando tanto
;     la parte entera como la decimal de manera precisa.
;
; ENTRADA:
;     temp_min_idx: indice del primer estudiante a comparar
;     temp_j: indice del segundo estudiante a comparar
;
; SALIDA:
;     AL = Resultado de la comparación:
;         0: Las notas son iguales
;         1: nota[j] > nota[min_idx]
;         2: nota[j] < nota[min_idx]
;
; ALGORITMO:
;     1. Compara partes enteras (2 bytes)
;     2. Si son iguales, compara partes decimales (4 bytes)
;        - Primero compara words altos
;        - Luego compara words bajos
;
; PRESERVA: todos los registros excepto AL
; ------------------------------------------------------------
CompareElements PROC
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Calcular direccion del elemento[min_idx]
    mov ax, [temp_min_idx]
    mov bx, TAM_REGISTRO
    mul bx
    mov si, OFFSET EstudiantesData
    add si, ax
    add si, OFFSET_NOTA           ; SI = direccion nota[min_idx]
    
    ; Calcular direccion del elemento[j]
    mov ax, [temp_j] 
    mov bx, TAM_REGISTRO
    mul bx
    mov di, OFFSET EstudiantesData
    add di, ax
    add di, OFFSET_NOTA           ; DI = direccion nota[j]
    
    ; Comparar partes enteras
    mov ax, [di]                  ; Parte entera de nota[j]
    mov bx, [si]                  ; Parte entera de nota[min_idx]
    cmp ax, bx
    ja CompElem_Greater           ; nota[j] > nota[min_idx]
    jb CompElem_Lesser            ; nota[j] < nota[min_idx]
    
    ; Partes enteras iguales, comparar decimales (32 bits)
    ; Comparar high words
    mov ax, [di+4]                ; High word de nota[j]
    mov bx, [si+4]                ; High word de nota[min_idx]
    cmp ax, bx
    ja CompElem_Greater
    jb CompElem_Lesser
    
    ; High words iguales, comparar low words
    mov ax, [di+2]                ; Low word de nota[j]  
    mov bx, [si+2]                ; Low word de nota[min_idx]
    cmp ax, bx
    ja CompElem_Greater
    jb CompElem_Lesser
    
    ; Completamente iguales
    mov al, 0
    jmp CompElem_End
    
CompElem_Greater:
    mov al, 1                     ; nota[j] > nota[min_idx]
    jmp CompElem_End
    
CompElem_Lesser:
    mov al, 2                     ; nota[j] < nota[min_idx]
    
CompElem_End:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
CompareElements ENDP

; ------------------------------------------------------------
; SwapElements: Intercambia dos registros de estudiantes completos
; ------------------------------------------------------------
; DESCRIPCIÓN:
;     Realiza el intercambio fisico de dos registros de estudiantes
;     completos (70 bytes cada uno) en memoria.
;
; ENTRADA:
;     temp_i: indice del primer registro a intercambiar
;     temp_min_idx: indice del segundo registro a intercambiar
;
; ALGORITMO:
;     1. Calcula direcciones base de ambos registros
;     2. Realiza intercambio byte a byte para asegurar
;        integridad de datos y evitar problemas de alineación
;     3. Intercambia 70 bytes (tamanno completo del registro)
;
; PRECAUCIONES:                      
;     - Preserva DS y ES para seguridad en acceso a memoria
;     - Usa intercambio byte a byte para máxima compatibilidad
;
; PRESERVA: todos los registros y segmentos
; ------------------------------------------------------------
SwapElements PROC
    push ax
    push bx
    push cx
    push si
    push di
    push es
    push ds
    
    mov ax, ds
    mov es, ax
    
    ; Calcular dirección del elemento[i]
    mov ax, [temp_i]
    mov bx, TAM_REGISTRO
    mul bx
    mov si, OFFSET EstudiantesData
    add si, ax                    ; SI = direccion elemento[i]
    
    ; Calcular dirección del elemento[min_idx]
    mov ax, [temp_min_idx]
    mov bx, TAM_REGISTRO
    mul bx
    mov di, OFFSET EstudiantesData
    add di, ax                    ; DI = direccion elemento[min_idx]
    
    ; Intercambio byte a byte para evitar problemas con rep movsw
    mov cx, 70                    ; 70 bytes por registro
    
SwapLoop:
    ; Leer byte de elemento[i]
    mov al, [si]
    ; Leer byte de elemento[min_idx]  
    mov ah, [di]
    ; Intercambiar
    mov [si], ah
    mov [di], al
    ; Avanzar punteros
    inc si
    inc di
    loop SwapLoop
    
    pop ds
    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
SwapElements ENDP

; ------------------------------------------------------------
; EstablecerOrdenamiento: Establece el orden de clasificación
; Entrada: AL = 0 (ascendente), 1 (descendente)
; ------------------------------------------------------------
EstablecerOrdenamiento PROC
    push ax
    mov [sort_order], al
    pop ax
    ret
EstablecerOrdenamiento ENDP

; ------------------------------------------------------------
; OrdenarYMostrar: Ordena y muestra los estudiantes
; Entrada: AL = orden (0=ascendente, 1=descendente)
; ------------------------------------------------------------
OrdenarYMostrar PROC
    push ax
    push dx
    
    ; Establecer orden de clasificacion
    call EstablecerOrdenamiento
    
    ; Ejecutar ordenamiento
    call SelectionSort
    
    ; Mostrar mensaje de orden
    cmp al, 0
    je OrdenAscendente
    
    mov dx, OFFSET msgDescending
    jmp MostrarOrden
    
OrdenAscendente:
    mov dx, OFFSET msgAscending
    
MostrarOrden:
    mov ah, 09h
    int 21h
    
    ; Mostrar estudiantes ordenados
    call MostrarTodosEstudiantes
    
    ; Validacion, verifica que el primer elemento cumple el criterio
    call ValidarOrdenamiento
    
    pop dx
    pop ax
    ret
OrdenarYMostrar ENDP

; ------------------------------------------------------------
; ValidarOrdenamiento: Validacion del ordenamiento
; ------------------------------------------------------------
ValidarOrdenamiento PROC
    push ax
    push si
    push dx
    
    mov al, [NumEstudiantesRegistrados]
    cmp al, 2
    jb Validate_End     ; Si < 2 estudiantes, no validar
    
    ; Configurar comparacion entre primeros dos registros
    mov WORD PTR [temp_min_idx], 0    ; Primer registro (posicion 0)
    mov WORD PTR [temp_j], 1          ; Segundo registro (posicion 1)
    
    call CompareElements  ; AL = resultado de comparacion
    
    mov ah, [sort_order]
    cmp ah, 0           ; Ascendente?
    je Validate_Ascending
    
    ; Descendente: primer registro debe ser >= segundo
    ; CompareElements retorna: 1 si elemento[j] > elemento[min_idx], 2 si elemento[j] < elemento[min_idx]
    ; Para descendente: elemento[0] >= elemento[1], entonces elemento[1] <= elemento[0]
    ; Esto significa que CompareElements deberia retornar 2 (elemento[1] < elemento[0]) o 0 (iguales)
    cmp al, 1           ; elemento[1] > elemento[0]?? (MAL para descendente)
    je Validate_Error
    jmp Validate_OK
    
Validate_Ascending:
    ; Ascendente: primer registro debe ser <= segundo
    ; Para ascendente: elemento[0] <= elemento[1], entonces elemento[1] >= elemento[0]  
    ; Esto significa que CompareElements deberia retornar 1 (elemento[1] > elemento[0]) o 0 (iguales)
    cmp al, 2           ; elemento[1] < elemento[0]?? (MAL para ascendente)
    je Validate_Error
    
Validate_OK:
    mov dx, OFFSET msgSortOK
    mov ah, 09h
    int 21h
    jmp Validate_End
    
Validate_Error:
    mov dx, OFFSET msgSortError
    mov ah, 09h
    int 21h
    
Validate_End:
    pop dx
    pop si
    pop ax
    ret
ValidarOrdenamiento ENDP

; ------------------------------------------------------------
; MostrarTodosEstudiantes: Muestra todos los estudiantes registrados
; ------------------------------------------------------------
MostrarTodosEstudiantes PROC
    push ax
    push cx
    push si
    push dx
    
    mov al, [NumEstudiantesRegistrados]
    xor ah, ah
    mov cx, ax
    cmp cx, 0
    je FinMostrar
    
    mov si, OFFSET EstudiantesData
    mov dx, 1           ; Contador de estudiantes
    
BucleMostrar:
    ; Mostrar numero de estudiante
    push dx
    mov ax, dx
    call ImprimirNumero
    pop dx
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Mostrar datos del estudiante
    call MostrarEstudiante
    
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10  
    mov ah, 02h
    int 21h
    
    add si, TAM_REGISTRO
    inc dx
    loop BucleMostrar
    
FinMostrar:
    pop dx
    pop si
    pop cx
    pop ax
    ret
MostrarTodosEstudiantes ENDP

; ------------------------------------------------------------
; MostrarEstudiante: Muestra un estudiante especifico
; Entrada: SI = puntero al registro del estudiante
; ------------------------------------------------------------
MostrarEstudiante PROC
    push ax
    push si
    push dx
    
    ; Mostrar "Nombre: "
    mov dx, OFFSET msgNombre
    mov ah, 09h
    int 21h
    
    ; Mostrar nombre (termina en $)
    call MostrarCadena
    
    ; Mostrar ", Apellido1: "
    mov dx, OFFSET msgApellido1
    mov ah, 09h
    int 21h
    
    ; Avanzar al apellido1
    add si, TAM_NOMBRE
    call MostrarCadena
    
    ; Mostrar ", Apellido2: "
    mov dx, OFFSET msgApellido2
    mov ah, 09h
    int 21h
    
    ; Avanzar al apellido2
    add si, TAM_APELLIDO1
    call MostrarCadena
    
    ; Mostrar ", Nota: "
    mov dx, OFFSET msgNota
    mov ah, 09h
    int 21h
    
    ; Avanzar a la nota y mostrarla
    add si, TAM_APELLIDO2
    
    ; Mostrar parte entera
    mov ax, [si]
    call ImprimirNumero
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar parte decimal
    mov ax, [si+2]
    call ImprimirDecimal
    
    pop dx
    pop si
    pop ax
    ret
MostrarEstudiante ENDP

; ------------------------------------------------------------
; MostrarCadena: Muestra una cadena terminada en $
; Entrada: SI = puntero a la cadena
; ------------------------------------------------------------
MostrarCadena PROC
    push ax
    push si
    
BucleMostrarCadena:
    mov al, [si]
    cmp al, '$'
    je FinMostrarCadena
    cmp al, 0
    je FinMostrarCadena
    
    mov dl, al
    mov ah, 02h
    int 21h
    
    inc si
    jmp BucleMostrarCadena
    
FinMostrarCadena:
    pop si
    pop ax
    ret
MostrarCadena ENDP

END start