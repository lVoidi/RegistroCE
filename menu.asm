; ============================================================
; menu.asm - Modulo que implementa el menu principal.
; Nos muestra:
;   - Menu_Print      : Muestra el menu y el prompt.
;   - Menu_ReadChoice : Lee una opcion valida [1..5] y la
;                       devuelve en AL (1=Ingresar, 2=Estadisticas,
;                       3=Buscar, 4=Ordenar, 5=Salir).
; ============================================================

.MODEL SMALL               ; Mismo modelo en todos los modulos para compartir DGROUP
; .STACK se declara SOLO en main.asm para no duplicar pila

.DATA
menuTitle      db 13,10, '=== MENU PRINCIPAL ===',13,10,'$' ; los numeros 13,10 son equivalentes a un salto de linea
menu1          db '1) Ingresar calificaciones.',13,10,'$' ;menu1 es por asi decirlo la variable que contiene la opcion 1 y asi con las demas
menu2          db '2) Mostrar estadisticas.',13,10,'$'
menu3          db '3) Buscar estudiante por indice.',13,10,'$'
menu4          db '4) Ordenar calificaciones.',13,10,'$'
menu5          db '5) Salir.',13,10,'$'
prompt         db 'Seleccione una opcion [1-5]: $'
msgInvalid     db 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'

.CODE
PUBLIC Menu_Print, Menu_ReadChoice    ; Exporta simbolos para main.asm

; ------------------------------------------------------------
; Menu_Print
;   Muestra el menu y el prompt de seleccion.
;   No altera registros del llamador (salvo flags).
; ------------------------------------------------------------
Menu_Print PROC NEAR
    push ax
    push dx

    mov  dx, OFFSET menuTitle
    mov  ah, 09h               ; le decimos que debe de imprimir cadena terminada en '$'
    int  21h                    ; Imprime el texto

    mov  dx, OFFSET menu1 
    mov  ah, 09h 
    int  21h 

    mov  dx, OFFSET menu2
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET menu3
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET menu4
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET menu5
    mov  ah, 09h
    int  21h

    mov  dx, OFFSET prompt
    mov  ah, 09h
    int  21h

    pop  dx 
    pop  ax 
    ret
Menu_Print ENDP ; Fin de Menu_Print

; ------------------------------------------------------------
; Menu_ReadChoice
;   Espera una tecla entre '1' y '5'.
;   - Si valido:  devuelve en AL el numero 1..5 (binario), AH=0.
;   - Si invalido: muestra mensaje y reintenta.
;   Usa INT 21h / AH=01h (lectura con eco).
; ------------------------------------------------------------

Menu_ReadChoice PROC NEAR
ReadLoop:
    mov  ah, 01h               ;  leer caracter con eco (bloqueante)
    int  21h                   ; AL = ASCII de la tecla pulsada

    cmp  al, '1'               ; Verifica si AL < '1', si es así salta a Invalid
    jb   Invalid
    cmp  al, '5'               ; Verifica si AL > '5', si es así salta a Invalid
    ja   Invalid

    sub  al, '0'               ; Convierte ASCII a numero ( '1'->1 ... '5'->5 ) es decir pasa de string a numero
    xor  ah, ah                ; AH=0 por limpieza, para evitar resultados inesperados
    ret

Invalid:
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

END
