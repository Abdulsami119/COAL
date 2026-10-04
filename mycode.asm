.MODEL SMALL
.STACK 100H

.DATA  ;used to declare variables
    num1 DB 5    ;DB=Define byte, 8 bit=1 byte    
    num2 DW 10   ;DW=Define word, 16 bit=2 bytes   
    num3 DB 1
    result DB 0
    char1 DB 'S' ;DB can store character
    char2 DB 'Sami' ;char1 became array 
    array DB 2, 4, 6, 8, 10  ; array where each element is 8 bit, total = 5 bytes

.CODE
MAIN PROC

MOV AX, 5h  ;h means hexa decimal value
MOV BX, 10  ;nothing means decimal
ADD AX, BX   ;AX = AX + BX
SUB AX, BX   ;AX = AX - BX 
INC AX       ;AX = AX + 1
DEC AX       ;AX = AX - 1

;MOV AX, AL  cant do that cuz AX is 16 bit while AL is 8 bit
MOV AL, num1 ;both are 8 bit
MOV AX, num2 ;both are 16 bit

;MOV num1, num3 cant do that directly
MOV AL, num3
MOV num1,AL
;similartly
MOV AL, num1
ADD AL, num3
MOV result, AL

MOV SI, OFFSET array ;means SI gets the address of the first element
MOV AX, SI      ; AX gets the VALUE of SI
MOV AL, [SI]    ; AL gets the VALUE stored at the ADDRESS in SI, gets array[0]
MOV AL, [SI+1]  ; 1 byte forward, gets array[1]


MOV AH, 4CH
INT 21H

MAIN ENDP
END MAIN