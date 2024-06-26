; * ROGER ALAMANAC, DANIEL CASAS, 2024 (ENTI-UB)

; **********************************
; DECLARACIO DE VARIABLES I TECLES
; **********************************

SGROUP 		GROUP 	CODE_SEG, DATA_SEG
			ASSUME 	CS:SGROUP, DS:SGROUP, SS:SGROUP

    TRUE  EQU 1
    FALSE EQU 0

; CONTROL DE LES BARRES
    ASCII_SPECIAL_KEY EQU 00
; JUGADOR 1
    ASCII_UP_ARROW       EQU 048h ; Tecla de flecha hacia arriba
    ASCII_DOWN_ARROW     EQU 050h ; Tecla de flecha hacia abajo
    ASCII_QUIT           EQU 070h ; 'p'
; JUGADOR 2
    ASCII_w              EQU 077h    ; VA CAP ADALT AMB LA 'w'
    ASCII_s              EQU 073h    ; VA CAP ABAIX AMB LA 's'


; ASCII / ATRR CODES PER PINTAR LA BARRA DE JUGADOR 1
    ASCII_BARRA1        EQU 020h ; 020h es l'espai en blanc en hexadecimal del codi ascii per fer la barra 
    ATTR_BARRA1         EQU 070h ; Asignem el color de la barra 
    ASCII_BARRA2        EQU 020h
    ATTR_BARRA2         EQU 070h
    MIN_BAR_POSITION EQU 1 ; Posici�n m�nima de la barra
    MAX_BAR_POSITION EQU SCREEN_MAX_ROWS - 2 ;

; ASCII / ATTR CODES PER PINTAR LA PILOTA
    ASCII_BALL      EQU 02Ah ;EL SIMBOL DE LA PILOTA SERA UN '*'
    ATTR_BALL       EQU 004h

; ASCII / ATTR CODES PER PINTAR LA PILOTA 2
    ASCII_BALL2      EQU 02Ah ;EL SIMBOL DE LA PILOTA SERA UN '*'
    ATTR_BALL2       EQU 001h


; ASCII / ATTR CODES PER PINTAR ELS BLOCS DESTRUIBLES
    ASCII_BRICK     EQU 05Fh    ; Es pot posar el 020h tamb�, s�n espais
    ATTR_BRICK_BLUE EQU 09Fh
    ATTR_BRICK_RED EQU 0C4h
    ATTR_BRICK_GREEN   EQU 020h
    ATTR_BRICK_YELLOW EQU 0ECh

; ASCII / ATTR PER PINTAR ELS LÍMITS DEL CAMP
    ASCII_FIELD         EQU 020h
    ATTR_FIELD          EQU 070h
    ASCII_NUMBER_ZERO   EQU 030h


; CURSOR
    CURSOR_SIZE_HIDE EQU 02607h  ; BIT 5 OF CH = 1 MEANS HIDE CURSOR
    CURSOR_SIZE_SHOW EQU 00607h
    
; ASCII

 ASCII_YES_UPPERCASE      EQU 059h
 ASCII_YES_LOWERCASE      EQU 079h

; COLOREJAR DIMENSIONS DE LA PANTALLA EN NOMBRE DE CARACTERS
    SCREEN_MAX_ROWS EQU 25              
    SCREEN_MAX_COLS EQU 80

; DIMENSIONS DEL CAMP
    FIELD_R1 EQU 0
    FIELD_R2 EQU SCREEN_MAX_ROWS -1
    FIELD_C1 EQU 1
    FIELD_C2 EQU SCREEN_MAX_COLS-1

;*************************
;  CODI EXECUTABLE (MAIN)
;*************************

CODE_SEG	SEGMENT PUBLIC
   ORG 100h; Indica on comen�a l'execuci�

