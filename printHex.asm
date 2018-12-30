;;;; I modified the program found on page 27 of Igor Zhirkov's
;;;; "Low Level Programming", so that it doesn't print leading
;;;; zeros and prints negative numbers.
;;;;

section .data
newline db 0xa
codes db '0123456789abcdef'	
negsign db '-'			
				 
section .text
global _start

print_newline:
	mov rax, 1		
	mov rdi, 1		
	mov rsi, newline	
	mov rdx, 1		
	syscall
	ret		

print_hex:
	push rbx	
	xor rbx, rbx
	mov rax, rdi
	mov rdi, 1	
	mov rdx, 1
	mov rcx, 64

	cmp rax, 0
	jg iterate
	not rax		
	inc rax	
		
	push rcx
	push rax

	mov rax, 1		
	mov rsi, negsign
	syscall
	
	pop rax			
	pop rcx		
	
iterate:
	push rax
	sub rcx, 4	
	shr rax, cl	
	and rax, 0xf	
	cmp rbx, 1
	je continue1

	cmp rax, 0	
	je continue2	

	mov rbx, 1	

	continue1:

	lea rsi, [codes + rax]	

	mov rax, 1	
	push rcx	
	syscall		
	pop rcx		

	continue2:

	pop rax		
	test rcx, rcx	
	jnz iterate
	pop rbx	
	ret		

_start:
	mov rdi, -0x90210666420	
	call print_hex			
	call print_newline	

	mov rax, 60	
	xor rdi, rdi		
	syscall				
