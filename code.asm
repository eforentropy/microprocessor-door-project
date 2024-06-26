;MIKROISLEMCI DERSI KAPI KILIDI KODU
;HAZIRLAYANLAR 
;BÜNYAMIN UYSAL
;ADEM KOÇ
;KOD EMÜLATÖRDE RAHAT ANLASILABILMESI ICIN DOS OUTPUTLARLA DONATILDI
;STANDART OPUTLARI GÖSTERMEK AMACIYLA PORT_SUCCESS PORT_FAILED VE PORT_DEFAULT GIBI METODLAR TANIMLANDI
;CAPTCHA CEVABINI RANDOMIZE ETMEK AMACIYLA ZAMAN DAMGASI KULLANILDI

.MODEL SMALL
ORG 100H
.DATA         
   
WELCOME DB  "Hosgeldiniz , Pin kodu olusturmak icin lutfen 4 basamakli bir pin kodu giriniz...$" 
SUCCESS DB  "Pin kabul edildi!  , Mevcut Pin kodunu kullanarak giris yapabilirsiniz!!!$"
ERROR   DB  "Pin kabul edilmedi LÃ¼tfen tekrar deneyiniz...$"    
ENTER_PIN DB "Lutfen Pin kodunuzu giriniz=> $"
SUCCESS_PIN DB "Pin Kabul Edildi!!!$"
FAIL_PIN DB "Pin Kodunuz yanlis LÃ¼tfen tekrar deneyiniz...$"
CAPTCHA_FAILED DB "Captcha islemi basarisiz oldu lÃ¼tfen tekrar deneyiniz...$"
CAPTCHA_SUCCESS DB "Captcha islemi basarili!! Giris yapiliyor...$"   
PIN DB 5 DUP('$') 
TEMP_PIN DB 5 DUP('$')  

CAPTCHA_ENTRY DB 2 DUP(?) 
CAPTCHA_RESULT DB 1 DUP(?) 
CAPTCHA_STRING DB 5 DUP('$')
RANDOM_NUMBERS DB 2 DUP (?)     ;2 UNKNOWN NUMBER
;NUMBERS DB 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15   ;CAPTCHA RANDOMIZER
OPERATOR DB 1 DUP (?)
;OPERATORS DB '+','-'                      ;CAPTCHA RANDOMIZER 
;0=>+
;1=>-


;PORT 110H is default OUTPUT
;1 => success
;2 => fail
;0 => otherwise




