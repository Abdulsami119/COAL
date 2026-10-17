                     .MODEL SMALL
.STACK 100H

.DATA

; ============================================================
;                    COLORS
; ============================================================

; 1F = Bright White on Blue
; 1E = Yellow on Blue
; 1A = Green on Blue
; 1C = Red on Blue
; 1B = Cyan on Blue

COLOR_NORMAL EQU 1FH
COLOR_TITLE  EQU 1EH
COLOR_GREEN  EQU 1AH
COLOR_RED    EQU 1CH
COLOR_CYAN   EQU 1BH


; ============================================================
;                    GENERAL STRINGS
; ============================================================

NL              DB 13,10,'$'

LINE            DB '+------------------------------------------------------------+$'
BLANK_LINE      DB '|                                                            |$'

TITLE1          DB '|             STUDENT MANAGEMENT SYSTEM                    |$'
TITLE2          DB '|                  EMU8086 PROJECT                         |$'

LOGIN_TITLE     DB '|                    LOGIN PANEL                           |$'

USERNAME_MSG    DB '  Username : $'
PASSWORD_MSG    DB '  Password : $'

LOGIN_ERROR     DB '  Invalid username or password!$'
LOGIN_TRIES     DB '  Maximum login attempts reached.$'

WELCOME_MSG     DB '  Login successful. Welcome!$'

MENU_TITLE      DB '|                      MAIN MENU                           |$'
MENU1           DB '|  [1] Add New Student                                    |$'
MENU2           DB '|  [2] Display All Students                               |$'
MENU3           DB '|  [3] Search Student                                     |$'
MENU4           DB '|  [4] Class Statistics                                   |$'
MENU5           DB '|  [5] Exit                                               |$'

CHOICE_MSG      DB '  Enter choice: $'

INVALID_CHOICE  DB '  Invalid choice!$'

NO_STUDENT      DB '  No student records available.$'
MAX_STUDENT     DB '  Maximum of 5 students reached.$'

ADD_TITLE       DB '|                    ADD STUDENT                          |$'
DISPLAY_TITLE   DB '|                  STUDENT RECORDS                        |$'
SEARCH_TITLE    DB '|                  SEARCH STUDENT                         |$'
STATS_TITLE     DB '|                  CLASS STATISTICS                       |$'

ROLL_MSG        DB '  Roll Number (1-999): $'
NAME_MSG        DB '  Student Name: $'

SUB1_MSG        DB '  Subject 1 Marks (0-100): $'
SUB2_MSG        DB '  Subject 2 Marks (0-100): $'
SUB3_MSG        DB '  Subject 3 Marks (0-100): $'

INVALID_MARK    DB '  Marks must be between 0 and 100.$'
INVALID_ROLL    DB '  Roll number must be between 1 and 999.$'

SAVED_MSG       DB '  Student record saved successfully!$'

ROLL_OUT        DB '  Roll Number : $'
NAME_OUT        DB '  Name        : $'
SUB1_OUT        DB '  Subject 1   : $'
SUB2_OUT        DB '  Subject 2   : $'
SUB3_OUT        DB '  Subject 3   : $'
TOTAL_OUT       DB '  Total       : $'
AVERAGE_OUT     DB '  Average     : $'
PERCENT_OUT     DB '  Percentage  : $'
GRADE_OUT       DB '  Grade       : $'
RESULT_OUT      DB '  Result      : $'

PASS_TEXT       DB 'PASS$'
FAIL_TEXT       DB 'FAIL$'

GRADE_A         DB 'A$'
GRADE_B         DB 'B$'
GRADE_C         DB 'C$'
GRADE_D         DB 'D$'
GRADE_F         DB 'F$'

SEARCH_ROLL     DB '  Enter roll number to search: $'
FOUND_MSG       DB '  Student Found!$'
NOT_FOUND       DB '  Student not found.$'

STAT_TOTAL      DB '  Students Registered : $'
STAT_AVG        DB '  Class Average       : $'
STAT_HIGH       DB '  Highest Total       : $'
STAT_LOW        DB '  Lowest Total        : $'

