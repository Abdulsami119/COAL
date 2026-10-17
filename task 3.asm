.model small
.stack 100h
.data

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ax, 0005h
    mov bx, 000Ah

    xchg ax, bx

    mov ah, 4Ch
    int 21h

main endp
end main