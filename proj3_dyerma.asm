TITLE Project Three     (proj3_dyerma.asm)

; Author: Matthew Dyer
; Last Modified: October 24th, 2022
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271
; Project Number:3                Due Date: October 30th, 2022
; Description: Project 3 - Data Validation, Looping, and Constants
; This program will do the following:
;			-Display the program title and programmer's name
;			-Get the user's name, and greet the user
;			-Display instructions for the user
;			-Repeatedly prompt the user to enter a negative number until they enter a positive number
;			-Validate the user input to be within the bounds (inclusive) defined as constants
;			-Notify the user of any invalid negative numbers (not in range)
;			-Count and accumulate the valid user numbers until a non-negative number is entered (using SIGN (SF) flag)
;			-Calculate the rounded integer average of the valid numbers and store in a variable
;			-Display the count of numbers entered
;				-if no valid numbers entered, tell the user and skip to parting message
;			-Display the sum of valid integers
;			-Display the maximum valid user value entered
;			-Display the minimum valid user value entered
;			-Display the average, rounded to the nearest integer
;			-Display a parting message with the user's name

INCLUDE Irvine32.inc

LOW_MIN = -200
LOW_MAX = -100
HIGH_MIN = -50
HIGH_MAX = -1
NAME_MAX = 31

.data
intro_1			BYTE	"'Project 3 - Data Validation, Looping, and Constants' by Matthew Dyer",0
intro_2			BYTE	"We will be accumulating user-input negative integers between the specified bounds, ",13,10,
						"then displaying statistics of the input values",13,10,
						"including minimum, maximum, and average values, total sum,",13,10,
						"and total number of valid inputs.",0
ask_for_name	BYTE	"What is your name?",0
name_prompt		BYTE	"Name: ",0
user_name		BYTE	NAME_MAX+1	DUP(0)		; Name to be entered by the user
greeting		BYTE	"Hello, ",0
instruction_1	BYTE	"Please enter numbers in [-200, -100] or [-50, -1].",0
instruction_2	BYTE	"Enter a non-negative number when you are finished, and input stats will be shown.",0
number_prompt	BYTE	". Enter a number: ",0
user_input		DWORD	?						; Number to be inputted by the user
error_range		BYTE	"Input not accepted. Please enter a negative number between -200 to -100, or -50 to -1.",0
min				DWORD	-1						; the minimum number inputtted.
max				DWORD	-200					; the maximum number inputted
count			DWORD	?						; the number of inputted numbers
sum				DWORD	?						; the sum of all inputted numbers
average			DWORD	?						; the rounded average of all inputted numbers
average_dec		DWORD	?						; the average of all inputted numbers rounded to nearest 1/100th decimal point
min_string		BYTE	"The minimum number entered: ",0
max_string		BYTE	"The maximum number entered: ",0
count_string	BYTE	"The number of numbers entered: ",0
sum_string		BYTE	"The sum of numbers entered: ",0
average_string	BYTE	"The rounded average of numbers entered: ",0
parting			BYTE	"Thanks for using my program, ",0
ex_cred_1		BYTE	"**EC: Numbered the lines during user input. Incremented the line number only for valid number entries",0
ex_cred_2		BYTE	"**EC: Calculate and display the average as a decimal-point number, rounded to the nearest .01.",0
dec_10th		DWORD	?						; will hold the 0.1 decimal point (1/10th spot)
dec_100th		DWORD	?						; will hold the 0.01 decimal point (1/100th spot)
dec_1000th		DWORD	?						; will hold the 0.001 decimal point (1/1000th spot)
decimal			BYTE	".",0
dec_string		BYTE	"The average rounded to nearest 1/100th decimal point: ",0
remainder		DWORD	?						; variable to hold remainder for decimal place calculation
divisor			DWORD	10						; divisor used for decimal point calculations

.code
main PROC
; ------------------------------------------
; Provide information about the program and
;	and the extra credit included
; ------------------------------------------
; Title and Author
	MOV		EDX, OFFSET		intro_1
	CALL	writestring
	CALL	CrLf

; Intro
	MOV		EDX, OFFSET		intro_2
	CALL	WriteString
	CALL	CrLf

; Extra Credit info
	MOV		EDX, OFFSET		ex_cred_1
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET		ex_cred_2
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

;---------------------------------------
; Get the user's name, greet the user
;	and provide instructions
; --------------------------------------
; Get user's name
	MOV		EDX, OFFSET		ask_for_name
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET		name_prompt
	CALL	WriteString
	MOV		EDX, OFFSET		user_name
	MOV		ECX, NAME_MAX	; buffer size - 1
	CALL	ReadString
	CALL	CrLf

; Greet user
	MOV		EDX, OFFSET		greeting
	CALL	WriteString
	MOV		EDX, OFFSET		user_name
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; Give instructions
	MOV		EDX, OFFSET		instruction_1
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET		instruction_2
	CALL	WriteString
	CALL	CrLf

; ---------------------------------------------
; User input loop: receive user input,
;	check whether it is within valid range.
;	jump to error message if it is not. 
;	Loop continues until a non-negative number
;	is inputted.
; ---------------------------------------------
top:						; top of loop
; Prompt for number
	MOV		EAX, count
	CALL	WriteDec
	MOV		EDX, OFFSET		number_prompt
	CALL	WriteString
	CALL	ReadInt

; Check if number is positive (using sign flag SF)
	CMP		EAX, 0
	JNS		not_negative

; Check if number is in first set of bounds
	CMP		EAX, LOW_MIN	; -200
	JL		out_of_bounds
	CMP		EAX, LOW_MAX	; -100
	JG		second_check
	JMP		accumulate

