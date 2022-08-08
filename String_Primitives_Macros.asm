TITLE Designing low-level I/O Procedures     (String_Primitives_Macros.asm)

; Last Modified: 3/12/2022
; Description: This program implements custom procedures for reading (readVal) and writing (writeVal) integer values and uses these procedures
;				in the main (test) program. The procedures are implemented with macros mGetString and mDisplayString, which gets the string
;				of integers from the user and displays integer values as strings respectively.
;				The main program prompts the user for 10 integers and displays the list of valid integers received, the sum of the integers,
;				and the truncated average of the integers. The program validates that the values entered by the user are valid integers which
;				fit within a 32-bit register, and will display an error and re-prompt the user if the value entered is not valid. Note: Values
;				may be entered with a sign '+' or '-' and will be considered a valid entry. Valid numbers fitting within a 32-bit register
;				range from [-2^31 to (2^31)-1].

INCLUDE Irvine32.inc
; ------------------------------------------------------------------------------------------
; Name: mGetString
; Description: This macro receives three arguments - the address of the display prompt which asks the user to enter
; a value, the address of the string buffer which is used to store the user's input, and the byteCount which is the
; number of characters the buffer may hold (i.e. the buffer size).
; preconditions: passed arguments must be pre-defined and initialized.
; postconditions: 
;	bufferAddress = address of buffer with modified contents containing the user's entered string contents
;   byteCount = contents are modified to contain the number of characters which the user entered
; receives: 
;	promptAddress(input ref) = address of the prompt displayed to the user
;	bufferAddress (input/ouput ref) = address where the user's entered string will be stored
;	byteCount (input/output ref) = address where the count of the user's entered number of characters is stored
; returns: 
;	bufferAddress (input/ouput ref) = address contents are modifed to store with the user's entered string
;	byteCount (input/output ref) = address contents are modified to store the count of characters entered
; ------------------------------------------------------------------------------------------
mGetString MACRO promptAddress, bufferAddress, byteCount
  PUSH	EDX
  PUSH	EAX
  PUSH	ECX

  MOV	EDX, promptAddress
  call	WriteString						; Irvine procedure
  MOV	EDX, bufferAddress				; point to the buffer
  MOV	ECX, BUFFERSIZE					; specify max characters
  call	ReadString						; input the string. Irvine procedure
  MOV	byteCount, EAX					; byteCount = EAX = number of characters
  call	CrLf

  POP	ECX
  POP	EAX
  POP	EDX
ENDM

; ------------------------------------------------------------------------------------------
; Name: mDisplayString
; Description: This macro receives one argument - the address of the string to be displayed to the user.
; Note - this macro is specifically used to display the string representation of an integer value.
; preconditions: passed arguments must be pre-defined and initialized. stringAddress must contain
; a string.
; postconditions: string (representing an integer) is displayed
; receives: stringAddress(input ref) = address of the string displayed to the user
; returns: none
; ------------------------------------------------------------------------------------------
mDisplayString MACRO stringAddress
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX
  PUSH	EDI
  PUSH	ESI

  MOV	EDX, stringAddress
  call	WriteString

  POP	ESI
  POP	EDI
  POP	EDX
  POP	ECX
  POP	EBX
  POP	EAX
ENDM

; (insert constant definitions here)
BUFFERSIZE = 32

.data

heading_1				BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O proceudres     Written by Dana Yarges", 0
intro1					BYTE	"Please provide 10 signed decimal integers.",10,13
						BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",10,13
						BYTE	"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",0
prompt_1				BYTE	"Please enter a signed number: ", 0
prompt_error			BYTE	"ERROR: You did not enter a signed number or your number was too big.", 0
prompt_2				BYTE	"Please try again: ", 0
prompt_3				BYTE	"You entered the following numbers: ", 0
prompt_4				BYTE	"The sum of these numbers is: ", 0
prompt_5				BYTE	"The truncated average is: ", 0
comma					BYTE	", ", 0
goodbye					BYTE	"Thanks for playing!", 0
stringBuffer			BYTE	BUFFERSIZE DUP (0)	; input buffer
stringByteCount			OWORD	?					; holds counter
stringBuffer2			BYTE	BUFFERSIZE DUP (0)	; input buffer
stringBuffer3			BYTE	BUFFERSIZE DUP (0)	; output buffer
value					SDWORD	0
arrayValues				SDWORD	10 DUP(?)
integerCount			DWORD	0
sum						SDWORD	0
average					SDWORD	0

