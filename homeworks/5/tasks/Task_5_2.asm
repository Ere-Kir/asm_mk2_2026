.386

stack segment para stack
	db 256 dup(?)
stack ends

data segment para public
	max_len db 240
	len db ?
	buff db 241 dup (?)
	
	range_start db ?
	range_end db ?
	
	text1 db "Enter start of range: $"
	text2 db "Enter end of range: $"
	text3 db 0Dh, 0Ah, "Enter string to check: $"
	
	fail db "Some character in the string is not within the specified range.$"
	good db "All characters in a string within the specified range.$"
	
	newline db 0Dh, 0Ah, '$'
data ends

code segment para public use16
	assume cs:code, ds:data, ss:stack

start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov dx, offset text1
	mov ah, 09h
	int 21h
	
	mov ah, 01h
	int 21h
	mov range_start, al
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	
	mov dx, offset text2
	mov ah, 09h
	int 21h
	
	mov ah, 01h
	int 21h
	mov range_end, al
	
	mov dx, offset newline
	mov ah, 09h
	int 21
	
	mov dx, offset text3
	mov ah, 09h
	int 21h
	
	mov dx, offset max_len
	mov ah, 0Ah
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	xor bx, bx
	mov bl, len
	mov buff[bx], '$'
	
	xor bx, bx
	mov cl, len
	xor ch, ch
	
check:
	cmp bx, cx
	je all_good
	
	mov al, buff[bx]
	
	cmp al, range_start
	jb failed
	
	cmp al, range_end
	ja failed
	
	inc bx
	jmp check
	
failed:
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov dx, offset fail
	mov ah, 09h
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov ax, 4CFFh
	int 21h
	
all_good:
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov dx, offset good
	mov ah, 09h
	int 21h
	
	mov dx, offset newline
	mov ah, 09h
	int 21h
	
	mov ax, 4C00h
	int 21h

code ends
end start
