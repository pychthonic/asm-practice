	; any words to the right of a semi-colon are called comments and ignored by the computer.
	; this is my first heavily commented assembly program.
	; in assembly, even basic things like printing letters and numbers to the screen require 
	; lots of instructions. 
	; In order to "print" i.e. send numbers, letters, punctuation marks, and other symbols to the screen,
	; you need to convert each decimal digit into an ascii character. For example, if you're printing the 
	; number 430 to the screen, you'll have to first convert the number '4' to an ascii character, print it 
	; to the screen, then do the same for the number '3', then do the same for the number '0'.
	
	; More commentary coming soon. I'll add comments throughout the week. The goal is to have all lines 
	; explained so that even someone with very little or no experience with assembly language programming 
	; can see what each line does and understand what it means, or something close to it.


section .data			 ; the lines until the next section will contain initialized variables.
	num dq 66690210 	; 'num' is the name of the variable. 'dq' means define quad word, which is 
				; telling the computer that the variable will use one quad word of space, which is 
				; 64 bits. if you're using an x86_64 machine, then your registers hold 64 bits each.
				; Put any decimal number here, up to the max number a 64-bit register can hold. 
				; Just replace the one I put ("90210666") with the number to print to screen.

section .bss			; this means "This section will contain uninitialized data." Uninitialized data
				; is variables whose values are not defined until the program runs. In this program,
				; an uninitialized variable called 'asciiByte' will be used to store digits before
				; they're printed to screen. 
	asciiByte resb 1

section .text
	global _start

_start:
	mov rax, [num]
	call _printDigits	

	mov rax, 60		; exit
	mov rdi, 0
	syscall
		

_printDigits:			
	xor r9, r9	; zeroing out r9 just in case

digitsToBytes:
	xor rdx, rdx	; clear remainder from last time through loop (see line 21)
	inc r9		; r9 is used to keep track of how many times loop happened
			; which is used later when printing out the digits
	mov rbx, 10		
	div rbx		; uses rax as dividend (rdx was zerod out), puts quotient in rax, and 
			; remainder in rdx
	push rdx	; which gets pushed onto stack

	cmp rax, 0	; if the number divided by 10 is zero, then we have all the numbers
				; on the stack and we can start printing them, in dumpnums
	jne digitsToBytes

	mov r10, asciiByte	; move address of the uninitialized .bss byte into r10

printNums:
	pop rbx		; take first digit off the stack (or whichever one you're at in the loop)
	add bl, '0'	; make it into ascii char digit
	
	mov [r10], bl 	; move it into asciiByte
	
	mov rsi, r10	; move asciiByte into rsi for printing
	mov rax, 1
	mov rdi, 1
	mov rdx, 1
	syscall
	
	dec r9		; r9 counted up how many digits we have to print above in digitsToBytes
	cmp r9, 0	; now we count down.
	jne printNums

	ret