.code
main PROC
;  ---------------------------------------
;  Heading
;  ---------------------------------------
;  Heading - Title and Author
  PUSH	OFFSET heading_1
  call	heading

;  ---------------------------------------
;  Introduction - 
;  Display instructions and introduction
;  ---------------------------------------
  ; introduction prompt
  PUSH	OFFSET intro1
  call	introduction

;  ---------------------------------------
;  Get the data - 
;  Repeatedly prompt the user until 10 valid integers are entered. If
;  an invalid entry is made, an error will be displayed and the program
;  will re-prompt the user for a valid entry.
;  ---------------------------------------
  MOV	EDI, OFFSET arrayValues				; EDI = address where valid entered integers will be stored

  ; get 10 integers from the user
  MOV	ECX, LENGTHOF arrayValues			; initialize loop counter
_getTenIntegers:
  ; prompt user and store value
  PUSH	OFFSET prompt_2						; "Please try again: "
  PUSH	OFFSET prompt_error
  PUSH	OFFSET prompt_1						; "Please enter a signed number: "
  PUSH	OFFSET stringBuffer					; address where user's entered string will be stored
  PUSH	OFFSET stringByteCount				; address where user's entered character count will be stored
  PUSH	OFFSET value						; address where the string's converted numerical value will be stored
  call	readVal

  MOV	EAX, value
  MOV	[EDI], EAX							; store numerical value
  ADD	EDI, 4								; increment to next array element to store user's next input value
  MOV	value, 0							; reset stored value to 0
  LOOP	_getTenIntegers

;  ---------------------------------------
;  Calculate the data - 
;  Calculate the sum and average (truncated) of the 10 integers entered.
;  ---------------------------------------
  ; calculate the sum
  MOV	ECX, LENGTHOF arrayValues			; initialize loop counter
  MOV	ESI, OFFSET arrayValues				; ESI = address of arrayValues where numerical values are stored
_calculateSum:
  MOV	EAX, [ESI]
  ADD	sum, EAX
  ADD	ESI, 4
  LOOP	_calculateSum

  ; calculate the average
  MOV	ESI, OFFSET sum						; ESI = address of sum
  MOV	EDI, OFFSET	average					; EDI = address where the calculated average will be stored
  MOV	EAX, [ESI]
  MOV	EBX, 10								; 10 values must be entered by user. hence, the average must be divided by 10
  CDQ
  IDIV	EBX
  MOV	[EDI], EAX							; store the calculated average

;  ---------------------------------------
;  Display Results - 
;  Display the valid integers entered by the user, the sum of these 
;  number, and the truncated average.
;  ---------------------------------------

  ; Display the entered values
  MOV	EDX, OFFSET prompt_3				; "You entered the following numbers: "
  call	WriteString
  call	CrLf
  MOV	ECX, LENGTHOF arrayValues			; initialize loop counter
  MOV	EBX, ECX
  SUB	EBX, 1								; initialize EBX to track when last element is reached. this is to determine whether to display a comma
  MOV	ESI, OFFSET arrayValues				; ESI = address of arrayValues containing numerical values
_displayIntegers:
  MOV	EAX, [ESI]
  MOV	value, EAX							; store current value in array to prepare to pass to writeVal procedure
  PUSH	OFFSET stringBuffer3				; address where the string represented conversion will be stored (in order) and read to the display
  PUSH	OFFSET stringBuffer2				; address where the 1st conversion from numerical value is stored (in reverse)
  PUSH	OFFSET value						; address of the current value being converted to string representation and displayed
  call	writeVal
  ADD	ESI, 4								; increment to the next array value
  ; display comma, if necessary
  CMP	EBX, 0
  JE	_skipComma
  MOV	EDX, OFFSET comma
  call	WriteString
  DEC	EBX									; update last element tracker
