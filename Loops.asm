.MODEL SMALL
.STACK 100H

.DATA
    array DB 2, 4, 6, 8, 10

.CODE
MAIN PROC

MOV SI, OFFSET array     ; SI gets address of first element
MOV CX, 5                ; CX = number of times loop will run

again:
MOV AL, [SI]             ; AL gets current array element
INC SI                   ; Move SI to next element

LOOP again               ; CX = CX - 1
                         ; If CX != 0, jump to again

MOV AH, 4CH
INT 21H

MAIN ENDP
END MAIN