PRESS_KEY       DB '  Press any key to continue...$'

EXIT_MSG        DB '|              Thank you for using the                    |$'
EXIT_MSG2       DB '|             Student Management System!                  |$'


; ============================================================
;                    LOGIN DATA
; ============================================================

USERNAME        DB 'admin'
PASSWORD        DB '1234'

USER_BUFFER     DB 15
                DB 0
                DB 15 DUP(0)

PASS_BUFFER     DB 10 DUP(0)

LOGIN_COUNT     DB 0


; ============================================================
;                    STUDENT DATA
; ============================================================

MAX_STUDENTS    EQU 5
NAME_SIZE       EQU 21

STUDENT_COUNT   DB 0

; 5 roll numbers
ROLLS           DW 5 DUP(0)

; 5 names x 21 characters
NAMES           DB 105 DUP('$')

; marks
MARK1           DB 5 DUP(0)
MARK2           DB 5 DUP(0)
MARK3           DB 5 DUP(0)


; temporary name input
NAME_BUFFER     DB 20
                DB 0
                DB 20 DUP('$')


; temporary calculations
TEMP_TOTAL      DW 0
TEMP_AVG        DW 0


.CODE


; ============================================================
;                    MAIN
; ============================================================

MAIN PROC

    MOV AX,@DATA
    MOV DS,AX

    CLD

    CALL SET_VIDEO

    CALL LOGIN

    CMP AL,1
    JNE PROGRAM_EXIT

MAIN_MENU:

    CALL CLEAR_SCREEN
    CALL DRAW_HEADER
    CALL DRAW_MENU

    LEA DX,CHOICE_MSG
    CALL PRINT_STRING

    MOV AH,01H
    INT 21H

    CMP AL,'1'
    JE ADD_STUDENT

    CMP AL,'2'
    JE DISPLAY_STUDENTS

    CMP AL,'3'
    JE SEARCH_STUDENT

    CMP AL,'4'
    JE CLASS_STATISTICS

    CMP AL,'5'
    JE PROGRAM_EXIT

    CALL NEW_LINE

    LEA DX,INVALID_CHOICE
    CALL PRINT_STRING

    CALL PAUSE

    JMP MAIN_MENU


; ============================================================
;                    ADD STUDENT
; ============================================================

ADD_STUDENT:

    MOV AL,STUDENT_COUNT
    CMP AL,MAX_STUDENTS
    JAE MAX_REACHED

    CALL CLEAR_SCREEN
    CALL DRAW_HEADER

    LEA DX,ADD_TITLE
    CALL PRINT_TITLE

    CALL NEW_LINE
    LEA DX,BLANK_LINE
    CALL PRINT_STRING
    CALL NEW_LINE

; ---------------- ROLL NUMBER ----------------

GET_ROLL:

    LEA DX,ROLL_MSG
    CALL PRINT_STRING

    CALL READ_NUMBER

    CMP AX,1
    JB BAD_ROLL

    CMP AX,999
    JA BAD_ROLL

    ; Store roll number

    MOV BX,AX

    XOR AX,AX
    MOV AL,STUDENT_COUNT

    MOV SI,AX
    SHL SI,1

    MOV ROLLS[SI],BX

    JMP GET_NAME


BAD_ROLL:

    CALL NEW_LINE

    LEA DX,INVALID_ROLL
    CALL PRINT_STRING

    CALL NEW_LINE

    JMP GET_ROLL


; ---------------- NAME ----------------

GET_NAME:

    CALL NEW_LINE

    LEA DX,NAME_MSG
    CALL PRINT_STRING

    LEA DX,NAME_BUFFER
    MOV AH,0AH
    INT 21H

    ; Find destination
    ; STUDENT_COUNT * 21

    XOR AX,AX
    MOV AL,STUDENT_COUNT

    MOV BX,21
    MUL BX

    MOV DI,OFFSET NAMES
    ADD DI,AX

    ; Copy input name

    MOV SI,OFFSET NAME_BUFFER

    XOR CX,CX
    MOV CL,[SI+1]

    XOR BX,BX