_skipComma:
  LOOP	_displayIntegers

  call	CrLf

  ; Display the calculated sum
  MOV	EDX, OFFSET prompt_4				; "The sum of these numbers is: "
  call	WriteString

  PUSH	OFFSET stringBuffer3				; address where the string represented conversion will be stored (in order) and read to the display
  PUSH	OFFSET stringBuffer2				; address where the 1st conversion from numerical value is stored (in reverse)
  PUSH	OFFSET sum							; address of the value being converted to string representation and displayed
  call	writeVal
  call	CrLf

  ; Display the truncated average
  MOV	EDX, OFFSET prompt_5				; "The truncated average is: "
  call	WriteString

  PUSH	OFFSET stringBuffer3				; address where the string represented conversion will be stored (in order) and read to the display
  PUSH	OFFSET stringBuffer2				; address where the 1st conversion from numerical value is stored (in reverse)
  PUSH	OFFSET average						; address of the value being converted to string representation and displayed
  call	writeVal
  call	CrLf
  call	CrLf

;  ---------------------------------------
;  Say Goodbye
;  
;  ---------------------------------------
  ; Display goodbye prompt
  MOV	EDX, OFFSET goodbye					; "Thanks for playing!"
  call	WriteString



	Invoke ExitProcess,0					; exit to operating system
main ENDP

; ------------------------------------------------------------------------------------------
; Name: heading
; Description: Procedure to display the heading of the program.
; preconditions: none
; postconditions: Displays heading prompt
; receives: heading_1 (reference, input)
; returns: none
; ------------------------------------------------------------------------------------------
heading PROC
  PUSH	EBP
  MOV	EBP, ESP							; Base pointer
  PUSH	EDX
  MOV	EDX, [EBP+8]						; heading_1
  call	WriteString
  call	CrLf
  call	CrLf
  POP	EDX
  POP	EBP
  RET	4
heading ENDP

; ------------------------------------------------------------------------------------------
; Name: introduction
; Description: Procedure to introduce the program and instructions.
; preconditions: none
; postconditions: Displays introduction prompt
; receives: intro1 (reference, input)
; returns: none
; ------------------------------------------------------------------------------------------
introduction PROC
  PUSH	EBP
  MOV	EBP, ESP							; Base pointer
  PUSH	EDX
  MOV	EDX, [EBP+8]						; heading_1
  call	WriteString	
  call	CrLf
  call	CrLf
  POP	EDX
  POP	EBP
  RET	4
introduction ENDP


; ------------------------------------------------------------------------------------------
; Name: readVal
; Description: Converts the user entered ASCII digit characters to the numeric value represenation.
; Validates the user's input as a valid number (no letters, invalid symbols, and must fit within a 
; 32-bit register). The first character may be '+' or '-'.
; preconditions: none
; postconditions: Displays introduction prompt
; receives: prompt_2 (input, ref) =	address of display prompt
;			prompt_error (input, ref) = address of display prompt
;			prompt_1 (input, ref) = address of display prompt
;			stringBuffer (input, ref) = address of the string to be entered and modified with user's input
;			stringByteCount (input, ref) = address where character count of entered string is stored
;			value (input/output, ref) = address where numerical value of entered string is stored. contents modified with numerical value
; returns: value (input/output, ref) = address where numerical value of entered string is stored. contents modified with numerical value
; ------------------------------------------------------------------------------------------
readVal PROC
  LOCAL	tenMult: SDWORD, isNegative: SDWORD, firstDigit: SDWORD, negativeOne: SDWORD
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX
  PUSH	EDI
  PUSH	ESI

  MOV	tenMult, 10							; initialize tenMult to 10
  MOV	negativeOne, -1						; initialize negativeOne to -1

  ; Macro - Displays prompt. Get's string from user. Stores user's input as a string.
  ;			Syntax- mGetString promptAddress, bufferAddress, byteCount
  mGetString [EBP+20], [EBP+16], [EBP+12]
  ; Post-conditions: stringBufferAddress = address of buffer modified with string contents; stringByteCount = address contents modified with number of characters entered
  JMP	_numericalConversionBlock

  ; if input is determined invalid, re-prompt user for valid input
