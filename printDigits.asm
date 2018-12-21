section .data
	num dq 666 	; put any decimal number here, up to the max number a 64-bit register can hold.

section .bss
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