COPY_NAME:

    CMP BX,CX
    JAE NAME_DONE

    MOV AL,[SI+2+BX]
    MOV [DI+BX],AL

    INC BX

    JMP COPY_NAME


NAME_DONE:

    MOV BYTE PTR [DI+BX],'$'


; ---------------- SUBJECT 1 ----------------

GET_SUB1:

    CALL NEW_LINE

    LEA DX,SUB1_MSG
    CALL PRINT_STRING

    CALL READ_NUMBER

    CMP AX,100
    JA BAD_SUB1

    MOV SI,OFFSET MARK1

    XOR BX,BX
    MOV BL,STUDENT_COUNT

    MOV [SI+BX],AL

    JMP GET_SUB2


BAD_SUB1:

    CALL NEW_LINE

    LEA DX,INVALID_MARK
    CALL PRINT_STRING

    JMP GET_SUB1


; ---------------- SUBJECT 2 ----------------

GET_SUB2:

    CALL NEW_LINE

    LEA DX,SUB2_MSG
    CALL PRINT_STRING

    CALL READ_NUMBER

    CMP AX,100
    JA BAD_SUB2

    MOV SI,OFFSET MARK2

    XOR BX,BX
    MOV BL,STUDENT_COUNT

    MOV [SI+BX],AL

    JMP GET_SUB3


BAD_SUB2:

    CALL NEW_LINE

    LEA DX,INVALID_MARK
    CALL PRINT_STRING

    JMP GET_SUB2


; ---------------- SUBJECT 3 ----------------

GET_SUB3:

    CALL NEW_LINE

    LEA DX,SUB3_MSG
    CALL PRINT_STRING

    CALL READ_NUMBER

    CMP AX,100
    JA BAD_SUB3

    MOV SI,OFFSET MARK3

    XOR BX,BX
    MOV BL,STUDENT_COUNT

    MOV [SI+BX],AL

    JMP STUDENT_SAVED


BAD_SUB3:

    CALL NEW_LINE

    LEA DX,INVALID_MARK
    CALL PRINT_STRING

    JMP GET_SUB3


; ---------------- SAVE ----------------

STUDENT_SAVED:

    INC STUDENT_COUNT

    CALL NEW_LINE
    CALL NEW_LINE

    LEA DX,SAVED_MSG
    CALL PRINT_STRING

    CALL PAUSE

    JMP MAIN_MENU


MAX_REACHED:

    CALL CLEAR_SCREEN
    CALL DRAW_HEADER

    LEA DX,MAX_STUDENT
    CALL PRINT_STRING

    CALL PAUSE

    JMP MAIN_MENU


; ============================================================
;                    DISPLAY STUDENTS
; ============================================================

DISPLAY_STUDENTS:

    CALL CLEAR_SCREEN
    CALL DRAW_HEADER

    LEA DX,DISPLAY_TITLE
    CALL PRINT_TITLE

    MOV AL,STUDENT_COUNT
    CMP AL,0
    JE DISPLAY_NONE

    XOR SI,SI


