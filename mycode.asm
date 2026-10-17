ORG 100h

    MOV BX, 1234h

    MOV AL, 5
    CMP AL, 5

    JE LABEL1    

    JMP EXIT    

LABEL1:    
    MOV AX, BX    

EXIT:
    HLT   
