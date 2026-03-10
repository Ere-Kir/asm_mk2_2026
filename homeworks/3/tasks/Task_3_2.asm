stack segment para stack
	db 128 dup(?)
stack ends

data segment para public
	buff db 241 dup(?)
	read_byte dw ?
	
data ends

code segment para public
	assume cs:code, ds:data, ss:stack
	
	
start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov ah, 3Fh
	mov bx, 0
	mov cx, 240
	mov dx, offset buff
	int 21h
	
	mov read_byte, ax
	
	mov ah, 40h
	mov bx, 1
	mov cx, read_byte
	mov dx, offset buff
	int 21h
	
	mov ax, 4c00h
	int 21h

code ends
end start