DISPLAY_LOOP:

    CALL NEW_LINE
    CALL NEW_LINE

    ; Separator

    LEA DX,LINE
    CALL PRINT_STRING

    CALL NEW_LINE

    ; Student number

    MOV AX,SI
    INC AX

    PUSH SI

    CALL PRINT_NUMBER

    MOV DL,'.'
    MOV AH,02H
    INT 21H

    MOV DL,' '
    INT 21H

    POP SI

    ; Roll number

    LEA DX,ROLL_OUT
    CALL PRINT_STRING

    MOV AX,SI
    SHL AX,1
    MOV BX,AX

    MOV AX,ROLLS[BX]
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Name

    LEA DX,NAME_OUT
    CALL PRINT_STRING

    MOV AX,SI
    MOV BX,21
    MUL BX

    MOV DX,OFFSET NAMES
    ADD DX,AX

    CALL PRINT_STRING

    CALL NEW_LINE

    ; Subject 1

    LEA DX,SUB1_OUT
    CALL PRINT_STRING

    MOV AL,MARK1[SI]
    XOR AH,AH
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Subject 2

    LEA DX,SUB2_OUT
    CALL PRINT_STRING

    MOV AL,MARK2[SI]
    XOR AH,AH
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Subject 3

    LEA DX,SUB3_OUT
    CALL PRINT_STRING

    MOV AL,MARK3[SI]
    XOR AH,AH
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Total

    CALL GET_STUDENT_TOTAL

    LEA DX,TOTAL_OUT
    CALL PRINT_STRING

    MOV AX,TEMP_TOTAL
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Average

    CALL GET_STUDENT_AVERAGE

    LEA DX,AVERAGE_OUT
    CALL PRINT_STRING

    MOV AX,TEMP_AVG
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Percentage

    LEA DX,PERCENT_OUT
    CALL PRINT_STRING

    MOV AX,TEMP_TOTAL

    ; percentage = total / 3
    XOR DX,DX
    MOV BX,3
    DIV BX

    CALL PRINT_NUMBER

    MOV DL,'%'
    MOV AH,02H
    INT 21H

    CALL NEW_LINE

    ; Grade

    LEA DX,GRADE_OUT
    CALL PRINT_STRING

    CALL GET_GRADE

    CALL NEW_LINE

    ; Result

    LEA DX,RESULT_OUT
    CALL PRINT_STRING

    CALL GET_RESULT

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_STRING

    INC SI

    MOV AL,STUDENT_COUNT
    XOR AH,AH

    CMP SI,AX
    JB DISPLAY_LOOP

    CALL PAUSE

    JMP MAIN_MENU


DISPLAY_NONE:

    CALL NEW_LINE

    LEA DX,NO_STUDENT
    CALL PRINT_STRING

    CALL PAUSE

    JMP MAIN_MENU


; ============================================================
;                    SEARCH STUDENT
; ============================================================

SEARCH_STUDENT:

    CALL CLEAR_SCREEN
    CALL DRAW_HEADER

    LEA DX,SEARCH_TITLE
    CALL PRINT_TITLE

    MOV AL,STUDENT_COUNT
    CMP AL,0
    JE SEARCH_NONE

    CALL NEW_LINE

    LEA DX,SEARCH_ROLL
    CALL PRINT_STRING

    CALL READ_NUMBER

    MOV BX,AX

    XOR SI,SI


SEARCH_LOOP:

    MOV AX,SI
    SHL AX,1

    MOV DI,AX

    MOV AX,ROLLS[DI]

    CMP AX,BX
    JE STUDENT_FOUND

    INC SI

    MOV AL,STUDENT_COUNT
    XOR AH,AH

    CMP SI,AX
    JB SEARCH_LOOP

    JMP STUDENT_NOT_FOUND


STUDENT_FOUND:

    CALL NEW_LINE
    CALL NEW_LINE

    LEA DX,FOUND_MSG
    CALL PRINT_STRING

    CALL NEW_LINE
    CALL NEW_LINE

    ; Roll

    LEA DX,ROLL_OUT
    CALL PRINT_STRING

    MOV AX,ROLLS[DI]
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Name

    LEA DX,NAME_OUT
    CALL PRINT_STRING

    MOV AX,SI
    MOV BX,21
    MUL BX

    MOV DX,OFFSET NAMES
    ADD DX,AX

    CALL PRINT_STRING

    CALL NEW_LINE

    ; Subject 1

    LEA DX,SUB1_OUT
    CALL PRINT_STRING

    MOV AL,MARK1[SI]
    XOR AH,AH
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Subject 2

    LEA DX,SUB2_OUT
    CALL PRINT_STRING

    MOV AL,MARK2[SI]
    XOR AH,AH
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Subject 3

    LEA DX,SUB3_OUT
    CALL PRINT_STRING

    MOV AL,MARK3[SI]
    XOR AH,AH
    CALL PRINT_NUMBER

    CALL NEW_LINE

    CALL GET_STUDENT_TOTAL

    LEA DX,TOTAL_OUT
    CALL PRINT_STRING

    MOV AX,TEMP_TOTAL
    CALL PRINT_NUMBER

    CALL NEW_LINE

    CALL GET_STUDENT_AVERAGE

    LEA DX,AVERAGE_OUT
    CALL PRINT_STRING

    MOV AX,TEMP_AVG
    CALL PRINT_NUMBER

    CALL NEW_LINE

    LEA DX,GRADE_OUT
    CALL PRINT_STRING

    CALL GET_GRADE

    CALL NEW_LINE

    LEA DX,RESULT_OUT
    CALL PRINT_STRING

    CALL GET_RESULT

    CALL PAUSE

    JMP MAIN_MENU


