.MODEL SMALL
.STACK 100H

.DATA

.CODE
MAIN PROC

MOV AX, 10
MOV BX, 10

CMP AX, BX       ; Compare AX and BX
                 ; Works like AX - BX
                 ; Does not change AX or BX

JE equal         ; If AX == BX, jump to equal

; These statements run if AX != BX
MOV CX, 0
MOV DX, 5
MOV SI, 10

JMP done         ; Skip the equal part

equal:
; These statements run if AX == BX
MOV CX, 1
MOV DX, 20
MOV SI, 30

done:

MOV AH, 4CH
INT 21H

MAIN ENDP
END MAIN