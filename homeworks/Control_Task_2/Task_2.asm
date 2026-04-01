.386

stack segment para stack
    db 65535 dup(?)
stack ends

data segment para public 
    out_buf db 256 dup(0)
    in_buf db 1024 dup (?)

    sys_msg db 'enter SS(d or h):', 0
    exp_msg db 'enter expression:', 0
    dec_msg db 'Decimal: ', 0
    hex_msg db 'Hex: ', 0

    err_overflow db 'Overflow error',  0dh, 0ah, 0
    err_format db 'Invalid expression format',  0dh, 0ah, 0
    err_operation db 'Invalid operation',  0dh, 0ah, 0
    err_div_zero db 'Divide by zero',  0dh, 0ah, 0
    
    err_list dw offset err_overflow, offset err_format, offset err_operation, offset err_div_zero

    E_OVERFLOW equ 0
    E_FORMAT equ 1
    E_OPERATION equ 2
    E_DIV_ZERO equ 3

    parser dw 0
    a dw 0
    b dw 0
    op db 0
data ends

code segment para public use16
    assume cs:code, ds:data, ss:stack

	
print:
    push bp
    mov bp, sp
    mov di, word ptr [bp+4]
    mov ah, 02h
	
print_loop:
    mov dl, byte ptr [di]
    int 21h
    inc di
    test dl, dl
    jnz print_loop
    pop bp
    ret

	
to_hex:
    push bp
    mov bp, sp
    mov di, word ptr [bp+4]
    mov bx, word ptr [bp+6]
    test bx, bx
    jnz th_not_zero
    mov byte ptr [di], '0'
    inc di
    jmp th_done
	
th_not_zero:
    test bx, bx
    jns th_positive
    mov byte ptr [di], '-'
    inc di
    neg bx
	
th_positive:
    mov cx, 4
	
th_loop:
    rol bx, 4
    mov al, bl
    and al, 0Fh
    cmp al, 10
    jl th_digit
    add al, 'A' - 10
    jmp th_store
	
th_digit:
    add al, '0'
	
th_store:
    mov byte ptr [di], al
    inc di
    loop th_loop
	
th_done:
    mov byte ptr [di], 0
    pop bp
    ret


to_dec:
    push bp
    mov  bp, sp
    mov  di, word ptr [bp+4]
    mov  ax, word ptr [bp+6]
    test ax, ax
    jnz  td_not_zero
    mov  byte ptr [di], '0'
    mov  byte ptr [di+1], 0
    jmp  td_done
	
td_not_zero:
    xor  bx, bx
    cmp  ax, 0
    jge  td_positive
    mov  bx, 1
    neg  ax
	
td_positive:
    xor  cx, cx
    mov  si, 10
	
td_div:
    xor  dx, dx
    div  si
    push dx
    inc  cx
    test ax, ax
    jnz  td_div
    mov  di, word ptr [bp+4]
    test bx, bx
    jz   td_no_sign
    mov  byte ptr [di], '-'
    inc  di
	
td_no_sign:
    mov  bx, cx
    jcxz td_skip
	
td_write:
    pop  dx
    add  dl, '0'
    mov  byte ptr [di], dl
    inc  di
    loop td_write
    mov byte ptr [di], 0
	
td_skip:
td_done:
    pop  bp
    ret


parse_dec:
    push bp
    mov  bp, sp
    push si
    push di
    push bx
    push dx
    mov  si, word ptr [bp+4]
    mov  cx, word ptr [bp+6]
    xor  ax, ax
    xor  di, di
    test cx, cx
    jz   pd_end
    mov  bl, byte ptr [si]
    cmp  bl, '-'
    jne  pd_no_sign
    inc  di
    inc  si
    dec  cx
    test cx, cx
    jz   pd_end
	
pd_no_sign:
pd_loop:
    mov  bl, byte ptr [si]
    cmp  bl, '0'
    jb   pd_end
    cmp  bl, '9'
    ja   pd_end
    sub  bl, '0'
    mov  bh, 0
	
    mov  dx, ax
    cmp  dx, 3276
    ja   pd_overflow
    jne  pd_safe
    cmp  di, 0
    jne  pd_neg_limit
    cmp  bl, 7
    ja   pd_overflow
    jmp  pd_safe
	
pd_neg_limit:
    cmp  bl, 8
    ja   pd_overflow
	
pd_safe:
    mov  dx, 10
    mul  dx
    test dx, dx
    jnz  pd_overflow
    add  ax, bx
    jc   pd_overflow
    inc  si
    dec  cx
    jnz  pd_loop
	
pd_end:
    test di, di
    clc
    jz   pd_done
    cmp  ax, 32768
    clc
    jne  pd_neg_normal
    mov  ax, -32768
    clc
    jmp  pd_done
	
pd_neg_normal:
    neg  ax
    clc
    jo   pd_overflow
	
pd_done:
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    ret
	
