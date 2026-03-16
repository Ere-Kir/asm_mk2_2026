stack segment para stack
	db 128 dup(?)
stack ends

data segment para public
	a dw 50
	b dw 30
	c_l dw ?
	c_h dw ?
	text db "Res: $"
	newline db 0Dh, 0Ah, '$'
	buffer db 15 dup('$')
data ends

code segment para public
	assume cs:code, ds:data, ss:stack

start:
	
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov ax, word ptr[a]
	add ax, word ptr[b]
	mov bx, ax
	imul bx
	imul bx
	
	mov word ptr[c_l], ax
	mov word ptr [c_h], dx
	
	
	mov dx, offset text
	mov ah, 09h
	int 21h
	
	mov ax, word ptr[c_l]
	mov dx, word ptr[c_h]
	
	mov si, offset buffer
	add si, 14
	mov byte ptr[si], '$'
	dec si
	
	cmp dx, 0
	jne convert
	cmp ax, 0
	jne convert
	mov byte ptr [si], '0'
	dec si
	jmp print
	
convert:
	push bx
	push cx
	
	mov cx, 10
	
convert_loop:
	mov bx, ax
	mov ax, dx
	xor dx, dx
	div cx
	
	push ax
	
	mov ax, bx
	div cx
	
	add dl, '0'
	mov [si], dl
	dec si
	
	pop dx
	
	cmp dx, 0
	jne convert_loop
	cmp ax, 0
	jne convert_loop
	
	pop cx
	pop bx
	
print:
	inc si
	mov dx, si
	mov ah, 09h
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h

code ends
end start
