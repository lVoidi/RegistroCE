org 100h

.DATA
EstudiantesData:
    ; Estudiante 1: Nota 85.12345
    DB 'Juan$'
    DB 16 DUP(0)
    DB 'Perez$'
    DB 15 DUP(0)
    DB 'Lopez$'
    DB 15 DUP(0)
    DW 85           ; Parte entera
    DD 12345        ; Parte decimal

OFFSET_NOTA EQU 63
TAM_REGISTRO EQU 70

.CODE
start:
    mov ax, @DATA
    mov ds, ax
    
    ; Probar acceso a la primera nota
    mov si, OFFSET EstudiantesData
    add si, OFFSET_NOTA
    
    ; Leer parte entera
    mov ax, [si]
    call ImprimirNumero
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Leer parte decimal
    mov ax, [si+2]  ; Low word
    call ImprimirNumero
    
    mov ah, 4Ch
    int 21h

ImprimirNumero PROC
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10
    mov cx, 0
    
    cmp ax, 0
    jne ConvertLoop
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp PrintEnd
    
ConvertLoop:
    cmp ax, 0
    je PrintDigits
    
    xor dx, dx
    div bx
    
    add dl, '0'
    push dx
    inc cx
    
    jmp ConvertLoop
    
PrintDigits:
    cmp cx, 0
    je PrintEnd
    
    pop dx
    mov ah, 02h
    int 21h
    
    dec cx
    jmp PrintDigits
    
PrintEnd:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ImprimirNumero ENDP

END start
