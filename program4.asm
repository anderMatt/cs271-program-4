TITLE Program 4     (program4.asm)

; Author: Matthew Anderson		   anderma8@oregonstate.edu
; CS 271 Program 4                 Date: February 10, 2018
; Description:

INCLUDE Irvine32.inc

; (insert constant definitions here)

LOWER_LIMIT = 1			;smallest value accepted as valid input 	
UPPER_LIMIT = 400		;largest value accepted as valid input

.data
; (insert variable definitions here)
programName		BYTE	"Composite Number Calculator",0
myName			BYTE	"Written by: Matthew Anderson",0

inputPrompt		BYTE	"Enter a value for N in [1, 400], and I will display the first N composite numbers: ",0
errInputPrompt	BYTE	"Number must be in [1, 400]. Try again: ",0

currNum			DWORD	3
printTotal		DWORD	?		;number of composite numbers user wants us to print
printCount		DWORD	0		;number of composite numbers we have already printed.

gutter			BYTE	"   ",0	
goodbye			BYTE	"Goodbye!", 0


;---------------------------
; FOR TESTING
;---------------------------
yesStr BYTE "that IS composite", 0
noStr BYTE	"that is NOT composite", 0


.code
main PROC

; (insert executable instructions here)
	call	Introduction
	call	GetUserData
	call	Initialize
	call	PrintComposites
	call	Farewell

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

;---------------------------------------------
Introduction PROC
;
; Prints a greeting message and 
; instructions to user
;
;---------------------------------------------
	mov		edx, OFFSET programName
	call	WriteString
	call	CrLf
	mov		edx, OFFSET myName
	call	WriteString
	call	CrLf
	ret
Introduction ENDP


;--------------------------------------------------
GetUserData PROC

; Prompts user to enter a number N in [1, 400], to
; calculate and display the first N composite numbers.
; Returns: EAX = valid input, in [1, 400]
;--------------------------------------------------
	mov		edx, OFFSET inputPrompt
	call	WriteString

readInput:  call ReadInt		;Read integer entered by user
	call	Validate
	jz		inputValid

	;entered number not in [1, 400]. Print error message, and try again.
	mov		edx, OFFSET errInputPrompt
	call	WriteString
	jmp		readInput

inputValid:	
	;mov		printTotal, eax		;Save number of composites user wants us to print
	ret
GetUserData ENDP


;--------------------------------------------------
Initialize PROC

; Initializes registers to computing the first N
; composite numbers.
; Pre-conditions: EAX is number of composite numbers
; to print.
;--------------------------------------------------
	mov		ecx, eax
	;dec		ecx
	ret

Initialize ENDP


;--------------------------------------------------
Validate PROC

; Validates that user input is in [1, 400].
; Receives: EAX = integer entered by user
; Returns: ZF=1 if EAX contains integer in [1, 400];
; otherwise, ZF=0
;--------------------------------------------------

	cmp		eax, LOWER_LIMIT
	jb		notValid			;#2ZF=0 if dest < source
	cmp		eax, UPPER_LIMIT
	ja		notValid			;#2ZF=0 if dest > source
	test	eax, 0				;#5ZF = 1

notValid: ret					;#?ZF = 0
Validate ENDP


;--------------------------------------------------
IsComposite PROC

; Checks if the current number in EAX is composite.
; Receives: EAX = number to check
; Returns: ZF=1 if number in EAX is composite;
; otherwise, ZF=0
;
; USES ebx, edx, esi
;--------------------------------------------------

	;Check if currNumber is divisible by any number in [2, currNumber], other than itself.
	mov		ebx, 2

;check if currNumber is divisible by next number in [2, currNumber] sequence
next:	
	mov		esi, eax
	cmp		eax, ebx
	je		no			;Not divisible by anything in [2, currNum], so not composite.

	xor		edx, edx
	div		ebx
	cmp		edx, 0		;is divisible
	je		done	

	inc		ebx			;set EBX to next divisor in [2, currNum]
	mov		eax, esi
	jmp		next

no:
	cmp edx, 0			;set ZF = 0. We know EDX is never 0 here, otherwise, it would be composite.

done: ret

IsComposite ENDP


;--------------------------------------------------
GetNextComposite PROC
; Checks if currNum is a composite number.
; Returns:  currNum = the next composite number.
;--------------------------------------------------

checkNext:
	inc		currNum
	mov		eax, currNum
	call	IsComposite
	jnz		checkNext
	ret

GetNextComposite ENDP



;--------------------------------------------------
PrintComposites PROC
; Prints the first N composite numbers.

; Pre-conditions: ECX=N, the number of composite
; numbers to print.
;--------------------------------------------------

doNext:
	call	GetNextComposite
	call	Print
	loop	doNext
	ret

PrintComposites ENDP


;--------------------------------------------------
Print PROC
; Prints currNum
;--------------------------------------------------
	mov		edx, OFFSET gutter
	call	WriteString

	push	eax		;Preserve registers.
	push	ebx
	push	edx

	;Print current composite number.
	mov		eax, currNum
	call	WriteDec
	inc		printCount

	;Check if we need a new line - print count divisible by 10.
	mov		eax, printCount
	xor		edx, edx
	mov		ebx, 10
	div		ebx

	cmp		edx, 0
	jne		done

	;print a new line
	call	CrLf

done:
	pop		edx
	pop		ebx
	pop		eax
	ret

Print ENDP


;--------------------------------------------------
Farewell PROC
; Prints farewell message to the user, and exits
;--------------------------------------------------
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf
	ret

Farewell ENDP
END main