.CODE    
    
    MOV AX , @DATA ;COPY DATA SEGMENT ADDRESS TO AX
    MOV DS , AX    ;COPY DATA SEGMENT ADDRESS TO DS
    
    
    LEA DX , WELCOME    ;COPY WELCOME STRING ADDRESS TO DX 
    CALL PRINT_STRING   ;CALL PRINT STRING 
    CALL NEWLINE        ;CALL NEWLINE 
    PIN_TAKE_START:     ;TAG FOR RECALL 
    MOV CX , 4  ;PIN NUMBER COUNT FOR LOOP 
    LEA DI , PIN;PIN BASE ADDRESS
    TAKE_PIN:   ;COUNTER LOOP TAG 
    MOV AH , 1  ;MS-DOS SUB-PROCEDURE CALL FOR KEYBOARD ENTRY 
    INT 21H     ;MS-DOS INTERRUPT 
    MOV [DI],AL ;MOVE AL INPUT TO DI REGISTER
    INC DI      ;INCREASE DI REGISTER POINTER TO NEX PIN CHAR
    LOOP TAKE_PIN
    
    
    ;CHECK PIN IS NUMERIC?
    
    CALL VALIDATE_PIN       ;CALL CHECKER PROCEDURE
    RESUME:
    ;CONTINUE IF PIN IS ACCEPTED
    ;WAIT FOR PIN ENTRY
    CALL PORT_SUCCESS
    CALL NEWLINE
    LEA DX , SUCCESS    ;LOAD SUCCESS MESSAGE TO DX
    CALL PRINT_STRING   ;CALL PRINT_STRING
    CALL NEWLINE        ;CALL NEWLINE 
    CALL NEWLINE        ;CALL NEWLINE
    
    PIN_ENTRY_START: 
    LEA  DX , ENTER_PIN ;LOAD ENTER_PIN STRING TO DX
    CALL PRINT_STRING   ;CALL PRINT_STRING
    CALL NEWLINE        ;CALL NEWLINE
     
    MOV CX , 4          ;SET COUNTER FOR LOOP       
    
    LEA  DI , TEMP_PIN  ;LOAD TEMP_PIN ADDRESS TO DI
    PIN_ENTRY:
    MOV AH , 01H        ;MS-DOS INTERRUPT SUB-PROCEDURE CALL NUMBER
    INT 21H             ;MS-DOS INTERRUPT 
    MOV [DI],AL         ;MOVE AL VALUE TO DI
    INC DI              ;INCREASE DI INDEX
    LOOP PIN_ENTRY:
    
    CALL CHECK_PIN      ;CALL CHECK_PIN PROCEDURE
    ;CHECK IS TEMP_PIN EQUAL PIN?                 
    RESUME2:
    CALL NEWLINE
    CALL PORT_SUCCESS
    LEA DX , SUCCESS_PIN    ;LOAD SUCCESS_PIN TO DX 
    CALL PRINT_STRING       ;CALL PRINT_STRING
    CALL NEWLINE            ;CALL NEWLINE 
    
    ;CAPTCHA CONTROL
    CALL RANDOMIZER         ;CALL RANDOMIZER  
    CALL CREATE_CAPTCHA     ;CALL CREATE_CAPTCHA
               
    RESUME3:                ;RESUME TAG 
    CALL PORT_SUCCESS
    LEA DX , CAPTCHA_STRING     ;PRINT CAPTCHA QUESTION
    CALL PRINT_STRING           ;CALL PRINT STRING
    CALL NEWLINE                ;PRINT NEWLINE
    
    ;TAKE CAPTCHA RESULT
    
     
    LEA SI , CAPTCHA_ENTRY  ;LOAD CAPTCHA ENTRY FOR 2 STEP 
    MOV AH , 01H        ;MS-DOS INTERRUPT SUB-PROCEDURE CALL NUMBER
    INT 21H             ;MS-DOS INTERRUPT 
    MOV [SI] , AL       ;MOVE FIRST STEP TO CAPTCHA ENTRY
    INC SI              ;INCREASE ENTRY INDEX
    MOV AH , 01H        ;MS-DOS INTERRUPT SUB-PROCEDURE CALL NUMBER
    INT 21H             ;MS-DOS INTERRUPT
    MOV [SI] , AL       ;MOVE FIRST STEP TO CAPTCHA ENTRY 
    
    ;CONVERT ENTRY TO INTEGER
    LEA SI , CAPTCHA_ENTRY  ;RELOAD BASE ADDR
    MOV AX , 0              ;CLEAR AX CACHE
    MOV BX , 0              ;CLEAR BX CACHE
    
    MOV AL, [SI]            ;MOVE FIRST STEP TO AL
    SUB AL, '0'             ;CONVERT DECIMAL
    MOV BL, 10              ;MULTIPLY VALUE
    MUL BL                  ;
    MOV BL, AL              ;RESULT IN BL FOR 1 BYTE
    
    INC SI
    MOV AL, [SI]
    SUB AL, '0'
    ADD AL, BL
    ;AL NOW CONVERTED INTEGER
    MOV DL , 0  ;RESET DH FOR CAPTCHA RESULT
    LEA SI , CAPTCHA_RESULT
    MOV DL , [SI]   ;COPY CAPTCHA RESULT TO DL FOR COMPARING
        
    ;AL=CAPTCHA RESULT CHECK IS IT CORRECT
    CMP AL , DL         ;COMPARE RESULT AND ENTRY
    JE CORRECT;         ;JUMP IF EQUAL
    
    ;IF WRONG
    CALL PORT_FAIL          ;OUTPUT FAIL
    LEA DX , CAPTCHA_FAILED ;LOAD FAIL STRING TO DX
    CALL PRINT_STRING
    CALL NEWLINE
    JMP RESUME3:
    
    CORRECT:
    CALL PORT_SUCCESS           ;OUTPUT SUCCESS
    CALL NEWLINE                ;CALL NEWLINE
    LEA DX , CAPTCHA_SUCCESS    ;CAPTCHA SUCCESS STRING
    CALL PRINT_STRING           
    CALL NEWLINE

    HLT                     ;RETURN OPERATING SYSTEM CONTROL  
       


PRINT_STRING PROC
    MOV AH, 09H   ;MS-DOS INTERRUPT SUB-PROCEDURE CODE FOR PRINT STRING
    INT 21H       ;MS-DOS INTERRUPT
    RET           ;CALLBACK RETURN
PRINT_STRING ENDP    

NEWLINE PROC
    MOV AH, 02H         ;MS-DOS INTERRUPT SUB-PROCEDURE CODE FOR PRINT CHAR
    MOV DL, 0DH         ;CARRIAGE-RETURN CHAR
    INT 21H             ;MS-DOS INTERRUPT
    MOV DL, 0AH         ;NEWLINE CHAR
    INT 21H             ;MS-DOS INTERRUPT
    RET                 ;CALLBACK RETURN
NEWLINE ENDP 


