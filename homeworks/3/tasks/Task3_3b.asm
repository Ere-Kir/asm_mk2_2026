stack segment para stack
	db 128 dup(?)
stack ends

data segment para public
	a dw 5
	b dw 3
	c dw ?
	text db "Res: $"
	newline db 0Dh, 0Ah, '$'
data ends

code segment para public
	assume cs:code, ds:data, ss:stack

start:
	
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov ax, a
	add ax, b
	imul ax
	mov c, ax
	
	mov dx, offset text
	mov ah, 09h
	int 21h
	
	mov ax, c
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
	
	mov ax, 4c00h
	int 21h

code ends
end start