_invalidEntryRetryPrompt:					
  mGetString [EBP+28], [EBP+16], [EBP+12]	
  ; Post-conditions: stringBufferAddress = address of buffer modified with string contents; stringByteCount = address contents modified with number of characters entered

  ; convert string to numerical value
_numericalConversionBlock:					
  MOV	isNegative, 0						; initialize isNegative to 0
  MOV	ECX, [EBP+12]						; initialize ECX = # of characters entered
  MOV	firstDigit, ECX						; initialize firstLoop flag to ECX
  MOV	ESI, [EBP+16]						; set ESI to address of entered string 
  CLD										; clear direction flag; primitive will increment pointer

  ; check if the first character is a '+' or '-' symbol
  LODSB										; loads value pointed to by ESI into AL register. increments ESI
  CMP	AL, 45								; check if first character is ASCII '-' minus symbol (45d)
  JNE	_notNegative
  MOV	isNegative, 1						; boolean flag, set if entered value is negative
  DEC	ECX									; update character count (ECX) for loop counter
  MOV	firstDigit, ECX						; reset firstDigit flag to account for '-' symbol as first character
  JMP	_stringToNumber
_notNegative:
  MOV	isNegative, 0						; boolean flag, clear if entered value is not negative
  CMP	AL, 43								; check if first character is ASCII '+' plus symbol (43d)
  JNE	_noSymbolEntered
  DEC	ECX									; update character count (ECX) for loop counter
  JMP	_stringToNumber
_noSymbolEntered:
  DEC	ESI									; if entered value is neither '+' nor '-' then decrement ESI back to the first character

  ; convert and validate input
_stringToNumber:  
  LODSB										; loads value pointed to by ESI into AL register. increments ESI
  ; check that character is 48<= char <=57
  CMP	AL, 48
  JB	_invalidEntry
  CMP	AL, 57
  JA	_invalidEntry

  ; convert from ASCII to numerical value
  MOV	EBX, 0								; clear upper registers of EBX
  SUB	AL, 48								; convert ASCII to numeric digit
  MOV	BL, AL								; store current digit in EBX/BL
  MOV	EDI, [EBP+8]						; EDI = memory address of 'value'
  MOV	EAX, [EDI]							; move current numerical value stored in 'value' into EAX
  IMUL	tenMult								; multiply current numeric value by 10
  JO	_invalidEntry
  CMP	isNegative, 1						; check negative flag to determine whether to ADD or SUB from total value
  JE	_subtractFromTotal
  ADD	EAX, EBX							; add current digit to numeric value total
  JMP	_addTotalDone
_subtractFromTotal:
  SUB	EAX, EBX							; subtract current digit from numeric value total
_addTotalDone:
  JO	_invalidEntry						; check overflow. 32-bit range validation check

  ; store value
  MOV	[EDI], EAX							; store current numeric total in 'value'
  LOOP	_stringToNumber
  JMP	_procedureEnd

 ; display error prompt and prompt user for another value
_invalidEntry:
  PUSH	EDX
  MOV	EDX, [EBP+24]						; [EBP+24] = prompt_error
  call	WriteString
  call	CrLf
  POP	EDX
  MOV	EDI, [EBP+8]						; EDI = memory address of 'value'
  MOV	EAX, 0
  MOV	[EDI], EAX							; re-initialize stored value to 0
  JMP	_invalidEntryRetryPrompt

_procedureEnd:
  POP	ESI
  POP	EDI
  POP	EDX
  POP	ECX
  POP	EBX
  POP	EAX
  RET	24
readVal ENDP


