.386

stack segment para stack
    db 256 dup (?)
stack ends 

data segment para public
    matrix dw 100 dup(0)
    
    rows equ 10
    cols equ 10
    
    header_left db 0Dh, 0Ah, "LEFT:", 0Dh, 0Ah, '$'
    header_right db 0Dh, 0Ah, "RIGHT:", 0Dh, 0Ah, '$'
    newline db 0Dh, 0Ah, '$'
data ends

code segment para public use16
    assume cs:code, ds:data, ss:stack

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax

    xor bx, bx
    xor dx, dx
    
fill:
    mov matrix[bx], dx
    add bx, 2
    inc dx
    cmp dx, 100
    jl fill
	
	
    mov dx, offset header_left
    mov ah, 09h
    int 21h
    
    xor bx, bx
    mov cx, rows
    
row_left:
    push cx
    mov cx, cols
    
col_left:
    mov ax, matrix[bx]
    
    cmp ax, 10
    jl left_one_digit
    
    xor dx, dx
    mov si, 10
    div si
    
    push dx
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h
    pop dx
    mov dl, dl
    add dl, '0'
    mov ah, 02h
    int 21h
    jmp left_after_num
    
left_one_digit:
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
left_after_num:
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    cmp ax, 10
    jl left_extra_space
    cmp ax, 100
    jl left_next_col
    
left_extra_space:
    push ax
    mov ax, matrix[bx]
    cmp ax, 10
    pop ax
    jge left_next_col
    mov dl, ' '
    mov ah, 02h
    int 21h
    
left_next_col:
    add bx, 2
    loop col_left
    
    mov dx, offset newline
    mov ah, 09h
    int 21h
    
    pop cx
    loop row_left


	
    mov dx, offset header_right
    mov ah, 09h
    int 21h
    
    xor bx, bx
    mov cx, rows
    
row_right:
    push cx
    mov cx, cols
    
col_right:
    mov ax, matrix[bx]

    cmp ax, 10
    jge right_no_space
    push ax
    mov dl, ' '
    mov ah, 02h
    int 21h
    pop ax
	
right_no_space:
    cmp ax, 10
    jl right_one_digit
    
    xor dx, dx
    mov si, 10
    div si
    
    push dx
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h
    pop dx
    mov dl, dl
    add dl, '0'
    mov ah, 02h
    int 21h
    jmp right_after_num
    
right_one_digit:
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
right_after_num:
    mov dl, ' '
    mov ah, 02h
    int 21h
    
right_next_col:
    add bx, 2
    loop col_right
    
    mov dx, offset newline
    mov ah, 09h
    int 21h
    
    pop cx
    loop row_right

exit:
    mov ax, 4c00h
    int 21h

code ends
end start