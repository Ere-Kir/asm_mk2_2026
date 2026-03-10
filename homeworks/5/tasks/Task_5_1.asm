.386

stack segment para stack
	db 256 dup(?)
stack ends

data segment para public
	max_len db 240
	len db ?
	buff db 241 dup(?)
	n db 5
	newline db 0Dh, 0Ah, '$'
	
	text1 db "Enter string: $"
	text2 db 0Dh, 0Ah, "Reserved string: $"
	text3 db 0Dh, 0Ah, "String N times: $"
data ends

code segment para public use16
	assume cs:code, ds:data, ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov dx, offset max_len
	mov ah, 0Ah
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	xor bx, bx
	mov bl, len
	mov buff[bx], '$'
	
	mov dx, offset text2
	mov ah, 09h
	int 21h
	
	xor bx, bx
	mov bl, len
	dec bx
	
	
reverse:
	cmp bx, 0
	jl reverse_end
	
	mov dl, buff[bx]
	mov ah, 02h
	int 21h
	
	dec bx
	jmp reverse
	
reverse_end:
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	
	mov dx, offset text3
	mov ah, 09h
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	xor cx, cx
	mov cl, n
	
n_times:
	cmp cx, 0
	je n_times_end
	
	mov dx, offset buff
	mov ah, 09h
	int 21h
	
	push cx
	mov dx, offset newline
	mov ah, 09h
	int 21h
	pop cx
	
	dec cx
	jmp n_times
	
n_times_end:
	mov ax, 4c00h
	int 21h

code ends
end start