MAIN 	PROC 	NEAR

    MAIN_GO:

       CALL INIT_GAME
       CALL INIT_BALLS
       CALL INIT_SCREEN
       CALL HIDE_CURSOR
       CALL DRAW_FIELD
       CALL UPDATE_SCREEN

      MOV DH, SCREEN_MAX_ROWS/2
      MOV DL, SCREEN_MAX_COLS/2

    MAIN_LOOP:

       CMP [END_GAME], TRUE
       JZ END_PROG
      CALL PRINT_BRICK
      CALL DRAW_BALLS

      ; Comprovar si una tecla es pot llegir
      MOV AH, 0Bh
      INT 21h
      CMP AL, 0
      JZ MAIN_LOOP

      CALL READ_CHAR ; si hi ha tecla disponible, llegeix

      ; Comprovar si el joc s'acaba
      CMP AL, ASCII_QUIT
      JZ END_PROG

      ; Comprovar si es una tecla especial
      CMP AL, ASCII_SPECIAL_KEY
      JNZ CHECK_PLAYER_KEYS

      CALL READ_CHAR

      ;Comen�ar el joc
      MOV [START_GAME], TRUE

  CHECK_PLAYER_KEYS:
    CMP AL, ASCII_SPECIAL_KEY
    JNZ CHECK_PLAYER1_KEYS

    ; Comprovar si es una tecla de movimient del jugador 1
    CHECK_PLAYER1_KEYS:
    CMP AL, ASCII_w
    JZ MOVE_BAR1_UP
    CMP AL, ASCII_s
    JZ MOVE_BAR1_DOWN
    JMP CHECK_PLAYER2_KEYS

    ; Comprovar si es una tecla de movimient del jugador 2
    CHECK_PLAYER2_KEYS:
    CMP AL, ASCII_UP_ARROW
    JZ MOVE_BAR2_UP
    CMP AL, ASCII_DOWN_ARROW
    JZ MOVE_BAR2_DOWN
    JMP MAIN_LOOP

; Ll�gica per mantenir las barres dins dels l�mits de la pantalla:
; Funci� per moure la barra del jugador 1 cap a dalt
MOVE_BAR1_UP:
    DEC POS_BAR1
    CMP POS_BAR1, MIN_BAR_POSITION ; Comprobar si la posici�n es menor que el l�mite m�nimo
    JL SET_BAR1_MIN_POSITION ; Si es menor, establecer la posici�n en el l�mite m�nimo
    JMP UPDATE_SCREEN

; Funci� per moure la barra del jugador 1 cap a baix
MOVE_BAR1_DOWN:
    INC POS_BAR1
    CMP POS_BAR1, MAX_BAR_POSITION ; Comprovar si la posici� es major que el l�mit m�xim
    JG SET_BAR1_MAX_POSITION ; Si es major, establir la posici� en el l�mit m�xim
    JMP UPDATE_SCREEN

; Funci� per moure la barra del jugador 2 cap a dalt
MOVE_BAR2_UP:
    DEC POS_BAR2
    CMP POS_BAR2, MIN_BAR_POSITION ; Comprobar si la posici�n es menor que el l�mite m�nimo
    JL SET_BAR2_MIN_POSITION ; Si es menor, establecer la posici�n en el l�mite m�nimo
    JMP UPDATE_SCREEN

; Funci� per moure la barra del jugador 2 cap a baix
MOVE_BAR2_DOWN:
    INC POS_BAR2
    CMP POS_BAR2, MAX_BAR_POSITION ; Comprobar si la posici�n es mayor que el l�mite m�ximo
    JG SET_BAR2_MAX_POSITION ; Si es mayor, establecer la posici�n en el l�mite m�ximo
    JMP UPDATE_SCREEN

; Ll�gica per establir la posici� de la barra 1 en el l�mit m�nim
SET_BAR1_MIN_POSITION:
    MOV POS_BAR1, MIN_BAR_POSITION
    JMP UPDATE_SCREEN

; Ll�gica per establir la posici� de la barra 1 en el l�mit m�xim
SET_BAR1_MAX_POSITION:
    MOV POS_BAR1, MAX_BAR_POSITION
    JMP UPDATE_SCREEN

