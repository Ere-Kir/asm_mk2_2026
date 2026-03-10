stack segment para stack
	db 128 dup(?)
stack ends

data segment para public
	buff db 241
		 db ?
		 db 241 dup(?)
	
	newline db 0Dh, 0Ah, '$'
data ends

code segment para public
	assume cs:code, ds:data, ss:stack
	
start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov dx, offset buff
	mov ah, 0Ah
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	xor bh, bh
	mov bl, buff[1]
	mov buff[bx+2], '$'
	
	mov dx, offset buff+2
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h

code ends
end start
