; ================= CMP, FLAGS AND JUMPS =================

; CMP is used to compare two values
; CMP AX, BX works like AX - BX
; BUT it does not change AX or BX
; It only changes the FLAGS

MOV AX, 10
MOV BX, 10

CMP AX, BX       ; internally does AX - BX = 10 - 10 = 0
; since result is 0, ZF (Zero Flag) = 1

JE equal         ; JE = Jump if Equal
; jumps when ZF = 1

MOV CX, 0        ; this will be skipped

equal:
MOV CX, 1        ; CX = 1 because AX and BX were equal

; ---------------- JNE ----------------

MOV AX, 10
MOV BX, 5

CMP AX, BX       ; AX - BX = 10 - 5 = 5
; result is not 0, so ZF = 0

JNE notEqual     ; JNE = Jump if Not Equal
; jumps when ZF = 0

MOV CX, 0        ; skipped because values are not equal

notEqual:
MOV CX, 1

; ---------------- JG ----------------

MOV AX, 10
MOV BX, 5

CMP AX, BX       ; compare AX and BX
; 10 is greater than 5

JG greater       ; JG = Jump if Greater

MOV CX, 0        ; runs if AX is NOT greater

greater:
MOV CX, 1        ; runs because AX > BX

; ---------------- JL ----------------

MOV AX, 3
MOV BX, 8

CMP AX, BX       ; compare AX and BX
; 3 is less than 8

JL smaller       ; JL = Jump if Less

MOV CX, 0        ; runs if AX is NOT less

smaller:
MOV CX, 1        ; runs because AX < BX

; ---------------- JMP ----------------

MOV AX, 5

JMP skip         ; JMP always jumps, no condition is checked

MOV AX, 10       ; this line will be skipped

skip:
MOV BX, 20

; ---------------- FLAGS ----------------

; ZF = Zero Flag
; ZF = 1 when the result is zero
; ZF = 0 when the result is not zero

; CF = Carry Flag
; mainly used for unsigned arithmetic

; SF = Sign Flag
; SF = 1 when the result is negative
; SF = 0 when the result is positive

; OF = Overflow Flag
; indicates signed arithmetic overflow

; ---------------- IMPORTANT JUMPS ----------------

; JE  = Jump if Equal
; JNE = Jump if Not Equal
; JG  = Jump if Greater
; JL  = Jump if Less
; JGE = Jump if Greater or Equal
; JLE = Jump if Less or Equal
; JMP = Unconditional Jump
;      (always jumps)

; General pattern:

; CMP AX, BX
; JE  label

; means:
; Compare AX and BX
; If AX == BX, jump to label

MOV AH, 4CH
INT 21H