; Ll�gica per establir la posici� de la barra 2 en el l�mit m�nim
SET_BAR2_MIN_POSITION:
    MOV POS_BAR2, MIN_BAR_POSITION
    JMP UPDATE_SCREEN

; Ll�gica per establir la posici� de la barra 2 en el l�mit m�xim
SET_BAR2_MAX_POSITION:
    MOV POS_BAR2, MAX_BAR_POSITION
    JMP UPDATE_SCREEN

; Ll�gica per actualizar la pantalla amb les noves posicions de les barres
UPDATE_SCREEN:
    CALL INIT_SCREEN
    CALL DRAW_FIELD
    CALL PRINT_BAR1
    CALL PRINT_BAR2
    JMP MAIN_LOOP
      
      JMP MAIN_LOOP

END_PROG:
      CALL RESTORE_TIMER_INTERRUPT
      CALL SHOW_CURSOR
      CALL PRINT_SCORE_STRING
      CALL PRINT_SCORE
      CALL PRINT_PLAY_AGAIN_STRING
      
      CALL READ_CHAR

      CMP AL, ASCII_YES_UPPERCASE
      JZ MAIN_GO
      CMP AL, ASCII_YES_LOWERCASE
      JZ MAIN_GO

	INT 20h		

MAIN ENDP

; *******************************************************************************************************
; ****************************************
; Set screen to mode 3 (80x25, color) and 
; clears the screen
; Entry: 
;   -
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   Screen size: SCREEN_MAX_ROWS, SCREEN_MAX_COLS
; Calls:
;   int 10h, service AH=0
;   int 10h, service AH=6
; ****************************************
PUBLIC INIT_SCREEN
INIT_SCREEN	PROC NEAR

      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX

      ; Set screen mode
      MOV AL,3
      MOV AH,0
      INT 10h

      ; Clear screen
      XOR AL, AL
      XOR CX, CX
      MOV DH, SCREEN_MAX_ROWS
      MOV DL, SCREEN_MAX_COLS
      MOV BH, 7
      MOV AH, 6
      INT 10h
      
      POP DX      
      POP CX      
      POP BX      
      POP AX      
	RET

INIT_SCREEN		ENDP
; *******************************************************************************************************
; ****************************************
; Reset internal variables
; Entry: 
;   
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   INC_ROW memory variable
;   INC_COL memory variable
;   DIV_SPEED memory variable
;   NUM_TILES memory variable
;   START_GAME memory variable
;   END_GAME memory variable
; Calls:
;   -
; ****************************************
                  PUBLIC  INIT_GAME
INIT_GAME         PROC    NEAR

    MOV [INC_ROW], 0
    MOV [INC_COL], 0

    MOV [DIV_SPEED], 10

    MOV [NUM_TILES], 0
    
    MOV [START_GAME], FALSE
    MOV [END_GAME], FALSE

    RET
INIT_GAME	ENDP	
; *******************************************************************************************************
; ****************************************
; Reads char from keyboard
; If char is not available, blocks until a key is pressed
; The char is not output to screen
; Entry: 
;
; Returns:
;   AL: ASCII CODE
;   AH: ATTRIBUTE
; Modifies:
;   
; Uses: 
;   
; Calls:
;   
; ****************************************
PUBLIC  READ_CHAR
READ_CHAR PROC NEAR

    MOV AH, 8
    INT 21h

    RET
      
