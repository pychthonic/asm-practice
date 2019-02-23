;;;; This is a library of basic assembly functions: exit, find string length, print string
;;;; to stdout, print character to stdout, print newline to stdout, print unsigned int to
;;;; stdout, print int to stdout, test two strings for equivalence, read character from stdin, 
;;;; read word from stdin, parse string for unsigned int, parse string for signed int, and 
;;;; copy string.

section .text					; The .text section is where executable instructions go.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

exit:						; this first function cleanly exits the program.
	xor rdi, rdi				; xor'ing the same register twice makes it all 0's
	mov rax, 60				; moving the number 60 into the rax register means exit 
						; if a syscall is subsequently called.
	syscall					; annnnd there's the syscall. The program checks the rax register,
						; finds the number 60 from the previous instruction, and exits.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string_length:
	xor rax, rax				; clear all rax bits
 
_string_length_loop:
	cmp byte [rdi + rax], 0			; compare the byte of data found at (rdi + rax) to 0. rax contains 0 the 
						; first time through the loop, and is incremented by 1 each time through
						; the loop.
	je _string_length_exit			; if the byte of data found at (rdi + rax) is equal to zero, jump to
						; _string_length_exit
	inc rax					; adds 1 to rax
	jmp _string_length_loop			; start the loop over

_string_length_exit:
   	ret					; return to where the function was called. rax will hold the number
						; of characters in the string.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_string:	
	call string_length			; this will put the number of characters contained by the string in rax
	mov rdx, rax				; move rax number into rdx

    	mov rsi, rdi				; move the address in rdi into rsi 
    	mov rdi, 1				
    	mov rax, 1				
    	syscall
    	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_char:
	push rdi				; push rdi which contains the character to be printed onto stack

	mov rax, 1				
	mov rsi, rsp				; push stack pointer into rsi, so it points to what we just pushed onto it
	mov rdi, 1
	mov rdx, 1
	syscall					; write it to the screen

	pop rdi					; pop the character back into rdi
	ret					; return to the line that called print_char

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_newline:
	mov rdi, 0xa
	call print_char
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_uint:
	push rbx
	xor r9, r9
	mov rax, rdi
	
_print_uint_loop1:
	xor rdx, rdx
	inc r9
	mov rbx, 10
	div rbx
	add dl, '0'
	push rdx
	cmp rax, 0
	jne _print_uint_loop1

_print_uint_loop2:
	pop rsi
	push r9
	push rsi

	mov rax, 1
	mov rdi, 1
	mov rsi, rsp
	mov rdx, 1
	syscall

	pop rsi
	pop r9

_print_uint_pass:
	dec r9
	cmp r9, 0
	jne _print_uint_loop2
	pop rbx
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_int:
    	xor rax, rax
	cmp rdi, 0
	jge print_uint
	neg rdi
	push rdi	

	mov rdi, '-'
	call print_char
	
	pop rdi
	call print_uint
    	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string_equals:
	push rbx
	push r9
	push r10
	push r11
	push r12

	mov r9, rdi
	mov r11, rsi
	call string_length
	mov rbx, rax
	mov rdi, rsi
	call string_length
	mov rcx, rax
	cmp rbx, rcx
	jne _strings_not_equal_exit
	
_string_compare_loop:
	cmp byte [r9], 0
	je _strings_equal_exit
	xor rax, rax
	xor rbx, rbx

	mov al, byte [r9]
	mov bl, byte [r11]
	cmp rax, rbx
	jne _strings_not_equal_exit
	inc r9
	inc r11
	dec rcx
	cmp rcx, 0
	jne _string_compare_loop

_strings_equal_exit:
	mov rax, 1

	pop r12
	pop r11
	pop r10
	pop r9
	pop rbx
	ret

_strings_not_equal_exit:
	mov rax, 0
	
	pop r12
	pop r11
	pop r10
	pop r9
	pop rbx
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read_char:
	xor rax, rax
	push rax

	mov rdi, 0
	mov rsi, rsp
	mov rdx, 1
	syscall
	pop rax
	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read_word:
	push rbx	
	xor rbx, rbx
	xor rcx, rcx
	mov rdx, rsi
	
