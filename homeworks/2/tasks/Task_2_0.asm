stack segment para stack
	db 128 dup (?)
stack ends

data segment para public
	str1 db "Hello, asm!", 0Dh, 0Ah, '$'
data ends

code segment para public
	assume cs:code, ds:data, ss:stack
	
start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov dx, offset str1
	mov ah, 09h
	int 21h
	
	mov bx, offset str1
	mov byte ptr [bx + 3], 'Q'
	
	lea dx, [bx + 3 + 1]
	mov bx, dx
	mov dl, byte ptr [bx]
	
	mov ah, 02h
	int 21h
	
	mov ax, 4ch
	int 21h
code ends
end start