STUDENT_NOT_FOUND:

    CALL NEW_LINE
    CALL NEW_LINE

    LEA DX,NOT_FOUND
    CALL PRINT_STRING

    CALL PAUSE

    JMP MAIN_MENU


SEARCH_NONE:

    CALL NEW_LINE

    LEA DX,NO_STUDENT
    CALL PRINT_STRING

    CALL PAUSE

    JMP MAIN_MENU


; ============================================================
;                    CLASS STATISTICS
; ============================================================

CLASS_STATISTICS:

    CALL CLEAR_SCREEN
    CALL DRAW_HEADER

    LEA DX,STATS_TITLE
    CALL PRINT_TITLE

    MOV AL,STUDENT_COUNT
    CMP AL,0
    JE STATS_NONE

    CALL NEW_LINE

    ; Number of students

    LEA DX,STAT_TOTAL
    CALL PRINT_STRING

    XOR AX,AX
    MOV AL,STUDENT_COUNT
    CALL PRINT_NUMBER

    CALL NEW_LINE

    ; Calculate all totals

    XOR SI,SI

    XOR BX,BX
    MOV WORD PTR TEMP_TOTAL,0


STATS_TOTAL_LOOP:

    CALL GET_STUDENT_TOTAL

    MOV AX,TEMP_TOTAL

    ; Store running class sum in DX
    ; Use CX as class sum instead

    INC SI

    MOV AL,STUDENT_COUNT
    XOR AH,AH

    CMP SI,AX
    JB STATS_TOTAL_LOOP

    ; Recalculate class total in CX

    XOR SI,SI
    XOR CX,CX


CLASS_SUM_LOOP:

    CALL GET_STUDENT_TOTAL

    ADD CX,TEMP_TOTAL

    INC SI

    MOV AL,STUDENT_COUNT
    XOR AH,AH

    CMP SI,AX
    JB CLASS_SUM_LOOP


    ; Class average

    LEA DX,STAT_AVG
    CALL PRINT_STRING

    MOV AX,CX
    XOR DX,DX

    XOR BX,BX
    MOV BL,STUDENT_COUNT

    DIV BX

    CALL PRINT_NUMBER

    CALL NEW_LINE


    ; Highest / Lowest

    XOR SI,SI

    CALL GET_STUDENT_TOTAL

    MOV AX,TEMP_TOTAL

    MOV BX,AX
    MOV DX,AX

    INC SI


HIGH_LOW_LOOP:

    MOV AL,STUDENT_COUNT
    XOR AH,AH

    CMP SI,AX
    JAE HIGH_LOW_DONE

    CALL GET_STUDENT_TOTAL

    MOV AX,TEMP_TOTAL

    ; Highest

    CMP AX,BX
    JBE CHECK_LOW

    MOV BX,AX


CHECK_LOW:

    CMP AX,DX
    JAE NEXT_STAT

    MOV DX,AX


NEXT_STAT:

    INC SI
    JMP HIGH_LOW_LOOP


HIGH_LOW_DONE:

    LEA DX,STAT_HIGH
    CALL PRINT_STRING

    MOV AX,BX
    CALL PRINT_NUMBER

    CALL NEW_LINE

    LEA DX,STAT_LOW
    CALL PRINT_STRING

    MOV AX,DX
    CALL PRINT_NUMBER

    CALL PAUSE

    JMP MAIN_MENU