pd_overflow:
    cmp  di, 0
    jne  pd_overflow_neg
    mov  ax, E_OVERFLOW
    stc
    jmp  pd_done
	
pd_overflow_neg:
    mov  ax, E_OVERFLOW
    stc
    jmp  pd_done


parse_hex:
    push bp
    mov  bp, sp
    push si
    push di
    push bx
    push dx
    mov  si, word ptr [bp+4]
    mov  cx, word ptr [bp+6]
    xor  ax, ax
    xor  di, di
    test cx, cx
    jz   ph_end
    mov  bl, byte ptr [si]
    cmp  bl, '-'
    jne  ph_no_sign
    inc  di
    inc  si
    dec  cx
    test cx, cx
    jz   ph_end
	
ph_no_sign:
    cmp  cx, 2
    jb   ph_no_prefix
    mov  bl, byte ptr [si]
    cmp  bl, '0'
    jne  ph_no_prefix
    mov  bl, byte ptr [si+1]
    cmp  bl, 'x'
    je   ph_prefix
    cmp  bl, 'X'
    jne  ph_no_prefix
	
ph_prefix:
    add  si, 2
    sub  cx, 2
    test cx, cx
    jz   ph_end
	
ph_no_prefix:
ph_loop:
    mov  bl, byte ptr [si]
    cmp  bl, '0'
    jb   ph_end
    cmp  bl, '9'
    jbe  ph_digit
    cmp  bl, 'A'
    jb   ph_end
    cmp  bl, 'F'
    jbe  ph_letter
    cmp  bl, 'a'
    jb   ph_end
    cmp  bl, 'f'
    jbe  ph_letter_low
    jmp  ph_end
	
ph_digit:
    sub  bl, '0'
    jmp  ph_got
	
ph_letter:
    sub  bl, 'A'
    add  bl, 10
    jmp  ph_got
	
ph_letter_low:
    sub  bl, 'a'
    add  bl, 10
	
ph_got:
    mov  dx, ax
    shl  dx, 4
    cmp  di, 0
    je   ph_pos
    cmp  dx, 8000h
    ja   ph_overflow
    jmp  ph_add
	
ph_pos:
    cmp  dx, 7FFFh
    ja   ph_overflow
	
ph_add:
    xor  bh, bh
    add  dx, bx
    cmp  di, 0
    je   ph_pos_add
    cmp  dx, 8000h
    ja   ph_overflow
    cmp  dx, 8000h
    jne  ph_store
    cmp  cx, 1
    jne  ph_overflow
	
ph_store:
    mov  ax, dx
    jmp  ph_next
	
ph_pos_add:
    cmp  dx, 7FFFh
    ja   ph_overflow
    mov  ax, dx
	
ph_next:
    inc  si
    dec  cx
    jnz  ph_loop
	
ph_end:
    test di, di
    jz   ph_done
    cmp  ax, 8000h
    je   ph_done
    neg  ax
	
ph_done:
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    clc
    ret
	
ph_overflow:
    pop  dx
    pop  bx
    pop  di
    pop  si
    pop  bp
    mov  ax, E_OVERFLOW
    stc
    ret


error_show:
    push bp
    mov  bp, sp
    mov  ax, word ptr [bp+4]
    mov  bx, ax
    shl  bx, 1
    mov  dx, word ptr [err_list + bx]
    push dx
    call print
    add sp, 2
    mov ax, 4cFFh
    int 21h
    pop  bp
    ret


parse:
    push bp
    mov  bp, sp
    sub sp, 7
    mov di, word ptr [bp+4]
    mov cx, word ptr [bp+6]
    mov ax, 0
    mov word ptr [bp-7], ax
	
parse_loop:
    inc di
    cmp byte ptr [di], ' '
    je parse_white
    cmp byte ptr [di], 0Dh
    je parse_end
    loop parse_loop
	
parse_white:
    mov ax, word ptr [bp+4]
    mov si, di
    sub di, ax
    clc
    mov ax, di
    mov di, si
    push ax
    push word ptr [bp+4]
    call parser
    jc parse_fail_num
    add sp, 4
    clc
    mov word ptr [a], ax
    inc di
    mov al, byte ptr [di]
    cmp al, '+'
    je parse_op_ok
    cmp al, '-'
    je parse_op_ok
    cmp al, '*'
    je parse_op_ok
    cmp al, '/'
    je parse_op_ok
    cmp al, '%'
    je parse_op_ok
    jmp parse_fail_op
	
parse_op_ok:
    mov byte ptr [op], al
    inc di
    inc di
    mov word ptr [bp-5], di
    dec di
    mov ax, word ptr [bp-7]
    cmp ax, 1
    je parse_fail_format
    mov ax, 1
    mov word ptr [bp-7], ax
    loop parse_loop
	
