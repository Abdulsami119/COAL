                                                           .model small
.stack 100h

.data
num1 dw 0025h
num2 dw 0015h
result dw ?

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ax, num1
    mov result, ax

    mov ax, num1
    mov bx, num2

    add ax, bx

    mov result, ax

    mov ax, num1
    mov bx, num2

    sub ax, bx

    mov result, ax

    mov ah, 4Ch
    int 21h

main endp
end main