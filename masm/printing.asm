;; bool PrintStr(string: r8 char*, len: r9 u64)
;; Prints EXACTLY len characters
align qword
PrintStrSized proc
	local		holder: qword

	; return WriteConsole(
	;	GetStdHandle(STD_OUTPUT_HANDLE),
	;	string, len, nullptr, nullptr);
	mov		rax, STD_OUTPUT_HANDLE
	WinCall		GetStdHandle, rax
	WinCall		WriteConsole, rax, r8, r9, 0, 0

	ret
PrintStrSized endp

; bool PrintNewLine(void)
align qword
PrintNewLine proc
	local	holder: qword
	local	nl_lit: qword
	local	nl_lit_size: qword
	
	lea	rax, consts.newline_literal
	mov	nl_lit, rax
	mov	rax, sizeof consts.newline_literal
	dec	rax
	mov	nl_lit_size, rax

	mov	rax, STD_OUTPUT_HANDLE
	WinCall	GetStdHandle, rax
	WinCall	WriteConsole, rax, nl_lit, nl_lit_size, 0, 0
	ret
PrintNewLine endp


;; bool PrintStr(string: r8 char*, len: r9 u64)
;; Prints len characters minus one
;; (because WriteConsole also advances the cursor when NUL is printed)
align qword
PrintStr proc
	dec	r9
	call	PrintStrSized
	ret
PrintStr endp


; bool Println(string: r8 char*, len: r9 u64)
; Prints (len - 1) characters, then prints a newline
; r8 and r9 not preserved
align qword
PrintLine proc
	call	PrintStr
	call	PrintNewLine
	ret
PrintLine endp

; bool Println(string: r8 char*, len: r9 u64)
; Prints (len) characters, then prints a newline
; r8 and r9 not preserved
align qword
PrintLineSized proc
	call	PrintStrSized
	call	PrintNewLine
	ret
PrintLineSized endp

; bool PrintByteArrayHex(string ptr: rsi, strlen: rcx)
; rax, rsi, rcx, r8 and r9 get consumed
align qword
PrintByteArrayHex proc
	local		character: byte

print_starting_brace:
	mov		character, CHAR_BRACKET_SQ_L
	lea		r8, character
	mov		r9, 1
	call		PrintStrSized

print_byte_loop:
	dec		rcx
	jrcxz		print_ending_brace
	call		PrintByteHex
	jmp print_byte_loop

print_ending_brace:
	mov		character, CHAR_BRACKET_SQ_R
	lea		r8, character
	mov		r9, 1
	call		PrintStrSized
	ret
PrintByteArrayHex endp

; bool PrintByteHex(char ptr: rsi)
; r8 and r9 consumed
align qword
PrintByteHex proc
	local		char_hi: byte
	local		char_lo: byte

	; Fill high order bytes:
	mov		r8b, byte ptr [rsi]
	mov		char_hi, r8b
	and		char_hi, 0fh

	; Fill low order bytes
	and		r8b, 0f0h
	shr		r8b, 4
	mov		char_lo, r8b

	; Print high order byte
	cmp		r8b, 00h
	je		print_zero1
	cmp		r8b, 01h
	je		print_one1
	cmp		r8b, 02h
	je		print_two1
	cmp		r8b, 03h
	je		print_three1
	cmp		r8b, 04h
	je		print_four1
	cmp		r8b, 05h
	je		print_five1
	cmp		r8b, 06h
	je		print_six1
	cmp		r8b, 07h
	je		print_seven1
	cmp		r8b, 08h
	je		print_eight1
	cmp		r8b, 09h
	je		print_nine1
	cmp		r8b, 0ah
	je		print_a1
	cmp		r8b, 0bh
	je		print_b1
	cmp		r8b, 0ch
	je		print_c1
	cmp		r8b, 0dh
	je		print_d1
	cmp		r8b, 0eh
	je		print_e1
	cmp		r8b, 0fh
	je		print_f1
	jmp		print_lower_byte

print_zero1:
print_one1:
print_two1:
print_three1:
print_four1:
print_five1:
print_six1:
print_seven1:
print_eight1:
print_nine1:
print_a1:
print_b1:
print_c1:
print_d1:
print_e1:
print_f1:
	mov	al, rax ; TODO!

	; Print low order byte
print_lower_byte:

	ret
PrintByteHex endp
