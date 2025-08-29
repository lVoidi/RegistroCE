.DATA
; Lista de estudiantes (Nombre + Nota)
estudiantes db 'Ana$',90
            db 'Luis$',85
            db 'Maria$',78
            db 'Pedro$',92
            db 'Jose$',60
            db 'Elena$',70
            db 'Raul$',88
            db 'Clara$',95
            db 'David$',81
            db 'Marta$',74
            db 'Jorge$',66
            db 'Sofia$',100
            db 'Hugo$',55
            db 'Pablo$',83
            db 'Laura$',79

msgIngIndice   db 13,10,'Ingrese el indice del estudiante (1-15): $'
msgFueraRango  db 13,10,'[ERROR] Indice fuera de rango.',13,10,'$'
msgResultado   db 13,10,'Estudiante: $'
msgNota        db 13,10,'Nota: $'
newline        db 13,10,'$'

.CODE

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

    dec bl              ; convertir a índice base 0
    mov si, bx

    ; Encontrar estudiante recorriendo nombres+notas
    mov bx, OFFSET estudiantes
NextStudent:
    cmp si, 0
    je  FoundStudent
SkipLoop:
    mov al, [bx]
    inc bx
    cmp al, '$'
    jne SkipLoop
    inc bx              ; saltar la nota
    dec si
    jmp NextStudent

FoundStudent:
    ; Mostrar mensaje
    mov dx, OFFSET msgResultado
    mov ah, 09h
    int 21h

    ; Imprimir nombre
    mov dx, bx
    mov ah, 09h
    int 21h

    ; Saltar hasta la nota (después del $)
SkipToNota:
    mov al, [bx]
    inc bx
    cmp al, '$'
    jne SkipToNota

    ; bx ahora apunta a la nota
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