VALIDATE_PIN PROC
    LEA SI, PIN     ;LOAD PIN BASE ADDRESS TO SI REGISTER
    MOV CX, 4       ;SET COUNTER TO 4

    VALIDATE_LOOP:      ;VALIDATE PIN IS ONLY NUMERIC
        MOV AL , [SI]   ;MOV SI VALUE TO AL
        CMP AL, '0'     ;COMPARE AL TO '0' ASCII VALUE
        JB INVALID_PIN  ;JUMP IF BELOW 0
        CMP AL, '9'     ;COMPARE AL TO '9' ASCII VALUE
        JA INVALID_PIN  ;JUMP IF ABOVE 9
        INC SI          ;INCREASE SI
    LOOP VALIDATE_LOOP 
    JMP RESUME  ;IF PIN VALID JUMP RESUME TAG    
    INVALID_PIN:
        CALL NEWLINE        ;CALL NEWLINE
        LEA DX, ERROR       ;LOAD ERROR TEXT BASE ADDRESS TO DX
        CALL PRINT_STRING   ;CALL PRINT_STRING
        CALL NEWLINE        ;CALL NEWLINE
        ;REMOVE ALL PIN ENTRY FOR NEW ITERATION
        LEA SI , PIN        ;LOAD PIN BASE ADDRESS TO SI
        MOV CX , 4          ;SET COUNTER
        REMOVE:             ;LOOPBACK TAG
        MOV [SI],'$'        ;REPLACE SI VALUE WITH '$' 
        INC SI              ;INCREASE SI INDEX
        LOOP REMOVE         ;GO BACK REMOVE TAG AND DECREASE CX                
        JMP PIN_TAKE_START  ;RECALL PIN ENTRY 
VALIDATE_PIN ENDP  


CHECK_PIN PROC
    LEA SI , TEMP_PIN   ;LOAD TEMP_PIN BASE ADDRESS TO SI
    LEA DI , PIN        ;LOAD PIN BASE ADDRESS TO DI
    
    MOV CX , 4          ;SET COUNTER
    CHECK:
    MOV AH , [SI]
    MOV AL , [DI]
    CMP AH , AL         ;COMPARE 
    JNE CHECK_FAILED    ;JUMP IF NOT EQUAL
    LOOP CHECK          ;LOOP 4 TIMES
    JMP RESUME2         ;IF TEMP_PIN IS CORRECT JUMP RESUME2
        
    CHECK_FAILED:
    CALL NEWLINE 
    LEA DX , FAIL_PIN   ;LOAD FAIL_PIN STRING TO DX     
    CALL PRINT_STRING
    CALL NEWLINE
    ;REMOVE ALL TEMP_PIN 
    LEA SI , TEMP_PIN   ;LOAD PIN BASE ADDRESS TO SI
    MOV CX , 4          ;SET COUNTER
    REMOVE2:            ;LOOPBACK TAG
    MOV [SI],'$'        ;REPLACE SI VALUE WITH '$' 
    INC SI              ;INCREASE SI INDEX
    LOOP REMOVE2        ;GO BACK REMOVE TAG AND DECREASE CX 
    JMP PIN_ENTRY_START ;RECALL PIN_ENTRY  
CHECK_PIN ENDP 


RANDOMIZER PROC  
    MOV AH, 2CH ; MS-DOS SUB-PROCEDURE PROCESS NUMBER FOR TIMESTAMP
    INT 21h     ;MSDOS INTERRUPT
    ;DH=>SECOND     ;DL=>1/100 SECOND 
    MOV AL, DH  ;MOVE SECOND TO AL
    MOV AH, DL  ;MOVE 10 MILISECOND TO AH
    XOR AL, AH  ;XOR AL AND AH
    AND AL, 00000111B   ;AND BINARY FOR NARROW THE RANGE 0-8
    LEA SI, RANDOM_NUMBERS  ; LOAD RANDOM_NUMBERS ADDR 
    MOV [SI], AL            ; MOVE RANDOM NUMBER TO RANDOM_NUMBERS ARRAY   
    MOV AH, 2CH ; MS-DOS SUB-PROCEDURE PROCESS NUMBER FOR TIMESTAMP
    INT 21h     ;MSDOS INTERRUPT 
    MOV AL, DH  ;MOVE SECOND TO AL
    MOV AH, DL  ;MOVE 10 MILISECOND TO AH
    XOR AL, AH  ;XOR AL AND AH
    AND AL, 00000111B   ;AND BINARY FOR NARROW THE RANGE 0-8
    MOV [SI+1], AL  ; MOVE RANDOM NUMBER TO RANDOM_NUMBERS ARRAY
    MOV AH, 2CH ; MS-DOS SUB-PROCEDURE PROCESS NUMBER FOR TIMESTAMP
    INT 21h     ;MSDOS INTERRUPT 
    MOV AL, DH  ;MOVE SECOND TO AL
    MOV AH, DL  ;MOVE 10 MILISECOND TO AH
    XOR AL, AH  ;XOR AL AND AH
    AND AL, 00000001B   ;AND BINARY FOR NARROW THE RANGE 0-1
    LEA SI , OPERATOR   ;LOAD OPERATOR BASE ADDRESS TO SI
    MOV [SI] , AL       ;LOAD 1 OR 0 TO OPERATOR
    RET