READ_CHAR ENDP
; *******************************************************************************************************
; ANEM A DIBUIXAR EL CAMP
; ****************************************
; Draws the rectangular field of the game
; Entry: 
; 
; Returns:
;   
; Modifies:
;   
; Uses: 
;   Coordinates of the rectangle: 
;    left - top: (FIELD_R1, FIELD_C1) 
;    right - bottom: (FIELD_R2, FIELD_C2)
;   Character: ASCII_FIELD
;   Attribute: ATTR_FIELD
; Calls:
;   PRINT_CHAR_ATTR
; ****************************************
PUBLIC DRAW_FIELD
DRAW_FIELD PROC NEAR

    PUSH AX
    PUSH BX
    PUSH DX

    MOV AL, ASCII_FIELD
    MOV BL, ATTR_FIELD

    MOV DL, FIELD_C2
    UP_DOWN_SCREEN_LIMIT:
    MOV DH, FIELD_R1
    CALL MOVE_CURSOR
    CALL PRINT_CHAR_ATTR

    MOV DH, FIELD_R2
    CALL MOVE_CURSOR
    CALL PRINT_CHAR_ATTR

    DEC DL
    CMP DL, FIELD_C1
    JNS UP_DOWN_SCREEN_LIMIT

    MOV DH, FIELD_R2
    LEFT_RIGHT_SCREEN_LIMIT:
    MOV DL, FIELD_C1
    CALL MOVE_CURSOR
    CALL PRINT_CHAR_ATTR

    MOV DL, FIELD_C2
    CALL MOVE_CURSOR
    CALL PRINT_CHAR_ATTR

    DEC DH
    CMP DH, FIELD_R1
    JNS LEFT_RIGHT_SCREEN_LIMIT
                 
    POP DX
    POP BX
    POP AX
    RET

DRAW_FIELD       ENDP
; *******************************************************************************************************
; FUNCIÓ PER PRINTAR UN CHAR ATTR
; ****************************************
; Prints character and attribute in the 
; current cursor position, page 0 
; Keeps the cursor position
; Entry: 
;   AL: ASCII to print
;   BL: ATTRIBUTE to print
; Returns:
;   
; Modifies:
;   
; Uses: 
;
; Calls:
;   int 10h, service AH=9
; Nota:
;   Compatibility problem when debugging
; ****************************************

; *******************************************************************************************************
; ****************************************


; *******************************************************************************************************
; ****************************************


; *******************************************************************************************************
; ****************************************
PUBLIC PRINT_CHAR_ATTR
PRINT_CHAR_ATTR PROC NEAR

    PUSH AX
    PUSH BX
    PUSH CX

    MOV AH, 9
    MOV BH, 0
    MOV CX, 1
    INT 10h

    POP CX
    POP BX
    POP AX
    RET

PRINT_CHAR_ATTR        ENDP 

; ///////////////////////////////////////////

; *******************************************************************************************************
; ****************************************
; Get cursor properties: coordinates and size (page 0)
; Entry: 
;   -
; Returns:
;   (DH, DL): coordinates -> (row, col)
;   (CH, CL): cursor size
; Modifies:
;   -
; Uses: 
;   -
; Calls:
;   int 10h, service AH=3
; ****************************************
PUBLIC GET_CURSOR_PROP
GET_CURSOR_PROP PROC NEAR

      PUSH AX
      PUSH BX

      MOV AH, 3
      XOR BX, BX
      INT 10h

      POP BX
      POP AX
      RET
      
GET_CURSOR_PROP       ENDP
; *******************************************************************************************************
; ****************************************
; Set cursor properties: coordinates and size (page 0)
; Entry: 
;   (DH, DL): coordinates -> (row, col)
;   (CH, CL): cursor size
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   -
; Calls:
;   int 10h, service AH=2
; ****************************************
PUBLIC SET_CURSOR_PROP
SET_CURSOR_PROP PROC NEAR

      PUSH AX
      PUSH BX

      MOV AH, 2
      XOR BX, BX
      INT 10h

      POP BX
      POP AX
      RET
      
SET_CURSOR_PROP       ENDP

; *******************************************************************************************************
; ****************************************
; Move cursor to coordinate
; Cursor size if kept
; Entry: 
;   (DH, DL): coordinates -> (row, col)
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   -
; Calls:
;   GET_CURSOR_PROP
;   SET_CURSOR_PROP
; ****************************************
PUBLIC MOVE_CURSOR
MOVE_CURSOR PROC NEAR

      PUSH DX
      CALL GET_CURSOR_PROP  ; Get cursor size
      POP DX
      CALL SET_CURSOR_PROP
      RET

