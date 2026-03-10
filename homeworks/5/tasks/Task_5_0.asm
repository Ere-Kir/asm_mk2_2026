.386

stack segment para stack
	db 256 dup(?)
stack ends

data segment para public
	src_string db "Try find symbol!"
	new_line db 0dh, 0ah, "$"
	src_len dw ?
	
	success_str db " - Found", 0dh, 0ah, "$"
	error_str db " - Not found", 0dh, 0ah, "$"
	empty_str db " - Emrty input", 0dh, 0ah, "$"
	
	show_string db "Current string: Try find symbol!", 0dh, 0ah, "$"
	
	reserved db 256 dup(?)
	request_cnt dw 0
	empty_cnt dw 0
data ends

code segment para public use16
	assume cs:code, ds:data, ss:stack
	
start:
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov cx, offset new_line
	mov bx, offset src_string
	sub cx, bx
	mov word ptr [src_len], cx
	
main_loop:
	mov ah, 01h
	int 21h
	
	cmp al, 0dh
	je empty_input
	
	mov word ptr [empty_cnt], 0
	
	mov byte ptr [reserved], al
	
	inc word ptr [request_cnt]
	
	mov ax, word ptr [request_cnt]
	mov cx, 5
	xor dx, dx
	div cx
	cmp dx, 0
	jne skip_show
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	push dx
	push ax
	mov dx, offset show_string
	mov ah, 09h
	int 21h
	pop ax
	pop dx
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
skip_show:
	mov al, byte ptr[reserved]
	mov cx, word ptr [src_len]
	mov bx, offset src_string
	dec bx

search:
	inc bx
	cmp al, byte ptr [bx]
	loopne search
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dl, byte ptr [reserved]
	mov ah, 02h
	int 21h
	
	
	je found
	
	mov dx, offset error_str
	jmp print_res
	
found:
	mov dx, offset success_str

print_res:
	mov ah, 09h
	int 21h
	
	jmp main_loop
	
empty_input:
	mov dx, offset empty_str
	mov ah, 09h
	int 21h
	
	inc word ptr [empty_cnt]
	
	cmp word ptr [empty_cnt], 2
	je exit
	
	jmp main_loop
	
exit:
	mov ax, 4c00h
	int 21h

code ends
end start