RANDOMIZER ENDP

CREATE_CAPTCHA PROC
    CAPTCHA_LOOP:
        CALL RANDOMIZER ; RASTGELE SAYILARI VE OPERATÃ–RÃœ YENIDEN ÃœRET
        
        ;USE RANDOM_NUMBERS
        ;USE OPERATOR 
        ;USE CAPTCHA_STRING

        LEA SI , RANDOM_NUMBERS ;LOAD RANDOM NUMBERS ADDRESS
        LEA DI , CAPTCHA_STRING ;LOAD CAPTCHA STRING ADDRESS
        MOV AL , [SI]           ;MOV RANDOM NUMBER TO AL
        ADD AL , '0'
        MOV [DI] , AL       ;MOV RANDOM NUMBER TO CAPTCHA STRING FIRST INDEX
        INC DI                  ;INCREASE STRING INDEX
        ;SELECT OPERATOR

        LEA SI , OPERATOR       ;LOAD OPERATOR BASE ADDRESS
        MOV AL , [SI]           ;MOVE OPERATOR TO AL
        CMP AL , 0            ;CHECK OPERATOR
        JE ADDITION
        CMP AL , 1
        JE SUBTRACT

        ADDITION:                       ;ADDITION OPERATOR 
        MOV [DI] , '+'
        JMP RESUME_CAPTCHA_STRING

        SUBTRACT:                       ;SUBTRACT OPERATOR
        MOV [DI] , '-'
        JMP RESUME_CAPTCHA_STRING

        RESUME_CAPTCHA_STRING:
        INC DI      ;INCREASE STRING INDEX
        ;ADD OPERAND 2 

        LEA SI , RANDOM_NUMBERS ;LOAD RANDOM NUMBERS ADDRESS
        INC SI                  ;INCREASE SI INDEX(2)
        MOV AL , [SI]           ;MOV RANDOM NUMBER TO AL
        ADD AL , '0'
        MOV [DI] , AL           ;ADD NUMBER TO STRING    
        INC DI                  ;GET NEXT INDEX
        MOV [DI] , '='          
        INC DI
        MOV [DI] , '$'          ;STRING TERMINATOR

        ;FIND CAPTCHA RESULT

        LEA SI , RANDOM_NUMBERS ;LOAD RANDOM NUMBERS BASE ADDRESS
        MOV AL , [SI]           ;GET FIRST RANDOM NUMBER
        INC SI                  ;INCREASE SI INDEX
        MOV BL , [SI]           ;GET SECOND RANDOM NUMBER
        LEA SI , OPERATOR       ;GET OPERATOR
        MOV AH , [SI]           ;COPY OPERATOR TO AL
        CMP AH , 0            ;CHECK CASES
        JE ADDITION_RESULT
        CMP AH , 1
        JE SUBTRACT_RESULT
        ;AH , BH 2 RANDOM NUMBER 

        ADDITION_RESULT:
        LEA DI , CAPTCHA_RESULT ;GET CAPTCHA RESULT BASE ADDRESS TO DI
        ADD AL , BL 
        MOV [DI] , AL   ;COPY RESULT TO CAPTCHA_RESULT
        JMP CHECK_POSITIVE

        SUBTRACT_RESULT:
        LEA DI , CAPTCHA_RESULT ;GET CAPTCHA RESULT BASE ADDRESS TO DI
        SUB AL , BL 
        MOV [DI] , AL   ;COPY RESULT TO CAPTCHA_RESULT
        JMP CHECK_POSITIVE

        CHECK_POSITIVE:
        ;CHECK IF CAPTCHA RESULT IS POSITIVE
        LEA DI , CAPTCHA_RESULT
        MOV AL , [DI]
        CMP AL , 0
        JL CAPTCHA_LOOP ;IF CAPTCHA RESULT IS NEGATIVE, REPEAT LOOP
        JMP END_CAPTCHA

    END_CAPTCHA: 
    JMP RESUME3

CREATE_CAPTCHA ENDP 


PORT_SUCCESS PROC  
    MOV AL , 1
    OUT 110 , AL
    RET
PORT_SUCCESS ENDP  

PORT_FAIL PROC
    MOV AL , 2
    OUT 110 , AL
    RET   
PORT_FAIL ENDP

PORT_DEFAULT PROC
    MOV AL , 2
    OUT 110 , AL
    RET     
PORT_DEFAULT ENDP


END MAIN 


  

     
    