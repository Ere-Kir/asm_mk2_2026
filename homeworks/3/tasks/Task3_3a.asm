stack segment para stack
	db 128 dup(?)
stack ends

data segment para public
	x dw 10
	y dw 5
	z dw ?
	text db "Res: $"
	newline db 0Dh, 0Ah, '$'
	buff db 6 dup('$')
data ends

code segment para public
	assume cs:code, ds:data, ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov ax, x
	imul y
	
	push dx
	push ax
	
	mov ax, x
	add ax, y
	
	cmp ax, 0
	je exit
	
	mov bx, ax
	
	pop ax
	pop dx
	
	idiv bx
	
	mov z, ax
	
	mov dx, offset text
	mov ah, 09h
	int 21h
	
	mov ax, z
	mov cx, 0
	mov bx, 10
	
convert:
	xor dx, dx
	div bx
	push dx
	inc cx
	cmp ax, 0
	jne convert
	
print:
	pop dx
	add dl, '0'
	mov ah, 02h
	int 21h
	loop print
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
exit:
	mov ax, 4c00h
	int 21h

code ends
end start