STATS_NONE:

    CALL NEW_LINE

    LEA DX,NO_STUDENT
    CALL PRINT_STRING

    CALL PAUSE

    JMP MAIN_MENU


; ============================================================
;                    LOGIN PROCEDURE
; ============================================================

LOGIN PROC

    MOV LOGIN_COUNT,0


LOGIN_AGAIN:

    CALL CLEAR_SCREEN
    CALL DRAW_LOGIN_SCREEN

    ; Username

    LEA DX,USERNAME_MSG
    CALL PRINT_STRING

    LEA DX,USER_BUFFER
    MOV AH,0AH
    INT 21H

    CALL NEW_LINE

    ; Check username

    CALL CHECK_USERNAME

    CMP AL,1
    JNE LOGIN_FAILED


    ; Password

    LEA DX,PASSWORD_MSG
    CALL PRINT_STRING

    CALL READ_PASSWORD

    CALL NEW_LINE

    CALL CHECK_PASSWORD

    CMP AL,1
    JE LOGIN_SUCCESS


LOGIN_FAILED:

    INC LOGIN_COUNT

    MOV AL,LOGIN_COUNT
    CMP AL,3
    JAE LOGIN_LOCKED

    LEA DX,LOGIN_ERROR
    CALL PRINT_STRING

    CALL PAUSE

    JMP LOGIN_AGAIN


LOGIN_SUCCESS:

    CALL NEW_LINE

    LEA DX,WELCOME_MSG
    CALL PRINT_STRING

    CALL PAUSE

    MOV AL,1
    RET


LOGIN_LOCKED:

    CALL NEW_LINE

    LEA DX,LOGIN_TRIES
    CALL PRINT_STRING

    CALL PAUSE

    MOV AL,0

    RET

LOGIN ENDP


; ============================================================
;                    CHECK USERNAME
; ============================================================

CHECK_USERNAME PROC

    MOV AL,[USER_BUFFER+1]

    CMP AL,5
    JNE USER_BAD

    MOV SI,OFFSET USER_BUFFER+2
    MOV DI,OFFSET USERNAME

    MOV CX,5

USER_COMPARE:

    MOV AL,[SI]
    CMP AL,[DI]
    JNE USER_BAD

    INC SI
    INC DI

    LOOP USER_COMPARE

    MOV AL,1
    RET


USER_BAD:

    MOV AL,0

    RET

CHECK_USERNAME ENDP


; ============================================================
;                    PASSWORD INPUT
; ============================================================

READ_PASSWORD PROC

    MOV DI,OFFSET PASS_BUFFER
    XOR CX,CX


PASSWORD_LOOP:

    MOV AH,08H
    INT 21H

    CMP AL,13
    JE PASSWORD_DONE

    CMP CX,9
    JAE PASSWORD_LOOP

    MOV [DI],AL
    INC DI
    INC CX

    MOV DL,'*'
    MOV AH,02H
    INT 21H

    JMP PASSWORD_LOOP


PASSWORD_DONE:

    MOV BYTE PTR [DI],0

    RET

READ_PASSWORD ENDP


; ============================================================
;                    CHECK PASSWORD
; ============================================================

CHECK_PASSWORD PROC

    MOV SI,OFFSET PASS_BUFFER
    MOV DI,OFFSET PASSWORD

    MOV CX,4

PASSWORD_COMPARE:

    MOV AL,[SI]
    CMP AL,[DI]
    JNE PASSWORD_BAD

    INC SI
    INC DI

    LOOP PASSWORD_COMPARE

    ; Make sure there are exactly 4 characters

    CMP BYTE PTR [SI],0
    JNE PASSWORD_BAD

    MOV AL,1
    RET


PASSWORD_BAD:

    MOV AL,0

    RET

CHECK_PASSWORD ENDP