; ------------------------------------------------------------------------------------------
; Name: writeVal
; Description: Converts a value (SDWORD) passed by reference into a string and displays the string representation
; preconditions: none
; postconditions: Displays string representation of passed numerical value
; receives: stringBuffer3 (input, ref) = address where the string represented conversion will be stored (in order) and read to the display
;			stringBuffer2 (input, ref) = address where the 1st conversion from numerical value is stored (in reverse)
;			parameter: value/sum/average (input/output, ref) = address of the value being converted to string representation and displayed
; returns: none
; ------------------------------------------------------------------------------------------
writeVal PROC
  LOCAL	tenDiv: DWORD, quotient: DWORD, isNegative: SDWORD, characterCount: DWORD
  PUSH	EAX
  PUSH	EBX
  PUSH	ECX
  PUSH	EDX
  PUSH	EDI
  PUSH	ESI

  MOV	tenDiv, 10				; initialize tenDiv to 10
  MOV	isNegative, 0			; initialize isNegative to 0
  MOV	characterCount, 0		; initialize character count to 0

  MOV	EDI, [EBP+12]			; EDI = memory address of 'stringBuffer2'
  MOV	ESI, [EBP+8]			; ESI = memory address of 'value'
  MOV	EAX, [ESI]				; move current numerical value stored into EAX

  ; check if value is a negative number
  CMP	EAX, 0
  JGE	_numberToString
  MOV	isNegative, 1
  IMUL	EAX, -1					; convert to a positive value
  MOV	[ESI], EAX				; store absolute value

  ; load NUL value as first value in 'stringBuffer2'
  MOV	BL, 0
  MOV	[EDI], BL
  INC	EDI
  
  ; convert value to string. resulting string is stored in reverse order in 'stringBuffer2'
  MOV	EAX, [ESI]				; Dividend (aka. Numerator). move current numerical value stored into EAX
_numberToString:
  MOV	EDX, 0					; clear high dividend
  DIV	tenDiv					; Postcondition of DIV: EAX stores quotient, EDX stores Remainder
  MOV	quotient, EAX			; store quotient
  ADD	EDX, 48					; convert remainder to ASCII value
  MOV	[EDI] ,DL				; store ASCII value in 'stringBuffer2'
  MOV	EAX, quotient			; initialize next loop's Dividend (aka. Numerator) with the resulting quotient
  INC	EDI
  CMP	quotient, 0	
  JNE	_numberToString
  DEC	EDI

  ; reverse stored string to get the in-order string representation and store in 'stringBuffer3'
  MOV	EAX, 0					; clear upper registers of EAX
  MOV	EDX, 0					; clear upper registers of EDX
  MOV	ESI, EDI			    ; pass the address of the last element in 'stringBuffer2' to ESI
  MOV	EDI, [EBP+16]			; EDI = memory address of 'stringBuffer3'

  ; add '-' symbol to string, if necessary
  CMP	isNegative, 1
  JNE	_reverseString
  MOV	AL, 45
  MOV	[EDI], AL				; insert '-' symbol (45d) as first character in string 
  INC	EDI

_reverseString:
  ; reverse string
  MOV	AL, [ESI]
  MOV	[EDI], AL
  DEC	ESI
  INC	EDI
  INC	characterCount			; count the number of characters
  MOV	BL, 0
  CMP	[ESI], BL				; check if null value has been reached in the source (reversed) string
  JNE	_reverseString
  MOV	[EDI], BL				; add null value to destination string

  mDisplayString [EBP+16]		; display the string

  ;reset stringBuffer2 back to 0
  MOV	ECX, characterCount
_resetStringBuffer2:
  MOV	EDI, [EBP+12]			; EDI = memory address of 'stringBuffer2'
  MOV	EAX, 0					
  MOV	[EDI], EAX				; reset stringBuffer value to 0
  INC	EDI
  LOOP	_resetStringBuffer2

  ;reset stringBuffer3 back to 0
  MOV	ECX, characterCount
_resetStringBuffer3:
  MOV	EDI, [EBP+16]			; EDI = memory address of 'stringBuffer3'
  MOV	EAX, 0					
  MOV	[EDI], EAX				; reset stringBuffer value to 0
  INC	EDI
  LOOP	_resetStringBuffer3

  POP	ESI
  POP	EDI
  POP	EDX
  POP	ECX
  POP	EBX
  POP	EAX
  RET	12
writeVal ENDP

END main
