pushregs macro r1, r2, r3, r4, r5, r6, r7, r8, r9, r10
    ifnb <r1>
        push r1
        pushregs r2, r3, r4, r5, r6, r7, r8, r9, r10
    endif
endm

popregs macro r1, r2, r3, r4, r5, r6, r7, r8, r9, r10
    ifnb <r1>
        pop r1
        popregs r2, r3, r4, r5, r6, r7, r8, r9, r10
    endif
endm

slen proc near
    push bp
    mov bp, sp
    pushregs cx, di
    mov di, word ptr [bp + 4]
    xor ax, ax
slen_loop:
    mov cl, byte ptr [di]
    test cl, cl
    jz slen_ret
    inc ax
    inc di
    jmp slen_loop
slen_ret:
    popregs di, cx
    mov sp, bp
    pop bp
    ret
slen endp

stos proc near
    push bp
    mov bp, sp
    sub sp, 10
    pushregs di, si, cx, bx, dx
    mov word ptr [bp-2], 1
    mov word ptr [bp-6], 0
    mov byte ptr [bp-8], 0
    mov di, word ptr [bp+a1]
    mov si, word ptr [bp+a2]
    mov cx, word ptr [bp+a3]
    mov [bp-10], cx
stos_ws_loop:
    mov bl, byte ptr [di]
    xor bh, bh
    test bl, bl
    jz stos_empty
    cmp bl, ' '
    je stos_ws_found
    cmp bl, 09h
    je stos_ws_found
    cmp bl, 0Ah
    je stos_ws_found
    cmp bl, 0Bh
    je stos_ws_found
    cmp bl, 0Ch
    je stos_ws_found
    cmp bl, 0Dh
    je stos_ws_found
    jmp stos_sign
stos_ws_found:
    inc di
    jmp stos_ws_loop
stos_sign:
    mov bl, byte ptr [di]
    cmp bl, '-'
    je stos_neg
    cmp bl, '+'
    je stos_pos
stos_sign_end:
    mov cx, [bp-10]
    test cx, cx
    jz stos_base0
    cmp cx, 16
    jz stos_base16
stos_base_chk_done:
    cmp cx, 2
    jb stos_inv_base
    mov word ptr [bp-4], di
stos_cnv:
    mov bl, byte ptr [di]
    test bl, bl
    jz stos_nodig
    cmp bl, '0'
    jb stos_chk_up
    cmp bl, '9'
    ja stos_chk_up
    sub bl, '0'
    jmp stos_dig_ok
stos_chk_up:
    cmp bl, 'A'
    jb stos_chk_lo
    cmp bl, 'Z'
    ja stos_chk_lo
    sub bl, 'A'
    add bl, 10
    jmp stos_dig_ok
stos_chk_lo:
    cmp bl, 'a'
    jb stos_nodig
    cmp bl, 'z'
    ja stos_nodig
    sub bl, 'a'
    add bl, 10
stos_dig_ok:
    cmp bl, cl
    jae stos_inv_dig
    cmp byte ptr [bp-8], 0
    jne stos_skip_acc
    mov ax, [bp-6]
    mul cx
    test dx, dx
    jnz stos_ovf_set
    add ax, bx
    jc stos_ovf_set
    cmp word ptr [bp-2], -1
    je stos_neglim
    cmp ax, 32767
    ja stos_ovf_set
    jmp stos_store
stos_neglim:
    cmp ax, 32768
    ja stos_ovf_set
stos_store:
    mov [bp-6], ax
    jmp stos_next_dig
stos_ovf_set:
    mov byte ptr [bp-8], 1
stos_skip_acc:
stos_next_dig:
    inc di
    jmp stos_cnv
stos_nodig:
    jmp stos_nodig_common
stos_nodig_common:
    mov ax, [bp-4]
    cmp di, ax
    je stos_nodigit
    cmp byte ptr [bp-8], 0
    jne stos_ovf_res
    mov ax, [bp-6]
    cmp word ptr [bp-2], -1
    jne stos_posres
    neg ax
stos_posres:
    mov bx, [bp+a2]
    mov [bx], di
    jmp stos_done
stos_ovf_res:
    cmp word ptr [bp-2], -1
    je stos_negovf
    mov ax, 32767
    jmp stos_setend
stos_negovf:
    mov ax, -32768
stos_setend:
    mov bx, [bp+a2]
    mov [bx], di
    jmp stos_done
stos_nodigit:
    xor ax, ax
    mov bx, [bp+a2]
    mov cx, [bp+a1]
    mov [bx], cx
    jmp stos_done
stos_inv_dig:
    mov ax, word ptr [bp-6]
    mov word ptr [si], di
    jmp stos_done
stos_inv_base:
stos_empty:
    xor ax, ax
    mov di, word ptr [bp+a1]
    mov word ptr [si], di
    jmp stos_done
stos_neg:
    inc di
    mov word ptr [bp-2], -1
    jmp stos_sign_end
stos_pos:
    inc di
    jmp stos_sign_end
stos_base0:
    mov bl, byte ptr [di]
    test bl, bl
    jz stos_empty
    cmp bl, '0'
    jne stos_base0_skip
    inc di
    mov bl, byte ptr [di]
    test bl, bl
    jz stos_base0_ret
    cmp bl, 'x'
    je stos_base0_16
    mov cx, 8
    mov [bp-10], cx
    jmp stos_base_chk_done
stos_base0_skip:
    mov cx, 10
    mov [bp-10], cx
    jmp stos_base_chk_done
stos_base0_16:
    inc di
    mov cx, 16
    mov [bp-10], cx
    jmp stos_base_chk_done
stos_base0_ret:
    dec di
    mov cx, 10
    mov [bp-10], cx
    jmp stos_base_chk_done
stos_base16:
    cmp byte ptr [di], '0'
    jne stos_base16_skip
    cmp byte ptr [di+1], 'x'
    je stos_base16_pfx_skip
stos_base16_skip:
    jmp stos_base_chk_done
stos_base16_pfx_skip:
    add di, 2
    jmp stos_base_chk_done
stos_done:
    popregs dx, bx, cx, si, di
    mov sp, bp
    pop bp
    ret
stos endp

stoa proc near
    push bp
    mov bp, sp
    sub sp, 14
    push si
    push di
    mov di, word ptr [bp+4]
    mov word ptr [bp-2], 0
    xor si, si
    or di, di
    jge stoa_cvt
    mov word ptr [bp-2], 1
    mov ax, di
    neg ax
    mov di, ax
stoa_cvt:
    mov ax, di
    mov bx, 10
    cwd
    idiv bx
    add dl, 48
    mov byte ptr [bp+si-14], dl
    inc si
    mov bx, 10
    mov ax, di
    cwd
    idiv bx
    mov di, ax
    or di, di
    jg stoa_cvt
    cmp word ptr [bp-2], 0
    je stoa_nonegsign
    mov byte ptr [bp+si-14], 45
    inc si
stoa_nonegsign:
    xor cx, cx
    jmp stoa_rev_tst
stoa_rev_body:
    dec si
    mov al, byte ptr [bp+si-14]
    mov bx, word ptr [bp+6]
    add bx, cx
    mov byte ptr [bx], al
    inc cx
stoa_rev_tst:
    or si, si
    jg stoa_rev_body
    mov bx, word ptr [bp+6]
    add bx, cx
    mov byte ptr [bx], 0
    mov ax, word ptr [bp+6]
    pop di
    pop si
    mov sp, bp
    pop bp
    ret
stoa endp