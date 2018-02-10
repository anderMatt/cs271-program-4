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



.code
main PROC

; (insert executable instructions here)
	call	Introduction
	call	GetUserData

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

readInput:  call ReadInt	;Read integer entered by user
	call	Validate
	jz		inputValid

	;entered number not in [1, 400]. Print error message, and try again.
	mov		edx, OFFSET errInputPrompt
	call	WriteString
	jmp		readInput

inputValid:	ret
GetUserData ENDP



;--------------------------------------------------
Validate PROC

; Validates that user input is in [1, 400].
; Receives: EAX = integer entered by user
; Returns: ZF=1 if EAX contains integer in [1, 400];
; otherwise, ZF=0
;--------------------------------------------------

	cmp		eax, LOWER_LIMIT
	jb		notValid			;ZF=0 if dest < source
	cmp		eax, UPPER_LIMIT
	ja		notValid			;ZF=0 if dest > source
	test	eax, 0				;ZF = 1

notValid:	ret					;ZF = 0
Validate ENDP

END main