parse_end:
    mov ax, word ptr [bp-7]
    cmp ax, 1
    jne parse_fail_format
    mov ax, 1
    mov ax, word ptr [bp-5]
    sub ax, di
    clc
    mov di, word ptr [bp-5]
    cmp ax, 0
    je parse_fail_second
    push ax
    push di
    call parser
    jc parse_fail_num
    add sp, 4
    clc
    mov word ptr [b], ax
    mov  sp, bp
    pop  bp
    xor ax, ax
    clc
    ret
	
parse_fail_num:
    add sp, 4
    mov ax, E_OVERFLOW
    stc
    mov  sp, bp
    pop  bp
    ret
	
parse_fail_op:
    add sp, 4
    mov ax, E_OPERATION
    stc
    mov sp, bp
    pop bp
    ret
	
parse_fail_second:
    add sp, 4
    mov ax, E_FORMAT
    stc
    mov sp, bp
    pop bp
    ret
	
parse_fail_format:
    mov ax, E_FORMAT
    stc
    mov sp, bp
    pop bp
    ret


calc:
    push bp
    mov  bp, sp
    sub  sp, 2
    mov  ax, word ptr [bp+4]
    mov  bx, word ptr [bp+6]
    mov  cl, byte ptr [bp+8]
    cmp  cl, '+'
    je   op_add
    cmp  cl, '-'
    je   op_sub
    cmp  cl, '*'
    je   op_mul
    cmp  cl, '/'
    je   op_div
    cmp  cl, '%'
    je   op_mod
    jmp  op_invalid
	
op_add:
    add  ax, bx
    jo   op_overflow
    clc
    jmp  op_done
	
op_sub:
    sub  ax, bx
    jo   op_overflow
    clc
    jmp  op_done
	
op_mul:
    imul bx
    cmp dx, 0
    jg op_overflow
    cmp dx, -1
    jl op_overflow
    cmp dx, 0
    jne mul_neg
    cmp ax, 0
    jl op_overflow
    jmp mul_ok
	
mul_neg:
    cmp ax, 0
    jge op_overflow
	
mul_ok:
    clc
    jmp  op_done
	
op_div:
    test bx, bx
    jz   op_div_zero
    cmp  bx, -1
    jne  do_div
    cmp  ax, -32768
    je   op_overflow
	
do_div:
    cwd
    idiv bx
    clc
    jmp  op_done
	
op_mod:
    test bx, bx
    jz   op_div_zero
    cmp  bx, -1
    jne  do_mod
    cmp  ax, -32768
    je   op_overflow
	
do_mod:
    cwd
    idiv bx
    mov  ax, dx
    clc
    jmp  op_done
	
op_div_zero:
    mov  ax, E_DIV_ZERO
    stc
    jmp  op_done
	
op_overflow:
    mov  ax, E_OVERFLOW
    stc
    jmp  op_done
	
op_invalid:
    mov  ax, E_OPERATION
    stc
	
op_done:
    mov  sp, bp
    pop  bp
    ret


start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    mov bp, sp
    sub sp, 6
    
    push offset sys_msg
    call print
    add sp, 2
    
    mov ah, 01h
    int 21h
    cmp al, 'h'
    je hex_mode
    mov word ptr [parser], offset parse_dec
	
cont_hex:
    mov dl, 0DH
    mov ah, 02h
    int 21h
    mov dl, 0AH
    int 21h
    
    push offset exp_msg
    call print
    add sp, 2
    
    mov bx, 0
    mov cx, 1023
    lea dx, in_buf
    mov ah, 3Fh
    int 21h
    
    push ax
    push offset in_buf
    call parse
    jc parse_failed
    add sp, 4
    
    mov ax, word ptr [a]
    mov bx, word ptr [b]
    mov cl, byte ptr [op]
    xor ch, ch
    
    push cx
    push word ptr [b]
    push word ptr [a]
    call calc
    jc calc_failed
    add sp, 6
    
    mov word ptr [bp-2], ax
    
    push offset dec_msg
    call print
    add sp, 2
    mov ax, word ptr [bp-2]
    push ax
    push offset out_buf
    call to_dec
    add sp, 4
    push offset out_buf
    call print
    add sp, 2
    mov dl, 0DH
    mov ah, 02h
    int 21h
    mov dl, 0AH
    int 21h
    
    push offset hex_msg
    call print
    add sp, 2
    mov ax, word ptr [bp-2]
    push ax
    push offset out_buf
    call to_hex
    add sp, 4
    push offset out_buf
    call print
    add sp, 2
    mov dl, 0DH
    mov ah, 02h
    int 21h
    mov dl, 0AH
    int 21h
    
    mov sp, bp
    mov ax, 4c00h
    int 21h

calc_failed:
    add sp, 4
	
parse_failed:
    add sp, 4
    push ax
    call error_show
    add sp, 2
    mov sp, bp
    mov ax, 4cFFh
    int 21h

hex_mode:
    mov word ptr [parser], offset parse_hex
    jmp cont_hex

code ends
end start