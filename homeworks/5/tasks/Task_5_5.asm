.386

stack segment para stack
    db 256 dup (?)
stack ends 

data segment para public
    number dw 3F7Ah
    hex_buffer db 5 dup('$')
    result db "Hexadecimal: 0x$"
    newline db 0Dh, 0Ah, '$'
data ends

code segment para public use16
    assume cs:code, ds:data, ss:stack

start:
    mov ax, data
    mov ds, ax
	mov ax, stack
    mov ss, ax

    
    mov ax, number
    mov cx, 4
    mov di, offset hex_buffer
    
convert:
    push ax

    mov dx, ax
    shr dx, 12
    
    cmp dx, 10
    jl is_digit
    
    sub dx, 10
    add dl, 'A'
    jmp save
    
is_digit:
    add dl, '0'
    
save:
    mov [di], dl
    inc di
    
    pop ax
    shl ax, 4

    loop convert
    
	
    mov dx, offset result
    mov ah, 09h
    int 21h
    
    mov dx, offset hex_buffer
    mov ah, 09h
    int 21h
    
    mov dx, offset newline
    mov ah, 09h
    int 21h

exit:
    mov ax, 4c00h
    int 21h

code ends
end start