MOVE_CURSOR       ENDP 
; *******************************************************************************************************
; ****************************************
; Hides the cursor 
; Entry: 
;   -
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   -
; Calls:
;   int 10h, service AH=1
; ****************************************
PUBLIC  HIDE_CURSOR
HIDE_CURSOR PROC NEAR

      PUSH AX
      PUSH CX
      
      MOV AH, 1
      MOV CX, CURSOR_SIZE_HIDE
      INT 10h

      POP CX
      POP AX
      RET

HIDE_CURSOR       ENDP
; *******************************************************************************************************
; PRINTAR LES BARRES DELS JUGADORS
; ****************************************
; Printar la posici� actual de la barra 1
; Entry: 
; 
; Returns:
;   
; Modifies:
;   
; Uses: 
;   character: ASCII_BARRA1
;   attribute: ATTR_BARRA1
; Calls:
;   PRINT_CHAR_ATTR
; ****************************************
PUBLIC PRINT_BAR1
PRINT_BAR1 PROC NEAR
    MOV DH, POS_BAR1
    MOV DL, 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BARRA1
    CALL PRINT_CHAR_ATTR
    RET
PRINT_BAR1 ENDP   

; ****************************************
; Printar la posicio actual de la barra 2
; Entry: 
; 
; Returns:
;   
; Modifies:
;   
; Uses: 
;   character: ASCII_BARRA2
;   attribute: ATTR_BARRA2
; Calls:
;   PRINT_CHAR_ATTR
; ****************************************
 PUBLIC PRINT_BAR2
 PRINT_BAR2 PROC NEAR
    MOV DH, POS_BAR2
    MOV DL, SCREEN_MAX_COLS - 4 ; Ajustar la posici� horitzonal
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA2
    MOV BL, ATTR_BARRA2
    CALL PRINT_CHAR_ATTR
    RET
PRINT_BAR2 ENDP

