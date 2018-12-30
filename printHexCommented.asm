;;;; I modified the program found on page 27 of Igor Zhirkov's
;;;; "Low Level Programming", so that it doesn't print leading
;;;; zeros and prints negative numbers.
;;;; 

section .data
newline db 0xa
codes db '0123456789abcdef'	; This string is used to look up the ascii character
				; to print for each hexadecimal digit
negsign db '-'			; This ascii character will be printed in front
				; of negative numbers 

section .text
global _start

print_newline:			; prints a newline 
	mov rax, 1		; syscall #1 is print to screen
	mov rdi, 1		; file descriptor is 1 for stdout
	mov rsi, newline	; move address of the newline variable from .data into rsi
	mov rdx, 1		; one byte will be printed
	syscall
	ret			; go back to where ever print_newline was called

print_hex:

	push rbx		; probably unnecessarily saving rbx before usage
	xor rbx, rbx		; clear rbx, which will be used as a flag inside iterate loop
	mov rax, rdi		; mov the number found within _start into rax register
	mov rdi, 1		; getting ready for print syscall which won't happen til later
	mov rdx, 1		; same as last line
	mov rcx, 64		; 64 for 64 bits in the rax register. counter will be decremented
				; by four each time through the 'iterate' loop below
	
	cmp rax, 0		; if rax is positive, 
	jg iterate		; jump straight to iterate. no need to change anything.
	not rax			; if rax is negative, we flip the bits
	inc rax			; and add one, since it was a twos complement negative number.
	
	
	push rcx		; save rcx on stack before printing ascii negsign
	push rax		; save rax on stack before printing ascii negsign

	mov rax, 1		; syscall #1 for print to screen
	mov rsi, negsign	; ascii negsign moved to rsi for print syscall
	syscall
	
	pop rax			; pop rax back from stack
	pop rcx			; pop rcx back from stack
	
	

iterate:
	push rax		; push rax to stack
	sub rcx, 4		; 1st time through loop, rcx becomes 60
	shr rax, cl		; 1st time through loop, shift rax right by 60
				; 1st time through loop, first (most significant) four bits 
				; are moved to the front (least significant) four bits.
	and rax, 0xf		; clear all bits in rax except four least significant bits

	cmp rbx, 1		; rbx is used as a flag. if it's 1, that means we've hit a number
				; that isn't 1 already, in which case any number will be printed.
				; if we haven't yet hit a number that isn't zero, we skip over it.
				; that way, leading zeros aren't printed. 000750 becomes 750 in
				; the output.
	je continue1		; if rbx is 0, jump to continue1 label
	cmp rax, 0		; compare what's in rax to 0
	je continue2		; if it's zero, jump to continue2
	mov rbx, 1		; if we got to this instruction, it means 1/ we have yet to 
				; print a non-zero character, and rax contains a non-zero 
				; character. so rbx flag is set to 1. in future loops, we will
				; skip straight to continue1

	continue1:

	lea rsi, [codes + rax]	; take the address of codes, add rax to it, then look up what
				; ascii character to print

	mov rax, 1		; syscall #1 for print to screen
	
	push rcx		; save rcx by pushing it to stack
	syscall			; print the ascii character
	pop rcx			; get rcx back

	continue2:

	pop rax			; bring rax back to its original number from before we shifted
				; its bits
	test rcx, rcx		; see if rcx is zero yet
	jnz iterate		; if it's not, go through loop again
	pop rbx			; get rbx back (probably not necessary)
	ret			; return to _start

_start:
	mov rdi, -0x90210666420			; here's the number the program will print.
						; it can be a 64-bit positive number or a 
						; 63-bit negative number
	call print_hex				; call the print function we wrote above
	call print_newline			; print a new line

	mov rax, 60				; syscall #60 is exit
	xor rdi, rdi				; clear rdi
	syscall					; bye bye
