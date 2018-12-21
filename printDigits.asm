section .data
	num dq 666 	

section .bss
	asciiByte resb 1

section .text
	global _start

_start:
	mov rax, [num]
	call _printDigits	

	mov rax, 60		
	mov rdi, 0
	syscall
		
_printDigits:			
	xor r9, r9	
__digitsToBytes:
	xor rdx, rdx	
	inc r9				
	mov rbx, 10		
	div rbx		
	push rdx	
	cmp rax, 0		
	jne __digitsToBytes
	mov r10, asciiByte	
__printNums:
	pop rbx		
	add bl, '0'	
	mov [r10], bl 	
	
	mov rsi, r10	
	mov rax, 1
	mov rdi, 1
	mov rdx, 1
	syscall
	
	dec r9		
	cmp r9, 0	
	jne __printNums
	ret