; *******************************************************************************************************
; PRINTAR ELS BLOCS DESTRUIBLES
; ****************************************
; Printar la posici� del bloc
; Entry: 
; 
; Returns:
;   
; Modifies:
;   
; Uses: 
;   character: ASCII_BRICK
;   attribute: ATTR_BRICK
; Calls:
;   PRINT_CHAR_ATTR
; ****************************************
PUBLIC PRINT_BRICK
PRINT_BRICK PROC NEAR
    ;ATTR_BRICK_BLUE EQU 09Fh
    ;ATTR_BRICK_RED EQU 0C4h
    ;ATTR_BRICK_GREEN   EQU 020h
    ;ATTR_BRICK_YELLOW EQU 0ECh
    


    MOV DH, SCREEN_MAX_ROWS / 2 
    MOV DL, SCREEN_MAX_COLS / 2 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_BLUE
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 4 
    MOV DL, 3 * SCREEN_MAX_COLS / 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_RED
    CALL PRINT_CHAR_ATTR

    MOV DH, 2 * SCREEN_MAX_ROWS / 3 
    MOV DL, SCREEN_MAX_COLS / 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_GREEN
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 3 
    MOV DL, SCREEN_MAX_COLS / 3 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_YELLOW
    CALL PRINT_CHAR_ATTR

    MOV DH, 2 * SCREEN_MAX_ROWS / 3 
    MOV DL, 2 * SCREEN_MAX_COLS / 3 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_YELLOW
    CALL PRINT_CHAR_ATTR
    
    MOV DH, SCREEN_MAX_ROWS / 5 
    MOV DL, 2 * SCREEN_MAX_COLS / 6 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_BLUE
    CALL PRINT_CHAR_ATTR

    MOV DH, 2 * SCREEN_MAX_ROWS / 3 
    MOV DL, 3 * SCREEN_MAX_COLS / 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_RED
    CALL PRINT_CHAR_ATTR

    MOV DH, 3 * SCREEN_MAX_ROWS / 4 
    MOV DL, SCREEN_MAX_COLS / 5 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_GREEN
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 6 
    MOV DL, SCREEN_MAX_COLS / 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_YELLOW
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 4 
    MOV DL, SCREEN_MAX_COLS / 5 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_BLUE
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 5 
    MOV DL, SCREEN_MAX_COLS / 6 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_RED
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 3 
    MOV DL, 2 * SCREEN_MAX_COLS / 5 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_GREEN
    CALL PRINT_CHAR_ATTR

    MOV DH, 2 * SCREEN_MAX_ROWS / 5 
    MOV DL, 3 * SCREEN_MAX_COLS / 6 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_YELLOW
    CALL PRINT_CHAR_ATTR

    MOV DH, 3 * SCREEN_MAX_ROWS / 6 
    MOV DL, SCREEN_MAX_COLS / 3 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_BLUE
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 4 
    MOV DL, 3 * SCREEN_MAX_COLS / 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_RED
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 3 
    MOV DL, 2 * SCREEN_MAX_COLS / 3 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_GREEN
    CALL PRINT_CHAR_ATTR

    MOV DH, 2 * SCREEN_MAX_ROWS / 5 
    MOV DL, SCREEN_MAX_COLS / 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_YELLOW
    CALL PRINT_CHAR_ATTR

    MOV DH, 3 * SCREEN_MAX_ROWS / 6 
    MOV DL, SCREEN_MAX_COLS / 5 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_RED
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 5 
    MOV DL, 2 * SCREEN_MAX_COLS / 6 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_GREEN
    CALL PRINT_CHAR_ATTR

    MOV DH, 2 * SCREEN_MAX_ROWS / 3 
    MOV DL, 3 * SCREEN_MAX_COLS / 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_BLUE
    CALL PRINT_CHAR_ATTR

    MOV DH, 3 * SCREEN_MAX_ROWS / 4 
    MOV DL, SCREEN_MAX_COLS / 5 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_RED
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 6 
    MOV DL, SCREEN_MAX_COLS / 4 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_YELLOW
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 4 
    MOV DL, SCREEN_MAX_COLS / 5 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_GREEN
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 5 
    MOV DL, SCREEN_MAX_COLS / 6 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_BLUE
    CALL PRINT_CHAR_ATTR

    MOV DH, SCREEN_MAX_ROWS / 3 
    MOV DL, 2 * SCREEN_MAX_COLS / 5 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_RED
    CALL PRINT_CHAR_ATTR

    MOV DH, 2 * SCREEN_MAX_ROWS / 5 
    MOV DL, 3 * SCREEN_MAX_COLS / 6 ; Ajustar la posici� horitzontalment de les barres
    CALL MOVE_CURSOR
    MOV AL, ASCII_BARRA1
    MOV BL, ATTR_BRICK_GREEN
    CALL PRINT_CHAR_ATTR

    RET

PRINT_BRICK      ENDP 
; *******************************************************************************************************
; ****************************************
; Shows the cursor (standard size)
; Entry: 
;   -
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   -
; Calls:
;   int 10h, service AH=1
; ****************************************
PUBLIC SHOW_CURSOR
SHOW_CURSOR PROC NEAR

    PUSH AX
    PUSH CX
      
    MOV AH, 1
    MOV CX, CURSOR_SIZE_SHOW
    INT 10h

    POP CX
    POP AX
    RET

SHOW_CURSOR       ENDP   
; *******************************************************************************************************
; ****************************************
; Print the score string, starting in the cursor
; (FIELD_C1, FIELD_R2) coordinate
; Entry: 
;   DX: pointer to string
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   SCORE_STR
;   FIELD_C1
;   FIELD_R2
; Calls:
;   GET_CURSOR_PROP
;   SET_CURSOR_PROP
;   PRINT_STRING
; ****************************************
PUBLIC PRINT_SCORE_STRING
PRINT_SCORE_STRING PROC NEAR

    PUSH CX
    PUSH DX

    CALL GET_CURSOR_PROP  ; Get cursor size
    MOV DH, FIELD_R2+1
    MOV DL, FIELD_C1
    CALL SET_CURSOR_PROP

    LEA DX, SCORE_STR
    CALL PRINT_STRING

    POP DX
    POP CX
    RET