; ============================================================
;                    GET STUDENT TOTAL
; SI = student index
; ============================================================

GET_STUDENT_TOTAL PROC

    XOR AX,AX

    MOV AL,MARK1[SI]

    XOR DX,DX
    MOV DL,MARK2[SI]

    ADD AX,DX

    XOR DX,DX
    MOV DL,MARK3[SI]

    ADD AX,DX

    MOV TEMP_TOTAL,AX

    RET

GET_STUDENT_TOTAL ENDP


; ============================================================
;                    GET STUDENT AVERAGE
; SI = student index
; ============================================================

GET_STUDENT_AVERAGE PROC

    CALL GET_STUDENT_TOTAL

    MOV AX,TEMP_TOTAL

    XOR DX,DX

    MOV BX,3

    DIV BX

    MOV TEMP_AVG,AX

    RET

GET_STUDENT_AVERAGE ENDP


; ============================================================
;                    GET GRADE
; SI = student index
; ============================================================

GET_GRADE PROC

    CALL GET_STUDENT_AVERAGE

    MOV AX,TEMP_AVG

    CMP AX,90
    JAE GRADE_A_LABEL

    CMP AX,80
    JAE GRADE_B_LABEL

    CMP AX,70
    JAE GRADE_C_LABEL

    CMP AX,60
    JAE GRADE_D_LABEL

    JMP GRADE_F_LABEL


GRADE_A_LABEL:

    LEA DX,GRADE_A
    CALL PRINT_STRING
    RET


GRADE_B_LABEL:

    LEA DX,GRADE_B
    CALL PRINT_STRING
    RET


GRADE_C_LABEL:

    LEA DX,GRADE_C
    CALL PRINT_STRING
    RET


GRADE_D_LABEL:

    LEA DX,GRADE_D
    CALL PRINT_STRING
    RET


GRADE_F_LABEL:

    LEA DX,GRADE_F
    CALL PRINT_STRING

    RET

GET_GRADE ENDP


; ============================================================
;                    GET RESULT
; SI = student index
; ============================================================

GET_RESULT PROC

    MOV AL,MARK1[SI]

    CMP AL,40
    JB RESULT_FAIL

    MOV AL,MARK2[SI]

    CMP AL,40
    JB RESULT_FAIL

    MOV AL,MARK3[SI]

    CMP AL,40
    JB RESULT_FAIL

    LEA DX,PASS_TEXT
    CALL PRINT_STRING

    RET


RESULT_FAIL:

    LEA DX,FAIL_TEXT
    CALL PRINT_STRING

    RET

GET_RESULT ENDP


; ============================================================
;                    DRAW HEADER
; ============================================================

DRAW_HEADER PROC

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,TITLE1
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,TITLE2
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE
    CALL NEW_LINE

    RET

DRAW_HEADER ENDP


; ============================================================
;                    DRAW LOGIN
; ============================================================

DRAW_LOGIN_SCREEN PROC

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,LOGIN_TITLE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE
    CALL NEW_LINE

    RET

DRAW_LOGIN_SCREEN ENDP


; ============================================================
;                    DRAW MENU
; ============================================================

DRAW_MENU PROC

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,MENU_TITLE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,MENU1
    CALL PRINT_COLOR

    CALL NEW_LINE

    LEA DX,MENU2
    CALL PRINT_COLOR

    CALL NEW_LINE

    LEA DX,MENU3
    CALL PRINT_COLOR

    CALL NEW_LINE

    LEA DX,MENU4
    CALL PRINT_COLOR

    CALL NEW_LINE

    LEA DX,MENU5
    CALL PRINT_COLOR

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE
    CALL NEW_LINE

    RET

DRAW_MENU ENDP


; ============================================================
;                    PRINT TITLE
; ============================================================

PRINT_TITLE PROC

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    ; DX already changed by above call, reload title
    PUSH AX
    PUSH BX

    ; Caller must reload its title after using this procedure
    POP BX
    POP AX

    RET

PRINT_TITLE ENDP


; ============================================================
;                    PRINT STRING
; ============================================================

