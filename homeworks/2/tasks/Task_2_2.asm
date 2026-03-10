stack segment para stack
	db 128 dup(?)
stack ends

data segment para public
	text db "Hello, World!$"
data ends

code segment para public
	assume cs:code, ds:data, ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov dx, offset text
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h
	
code ends
end start