PRINT_SCORE_STRING       ENDP
; *******************************************************************************************************
; ****************************************
; Prints the score of the player in decimal, on the screen, 
; starting in the cursor position
; NUM_TILES range: [0, 9999]
; Entry: 
;   -
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   NUM_TILES memory variable
; Calls:
;   PRINT_CHAR
; ****************************************
PUBLIC PRINT_SCORE
PRINT_SCORE PROC NEAR

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; 1000'
    MOV AX, [NUM_TILES]
    XOR DX, DX
    MOV BX, 1000
    DIV BX            ; DS:AX / BX -> AX: quotient, DX: remainder
    ADD AL, ASCII_NUMBER_ZERO
    CALL PRINT_CHAR

    ; 100'
    MOV AX, DX        ; Remainder
    XOR DX, DX
    MOV BX, 100
    DIV BX            ; DS:AX / BX -> AX: quotient, DX: remainder
    ADD AL, ASCII_NUMBER_ZERO
    CALL PRINT_CHAR

    ; 10'
    MOV AX, DX          ; Remainder
    XOR DX, DX
    MOV BX, 10
    DIV BX            ; DS:AX / BX -> AX: quotient, DX: remainder
    ADD AL, ASCII_NUMBER_ZERO
    CALL PRINT_CHAR

    ; 1'
    MOV AX, DX
    ADD AL, ASCII_NUMBER_ZERO
    CALL PRINT_CHAR

    POP DX
    POP CX
    POP BX
    POP AX
    RET   
         
PRINT_SCORE        ENDP
; *******************************************************************************************************
; ****************************************
; Print the score string, starting in the
; current cursor coordinate
; Entry: 
;   -
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   PLAY_AGAIN_STR
;   FIELD_C1
;   FIELD_R2
; Calls:
;   PRINT_STRING
; ****************************************
PUBLIC PRINT_PLAY_AGAIN_STRING
PRINT_PLAY_AGAIN_STRING PROC NEAR

    PUSH DX

    LEA DX, PLAY_AGAIN_STR
    CALL PRINT_STRING

    POP DX
    RET

PRINT_PLAY_AGAIN_STRING       ENDP
; *******************************************************************************************************
; ****************************************
; Restore timer ISR
; Entry: 
;   -
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   OLD_INTERRUPT_BASE memory variable
; Calls:
;   int 21h, service AH=25 (system interrupt 08)
; ****************************************
PUBLIC RESTORE_TIMER_INTERRUPT
RESTORE_TIMER_INTERRUPT PROC NEAR

      PUSH AX                             
      PUSH DS
      PUSH DX 

      CLI                                 ;Disable Ints
        
      ;Restore 08h ISR
      MOV  AX, 2508h                      ;MS-DOS service 25h, ISR 08h
      MOV  DX, WORD PTR OLD_INTERRUPT_BASE
      MOV  DS, WORD PTR OLD_INTERRUPT_BASE+02h
      INT  21h                            ;Define the new vector

      STI                                 ;Re-enable interrupts

      POP  DX                             
      POP  DS
      POP  AX
      RET    
      
RESTORE_TIMER_INTERRUPT ENDP
; *******************************************************************************************************
; ****************************************
; Prints character and attribute in the 
; current cursor position, page 0 
; Cursor moves one position right
; Entry: 
;    AL: ASCII code to print
; Returns:
;   
; Modifies:
;   
; Uses: 
;
; Calls:
;   int 21h, service AH=2
; ****************************************
PUBLIC PRINT_CHAR
PRINT_CHAR PROC NEAR

    PUSH AX
    PUSH DX

    MOV AH, 2
    MOV DL, AL
    INT 21h

    POP DX
    POP AX
    RET

