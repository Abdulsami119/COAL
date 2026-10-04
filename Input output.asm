.MODEL SMALL
.STACK 100H

.DATA
    msg1 DB 'Enter your name: $'
    msg2 DB 13,10,'Your name is: $'
    msg3 DB 13,10,'Enter a character: $'
    msg4 DB 13,10,'Your character is: $'

    input DB 30 DUP('$')     ; Space for 30 characters

.CODE
MAIN PROC

MOV AX, @DATA
MOV DS, AX

; Output a string
MOV DX, OFFSET msg1
MOV AH, 09H
INT 21H

; SI points to the first position of input
MOV SI, OFFSET input

again:

; Input one character
MOV AH, 01H
INT 21H

; Check if user pressed Enter
CMP AL, 13
JE stringDone

; Store the character in input
MOV [SI], AL

; Move to the next position
INC SI

; Take the next character
JMP again

stringDone:

; Output a string
MOV DX, OFFSET msg2
MOV AH, 09H
INT 21H

; Output the entered string
MOV DX, OFFSET input
MOV AH, 09H
INT 21H

; Output a string
MOV DX, OFFSET msg3
MOV AH, 09H
INT 21H

; Input one character
MOV AH, 01H
INT 21H

; Save the character
MOV BL, AL

; Output a string
MOV DX, OFFSET msg4
MOV AH, 09H
INT 21H

; Output the character
MOV DL, BL
MOV AH, 02H
INT 21H

; End program
MOV AH, 4CH
INT 21H

MAIN ENDP
END MAINMAIN