PRINT_STRING PROC

    MOV AH,09H
    INT 21H

    RET

PRINT_STRING ENDP


; ============================================================
;                    PRINT COLOR STRING
; ============================================================

PRINT_COLOR PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI,DX

COLOR_LOOP:

    LODSB

    CMP AL,'$'
    JE COLOR_DONE

    MOV AH,09H
    MOV BH,0
    MOV CX,1

    INT 10H

    JMP COLOR_LOOP


COLOR_DONE:

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    RET

PRINT_COLOR ENDP


; ============================================================
;                    PRINT TITLE COLOR
; ============================================================

PRINT_COLOR_TITLE PROC

    PUSH BX

    MOV BL,COLOR_TITLE

    CALL PRINT_COLOR

    POP BX

    RET

PRINT_COLOR_TITLE ENDP


; ============================================================
;                    READ NUMBER
; Returns AX
; ============================================================

READ_NUMBER PROC

    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX,BX


NUMBER_LOOP:

    MOV AH,01H
    INT 21H

    CMP AL,13
    JE NUMBER_DONE

    CMP AL,'0'
    JB NUMBER_LOOP

    CMP AL,'9'
    JA NUMBER_LOOP

    SUB AL,'0'

    MOV DL,AL
    XOR DH,DH

    MOV AX,BX

    MOV CX,10

    MUL CX

    ADD AX,DX

    MOV BX,AX

    JMP NUMBER_LOOP


NUMBER_DONE:

    MOV AX,BX

    POP DX
    POP CX
    POP BX

    RET

READ_NUMBER ENDP


; ============================================================
;                    PRINT NUMBER
; AX = number
; ============================================================

PRINT_NUMBER PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX,0
    JNE CONVERT_NUMBER

    MOV DL,'0'

    MOV AH,02H
    INT 21H

    JMP NUMBER_PRINT_DONE


CONVERT_NUMBER:

    XOR CX,CX

    MOV BX,10


DIVIDE_NUMBER:

    XOR DX,DX

    DIV BX

    PUSH DX

    INC CX

    CMP AX,0
    JNE DIVIDE_NUMBER


PRINT_DIGITS:

    POP DX

    ADD DL,'0'

    MOV AH,02H
    INT 21H

    LOOP PRINT_DIGITS


NUMBER_PRINT_DONE:

    POP DX
    POP CX
    POP BX
    POP AX

    RET

PRINT_NUMBER ENDP


; ============================================================
;                    NEW LINE
; ============================================================

NEW_LINE PROC

    PUSH AX
    PUSH DX

    LEA DX,NL

    MOV AH,09H
    INT 21H

    POP DX
    POP AX

    RET

NEW_LINE ENDP


; ============================================================
;                    PAUSE
; ============================================================

PAUSE PROC

    CALL NEW_LINE
    CALL NEW_LINE

    LEA DX,PRESS_KEY
    CALL PRINT_STRING

    MOV AH,01H
    INT 21H

    RET

PAUSE ENDP


; ============================================================
;                    CLEAR SCREEN
; ============================================================

CLEAR_SCREEN PROC

    MOV AX,0600H

    ; White text on blue background
    MOV BH,1FH

    MOV CX,0000H
    MOV DX,184FH

    INT 10H

    MOV AH,02H
    MOV BH,00H
    MOV DX,0000H

    INT 10H

    RET

CLEAR_SCREEN ENDP


; ============================================================
;                    SET VIDEO MODE
; ============================================================

SET_VIDEO PROC

    MOV AX,0003H
    INT 10H

    RET

SET_VIDEO ENDP


; ============================================================
;                    PROGRAM EXIT
; ============================================================

PROGRAM_EXIT:

    CALL CLEAR_SCREEN

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,EXIT_MSG
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,EXIT_MSG2
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE

    LEA DX,LINE
    CALL PRINT_COLOR_TITLE

    CALL NEW_LINE
    CALL NEW_LINE

    MOV AH,4CH
    MOV AL,00H
    INT 21H


END MAIN