PRINT_CHAR        ENDP   
; *******************************************************************************************************
; ****************************************
; Print string to screen
; The string end character is '$'
; Entry: 
;   DX: pointer to string
; Returns:
;   -
; Modifies:
;   -
; Uses: 
;   SCREEN_MAX_COLS
; Calls:
;   INT 21h, service AH=9
; ****************************************
PUBLIC PRINT_STRING
PRINT_STRING PROC NEAR

    PUSH DX
      
    MOV AH,9
    INT 21h

    POP DX
    RET

PRINT_STRING       ENDP
; *******************************************************************************************************
; Iniciar posicions de les pilotes
PUBLIC INIT_BALLS
INIT_BALLS PROC NEAR
    MOV POS_BALL1_ROW, SCREEN_MAX_ROWS / 2
    MOV POS_BALL1_COL, SCREEN_MAX_COLS - 75
    
    MOV POS_BALL2_ROW, SCREEN_MAX_ROWS / 2
    MOV POS_BALL2_COL, SCREEN_MAX_COLS - 5 ; Separar les pilotes una mica
    RET
INIT_BALLS ENDP
; *******************************************************************************************************
; Dibujar pelotas
PUBLIC DRAW_BALLS
DRAW_BALLS PROC NEAR
    PUSH AX
    PUSH BX
    PUSH DX

    ; Dibuixar pelota 1
    MOV DH, POS_BALL1_ROW
    MOV DL, POS_BALL1_COL
    CALL MOVE_CURSOR
    MOV AL, ASCII_BALL
    MOV BL, ATTR_BALL
    CALL PRINT_CHAR_ATTR

    ; Dibuixar pilota 2
    MOV DH, POS_BALL2_ROW
    MOV DL, POS_BALL2_COL
    CALL MOVE_CURSOR
    MOV AL, ASCII_BALL2
    MOV BL, ATTR_BALL2
    CALL PRINT_CHAR_ATTR

    POP DX
    POP BX
    POP AX
    RET
DRAW_BALLS ENDP
CODE_SEG ENDS

; *************************************************************************
; The data starts here
; *************************************************************************
DATA_SEG	SEGMENT	PUBLIC
    ; DEFINE YOUR MEMORY HERE
	DATA		DB 20 DUP (0)
OLD_INTERRUPT_BASE    DW  0, 0  ; Stores the current (system) timer ISR address

    ; (INC_ROW. INC_COL) may be (-1, 0, 1), and determine the direction of movement of the snake
    INC_ROW DB 0    
    INC_COL DB 0

    NUM_TILES DW 0              ; SNAKE LENGTH
    NUM_TILES_INC_SPEED DB 20   ; THE SPEED IS INCREASED EVERY 'NUM_TILES_INC_SPEED'
    
    DIV_SPEED DB 10             ; THE SNAKE SPEED IS THE (INTERRUPT FREQUENCY) / DIV_SPEED
    INT_COUNT DB 0              ; 'INT_COUNT' IS INCREASED EVERY INTERRUPT CALL, AND RESET WHEN IT ACHIEVES 'DIV_SPEED'

    START_GAME DB 0             ; 'MAIN' sets START_GAME to '1' when a key is pressed
    END_GAME DB 0               ; 'NEW_TIMER_INTERRUPT' sets END_GAME to '1' when a condition to end the game happens

    SCORE_STR           DB "Your score is $"
    PLAY_AGAIN_STR      DB ". Do you want to play again? (Y/N)$"

    POS_BAR1 DB SCREEN_MAX_ROWS - 4   ; Posici� inicial de la barra del jugador 1
    POS_BAR2 DB 3   ; Posici� inicial de la barra del jugador 2

    ; Declaraci� variables per la pilota 1
    POS_BALL1_ROW DB 0 ; Posici� inicial a la fila de la pilota 1
    POS_BALL1_COL DB 0 ; Posici� inicial a la columna de la pilota 1
    ; Declaraci� variables per la pilota 1
    POS_BALL2_ROW DB 0 ; Posici� inicial a la fila de la pilota 2
    POS_BALL2_COL DB 0 ; Posici� inicial a la columna de la pilota 2
DATA_SEG	ENDS

END MAIN