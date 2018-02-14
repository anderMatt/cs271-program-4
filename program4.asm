TITLE Program 4     (program4.asm)

; Author: Matthew Anderson		   anderma8@oregonstate.edu
; CS 271 Program 4                 Date: February 13, 2018
; Description: Prompts user to enter a value for N in [1,400], and then computes
; and displays the first N composite numbers. Validates that N is in the valid
; range.

INCLUDE Irvine32.inc

LOWER_LIMIT = 1			;smallest value accepted as valid input 	
UPPER_LIMIT = 400		;largest value accepted as valid input

.data
programName		BYTE	"Composite Number Calculator",0
myName			BYTE	"Written by: Matthew Anderson",0

inputPrompt		BYTE	"Enter a value for N in [1, 400], and I will display the first N composite numbers: ",0
errInputPrompt	BYTE	"Number must be in [1, 400]. Try again: ",0

currNum			DWORD	3
printTotal		DWORD	?		;number of composite numbers user wants us to print
printCount		DWORD	0		;number of composite numbers we have already printed.

gutter			BYTE	"     ",0	
space			BYTE	" ",0
goodbye			BYTE	"Goodbye!", 0


.code
main PROC

	call	Introduction
	call	GetUserData
	call	PrintComposites
	call	Farewell

	exit	; exit to operating system

main ENDP


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
; If user enters an invalid number, they are prompted
; again.
; Returns: EAX = entered number, in [1,400]
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
	mov		printTotal, eax		;Save number of composites user wants us to print
	ret
GetUserData ENDP


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

; Pre-conditions: EAX=N, the number of composite
; numbers to compute and print.
; Uses: ECX
;--------------------------------------------------

	mov		ecx, eax		
doNext:
	call	GetNextComposite	;sets currNum = next composite in series
	call	Print				
	loop	doNext
	ret

PrintComposites ENDP


;--------------------------------------------------
Print PROC
; Prints currNum. Right-aligns by left-
; padding with spaces, equal to (3-number of digits)
; Uses: eax, ebx, ecx, edx
;--------------------------------------------------

	pushad			;Preserve registers

	;Count number of digits in number being printed, to align output.
	;This is done by continually dividing by 10, until reaching 0.
	mov		eax, currNum
	mov		ebx, 10
	mov		ecx, 0	;Accumulator for number of digits

countDigit:
	inc		ecx
	xor		edx, edx
	div		ebx
	cmp		eax, 0
	jne		countDigit

	;Print spaces equal to (3-num digits) to right-align output.

	;If number already has 3 digits, no padding needed - it is already right-aligned.
	cmp		ecx, 3
	je		printNumber

	;Set ECX to number of spaces we need to print.
	neg		ecx
	add		ecx, 3

printSpace:
	mov		edx, OFFSET space
	call	WriteString
	loop	printSpace

printNumber:
	;Print current composite number.
	mov		eax, currNum
	call	WriteDec
	inc		printCount

	mov		edx, OFFSET gutter
	call	WriteString

	;Check if we need a new line - print count divisible by 10.
	mov		eax, printCount
	xor		edx, edx
	mov		ebx, 10
	div		ebx

	cmp		edx, 0
	jne		done

	;10 numbers exist on current line. Move to next line.
	call	CrLf

done:
	popad		
	ret

Print ENDP


;--------------------------------------------------
Farewell PROC
; Prints farewell message to the user.
;--------------------------------------------------
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf
	ret

Farewell ENDP

END main