_read_word_main_loop:
	push rcx
	push rdx
	push rdi
	call read_char
	pop rdi
	pop rdx
	pop rcx
	
	cmp rbx, 1
	je _read_word_already_started
	
	cmp rax, ' '
	je _read_word_main_loop
	mov rbx, 1
	
_read_word_already_started:
	cmp rax, ' '
	je _read_word_end
	cmp rax, 0xa
	je _read_word_end
	cmp rax, 13
	je _read_word_end
	cmp rax, 9
	je _read_word_end
	cmp rax, ''
	je _read_word_end
	mov [rdi], al
	inc rdi
	inc rcx
	cmp rdx, rcx
	je _word_too_large
	jmp _read_word_main_loop

_read_word_end:
	mov rax, 0
	mov [rdi], al
	sub rdi, rcx
	mov rax, rdi
	mov rdx, rcx
	pop rbx
	ret

_word_too_large:
	sub rdi, rcx
	mov byte [rdi], 0
	mov rax, 0
	mov rdx, 0
	pop rbx
    	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

parse_uint:			; rdi points to a string
	push rbx		; returns rax: number, rdx : length
	push r9

	xor rax, rax
	xor rcx, rcx
	xor rdx, rdx

_parse_uint_findnextnum:
	cmp byte [rdi], 0x30
	jl _no_num
	cmp byte [rdi], 0x39
	jg _no_num
	mov cl, [rdi]
	sub cl, 0x30
	push rcx
	inc rdx
	inc rdi
	jmp _parse_uint_findnextnum

_no_num:
	cmp rdx, 0
	jg _parse_uint_convert
	cmp byte[rdi], 0
	je _no_num_exit
	inc rdi
	jmp _parse_uint_findnextnum
   
_parse_uint_convert:
	mov r9, rdx
	mov rcx, rdx
	dec rcx
	xor rdx, rdx
	
	pop rdx
	mov rbx, 1

	cmp rcx, 0
	je _parse_uint_end
	
_convert_loop:
	
	mov rax, rbx
	mov rbx, 10

	push rdx
	mul rbx
	pop rdx

	mov rbx, rax
	pop rax
	
	push rdx
	mul rbx
	pop rdx
	add rdx, rax

	dec rcx
	cmp rcx, 0
	jne _convert_loop

_parse_uint_end:

	mov rax, rdx
	mov rdx, r9
	
	pop r9
	pop rbx
    	ret

_no_num_exit:
	pop r9
	pop rbx
	mov rax, 0
	mov rdx, 0
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

parse_int:  			; rdi points to a string
				; returns rax: number, rdx : length
_parse_int_findnextnum:
	cmp byte [rdi], '-'
	je _parse_int_negnum
	cmp byte [rdi], 0x30
	jl _parse_int_no_num
	cmp byte [rdi], 0x39
	jg _parse_int_no_num
	
	call parse_uint
	ret
	
_parse_int_no_num:
	inc rdi
	jmp _parse_int_findnextnum

_parse_int_negnum:
	call parse_uint
	cmp rax, 0
	je _parse_int_nonum_exit
	inc rdx
	neg rax

_parse_int_nonum_exit:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string_copy:
	push r9
	push rbx
	call string_length
	cmp rax, rdx
	jge _string_copy_too_long_exit
	mov rcx, rdx
	inc rcx
	mov r9, rcx

_string_copy_loop:
	mov rbx, [rdi]
	mov [rsi], rbx
	inc rdi
	inc rsi
	dec rcx
	cmp rcx, 0
	je _string_copied_exit
	jmp _string_copy_loop
	
_string_copied_exit:	
	sub rsi, r9
	mov rax, rsi
	pop rbx
	pop r9
	ret

_string_copy_too_long_exit:
	mov rax, 0
	pop rbx
	pop r9
	ret