second_check:
	CMP		EAX, HIGH_MAX	; -1
	JG		out_of_bounds
	CMP		EAX, HIGH_MIN	; -50
	JL		out_of_bounds
	JMP		accumulate

; If input is out of bounds, tell the user and go back to top
out_of_bounds:
	MOV		EDX, OFFSET		error_range
	CALL	WriteString
	CALL	CrLf
	JMP		top

; ---------------------------------------------------------------------
; Accumulator: takes the user input and for each input the count
;	is incremented, the input is added to the sum, the program checks
;	if it is the biggest number so far and if so stores it in the max
;	variable, checks if the input is the smallest number so far and if 
;	so stores it in the min variable.
; ---------------------------------------------------------------------
accumulate:
; Increment the count
	INC		count

; Add to sum
	ADD		sum, EAX

; Make current number max if bigger than current max
	CMP		max, EAX
	JL		make_max
	JMP		not_max

; Set current number to max
make_max:
	MOV		max, EAX

; Check if current number is smaller than current min
not_max:
	CMP		min, EAX
	JG		make_min
	JMP		not_min

; Set current number to min
make_min:
	MOV		min, EAX

not_min:
	JMP		top

; -----------------------------------------------
; When a non-negative number is input, the average
;	is calculated by taking the sum of all input
;	numbers and dividing it by the count (number
;	of input numbers). Next the first decimal point
;	is calculated by taking the remainder of the
;	previous division, multiplying that by 10, and dividing
;	that number by the same number as before (the count).
;	The remainder from this division is compared to -5 to
;	decide which way to round.
; -----------------------------------------------
not_negative:						; If the number was non-negative
; Calculate the average of input numbers
	MOV		EAX, sum	
	CDQ						; converts DWORD to QWORD for IDIV
	IDIV	count
	MOV		average, EAX

; Calculate the 1/10th decimal point
	MOV		EAX, EDX		; take the remainder
	IMUL	EAX, -10			; multiply it times 10
	XOR		EDX, EDX		; clears EDX (makes it 0)
	IDIV	count			; divide it by the same as before
	CMP		EAX, 5			; compare decimal point to -5 to decide which way to round	
	JGE		round_down
	JMP		dont_round

round_down:
	DEC		average

; ---------------------------------------------------
; Take all the stats (sum, max, min, count, and average)  
;	and display them with their corresponding strings
; ---------------------------------------------------
dont_round:
; Display the count
	CALL	CrLf
	MOV		EDX, OFFSET		count_string
	MOV		EAX, count
	CALL	WriteString
	CALL	WriteDec
	CALL	CrLf

; Display the min
	MOV		EDX, OFFSET		min_string
	MOV		EAX, min
	CALL	WriteString
	CALL	WriteInt
	CALL	CrLf

; Display the max
	MOV		EDX, OFFSET		max_string
	MOV		EAX, max
	CALL	WriteString
	CALL	WriteInt
	CALL	CrLf

; Display the sum
	MOV		EDX, OFFSET		sum_string
	MOV		EAX, sum
	CALL	WriteString
	CALL	WriteInt
	CALL	CrLf

; Display the average
	MOV		EDX, OFFSET		average_string
	MOV		EAX, average
	CALL	WriteString
	CALL	WriteInt
	CALL	CrLf

; -------------------------------------------------------
; Recalculate the average and first decimal point. Using 
;	the average's remainder, this time multiplied by -10
;	instead to get a positive integer, we again divide by 
;	the count to. The remainder is stored in a variable 
;	for use in finding the next decimal point. The quotient
;	is divided by 10 and the remainder from that is our decimal
;	first decimal point. Repeat this process using the remainder
;	stored in the variable for each subsequent decimal point.
;	The third decimal point (1/1000th place) is calculated to
;	decide whether to round the second decimal point (1/100th place)
;	or not.
; -------------------------------------------------------
; Calculate the average of input numbers again
	MOV		EAX, sum	
	CDQ						; converts DWORD to QWORD for IDIV
	IDIV	count
	MOV		average, EAX

; Calculate the 1/10th decimal point again
	MOV		EAX, EDX		
	IMUL	EAX, -10			
	XOR		EDX, EDX		
	IDIV	count		
	MOV		remainder, EDX
	XOR		EDX, EDX
	IDIV	divisor		
	MOV		dec_10th, EDX

; Calculate the 1/100th decimal point
	MOV		EAX, remainder		
	IMUL	EAX, 10
	XOR		EDX, EDX
	IDIV	count
	MOV		remainder, EDX
	XOR		EDX, EDX
	IDIV	divisor		
	MOV		dec_100th, EDX


; Check 1/1000th decimal place to see if the 1/100th decimal place needs to be rounded	
	MOV		EAX, remainder
	IMUL	EAX, 10
	XOR		EDX, EDX
	IDIV	count
	CMP		EAX, 5			
	JGE		rnd_up_dec
	JMP		dnt_rnd_dec

rnd_up_dec:
	INC		dec_100th

; -------------------------------------------------
; Take the previous extra credit decimal point average
;	calculations and display them piece by piece to
;	the user. Display a parting message and end the 
;	program.
; -------------------------------------------------
dnt_rnd_dec:
; Display the average of all input numbers rounded to nearest 1/100th decimal point
	MOV		EDX, OFFSET		dec_string
	CALL	WriteString
	MOV		EAX, average
	CALL	WriteInt
	MOV		EDX, OFFSET		decimal
	CALL	WriteString
	MOV		EAX, dec_10th
	CALL	WriteDec
	MOV		EAX, dec_100th
	CALL	WriteDec
	CALL	CrLf
	
; Parting message
	MOV		EDX, OFFSET		parting
	CALL	WriteString
	MOV		EDX, OFFSET		user_name
	CALL	WriteString
	CALL	CrLf


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
