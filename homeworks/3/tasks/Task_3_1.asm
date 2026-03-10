stack segment para stack
	db 128 dup(?)
stack ends

data segment para public
	CNT_STR equ 3
	MAX_LEN equ 240
	BUF_SIZE equ 241
	
	array db CNT_STR * BUF_SIZE dup (?)
	
	max_len1 db MAX_LEN
	len1 db ?
	buff1 db BUF_SIZE dup(?)
	
	max_len2 db MAX_LEN
	len2 db ?
	buff2 db BUF_SIZE dup (?)
	
	max_len3 db MAX_LEN
	len3 db ?
	buff3 db BUF_SIZE (?)
	
	text1 db "Enter string 1: $"
	text2 db "Enter string 2: $"
	text3 db "Enter string 3: $"
	
	newline db 0Dh, 0Ah, '$'
data ends

code segment
	assume cs:code, ds:data, ss:stack
	
start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov dx, offset text1
	mov ah, 09h
	int 21h
	
	mov dx, offset max_len1
	mov ah, 0Ah
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	xor bx, bx
	mov bl, len1
	
	mov cx, bx
	mov si, offset buff1
	mov di, offset array
	
copy1:
	mov al, [si]
	mov [di], al
	inc si
	inc di
	loop copy1
	
	mov byte ptr [di], '$'
	
	
	mov dx, offset text2
	mov ah, 09h
	int 21h
	
	mov dx, offset max_len2
	mov ah, 0Ah
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	xor bx, bx
	mov bl, len2
	
	mov cx, bx
	mov si, offset buff2
	mov di, offset array
	add di, BUF_SIZE
	
copy2:
		mov al, [si]
		mov [di], al
		inc si
		inc di
		loop copy2
	
	mov byte ptr [di], '$'
	
	
	mov dx, offset text3
	mov ah, 09h
	int 21h
	
	mov dx, offset max_len3
	mov ah, 0Ah
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	xor bx, bx
	mov bl, len3
	
	mov cx, bx
	mov si, offset buff3
	mov di, offset array
	add di, 2*BUF_SIZE
	
copy3:
	mov al, [si]
	mov [di], al
	inc si
	inc di
	loop copy3
	
	mov byte ptr[di], '$'
	
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov dx, offset array
	mov ah, 09h
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov dx, offset array
	add dx, BUF_SIZE
	mov ah, 09h
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov dx, offset array
	add dx, 2 * BUF_SIZE
	mov ah, 09h
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov ax, 4c00h
	int 21h
code ends
end start
	