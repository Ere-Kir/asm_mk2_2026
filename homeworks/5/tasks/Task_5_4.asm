.386

stack segment para stack
    db 256 dup (?)
stack ends 

data segment para public
    hex_chars db "0123456789ABCDEF"
    new_line db 0Dh, 0Ah, '$'
    colon db ": $"
    space db "  $"
    
    ctrl_00 db "NUL$"
    ctrl_01 db "SOH$"
    ctrl_02 db "STX$"
    ctrl_03 db "ETX$"
    ctrl_04 db "EOT$"
    ctrl_05 db "ENQ$"
    ctrl_06 db "ACK$"
    ctrl_07 db "BEL$"
    ctrl_08 db "BS$"
    ctrl_09 db "TAB$"
    ctrl_0A db "LF$"
    ctrl_0B db "VT$"
    ctrl_0C db "FF$"
    ctrl_0D db "CR$"
    ctrl_0E db "SO$"
    ctrl_0F db "SI$"
    ctrl_10 db "DLE$"
    ctrl_11 db "DC1$"
    ctrl_12 db "DC2$"
    ctrl_13 db "DC3$"
    ctrl_14 db "DC4$"
    ctrl_15 db "NAK$"
    ctrl_16 db "SYN$"
    ctrl_17 db "ETB$"
    ctrl_18 db "CAN$"
    ctrl_19 db "EM$"
    ctrl_1A db "SUB$"
    ctrl_1B db "ESC$"
    ctrl_1C db "FS$"
    ctrl_1D db "GS$"
    ctrl_1E db "RS$"
    ctrl_1F db "US$"
    ctrl_20 db "SP$"
    ctrl_7F db "DEL$"
    
data ends

code segment para public use16
    assume cs:code, ds:data, ss:stack

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax

    mov bx, 0
    mov cx, 256
    mov dx, 0
	
main_loop:
    push bx
    push cx
    push dx
    
    cmp bl, 20h
    jl control_range
    cmp bl, 7Fh
    je control_range
    jmp normal_char
    
control_range:
    cmp bl, 7Fh
    je print_del
    
    cmp bl, 0
    jne c1
    mov dx, offset ctrl_00
    jmp print_ctrl
c1: cmp bl, 1
    jne c2
    mov dx, offset ctrl_01
    jmp print_ctrl
c2: cmp bl, 2
    jne c3
    mov dx, offset ctrl_02
    jmp print_ctrl
c3: cmp bl, 3
    jne c4
    mov dx, offset ctrl_03
    jmp print_ctrl
c4: cmp bl, 4
    jne c5
    mov dx, offset ctrl_04
    jmp print_ctrl
c5: cmp bl, 5
    jne c6
    mov dx, offset ctrl_05
    jmp print_ctrl
c6: cmp bl, 6
    jne c7
    mov dx, offset ctrl_06
    jmp print_ctrl
c7: cmp bl, 7
    jne c8
    mov dx, offset ctrl_07
    jmp print_ctrl
c8: cmp bl, 8
    jne c9
    mov dx, offset ctrl_08
    jmp print_ctrl
c9: cmp bl, 9
    jne c10
    mov dx, offset ctrl_09
    jmp print_ctrl
c10: cmp bl, 10
    jne c11
    mov dx, offset ctrl_0A
    jmp print_ctrl
c11: cmp bl, 11
    jne c12
    mov dx, offset ctrl_0B
    jmp print_ctrl
c12: cmp bl, 12
    jne c13
    mov dx, offset ctrl_0C
    jmp print_ctrl
c13: cmp bl, 13
    jne c14
    mov dx, offset ctrl_0D
    jmp print_ctrl
c14: cmp bl, 14
    jne c15
    mov dx, offset ctrl_0E
    jmp print_ctrl
c15: cmp bl, 15
    jne c16
    mov dx, offset ctrl_0F
    jmp print_ctrl
c16: cmp bl, 16
    jne c17
    mov dx, offset ctrl_10
    jmp print_ctrl
c17: cmp bl, 17
    jne c18
    mov dx, offset ctrl_11
    jmp print_ctrl
c18: cmp bl, 18
    jne c19
    mov dx, offset ctrl_12
    jmp print_ctrl
c19: cmp bl, 19
    jne c20
    mov dx, offset ctrl_13
    jmp print_ctrl
c20: cmp bl, 20
    jne c21
    mov dx, offset ctrl_14
    jmp print_ctrl
c21: cmp bl, 21
    jne c22
    mov dx, offset ctrl_15
    jmp print_ctrl
c22: cmp bl, 22
    jne c23
    mov dx, offset ctrl_16
    jmp print_ctrl
c23: cmp bl, 23
    jne c24
    mov dx, offset ctrl_17
    jmp print_ctrl
c24: cmp bl, 24
    jne c25
    mov dx, offset ctrl_18
    jmp print_ctrl
c25: cmp bl, 25
    jne c26
    mov dx, offset ctrl_19
    jmp print_ctrl
c26: cmp bl, 26
    jne c27
    mov dx, offset ctrl_1A
    jmp print_ctrl
c27: cmp bl, 27
    jne c28
    mov dx, offset ctrl_1B
    jmp print_ctrl
c28: cmp bl, 28
    jne c29
    mov dx, offset ctrl_1C
    jmp print_ctrl
c29: cmp bl, 29
    jne c30
    mov dx, offset ctrl_1D
    jmp print_ctrl
c30: cmp bl, 30
    jne c31
    mov dx, offset ctrl_1E
    jmp print_ctrl
c31: cmp bl, 31
    jne c32
    mov dx, offset ctrl_1F
    jmp print_ctrl
c32: jmp normal_char

print_del:
    mov dx, offset ctrl_7F

print_ctrl:
    mov ah, 09h
    int 21h
    jmp after_char

normal_char:
    pop dx
    pop cx
    pop bx
    push bx
    push cx
    push dx

    mov dl, bl
    mov ah, 02h
    int 21h

after_char:

    mov dx, offset colon
    mov ah, 09h
    int 21h

    pop dx
    pop cx
    pop bx
    
    push bx
    push cx
    push dx
    
    mov al, bl
    shr al, 4
    xor ah, ah
    mov si, ax
    mov dl, hex_chars[si]
    mov ah, 02h
    int 21h
    
    mov al, bl
    and al, 0Fh
    xor ah, ah
    mov si, ax
    mov dl, hex_chars[si]
    mov ah, 02h
    int 21h
    
    mov dx, offset space
    mov ah, 09h
    int 21h
    
    pop dx
    pop cx
    pop bx
    
    inc dx

    cmp dx, 8
    jl skip_newline
    
    push dx
    mov dx, offset new_line
    mov ah, 09h
    int 21h
    pop dx
    mov dx, 0

skip_newline:
    inc bx
    dec cx
    cmp cx, 0
    jne main_loop

    mov dx, offset new_line
    mov ah, 09h
    int 21h

exit:
    mov ax, 4c00h
    int 21h

code ends
end start