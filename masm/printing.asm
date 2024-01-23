; TODO: maybe save all general purpose registers before printing
;  	restore them after printing over

; bool PrintStr(string: r8 char*, len: r9 u64)
; Prints EXACTLY len characters
align qword
PrintStrSized proc
	local		holder: qword
	local		temp: qword
	mov		temp, rcx

	; return WriteConsole(
	;	GetStdHandle(STD_OUTPUT_HANDLE),
	;	string, len, nullptr, nullptr);
	mov		rax, STD_OUTPUT_HANDLE
	WinCall		GetStdHandle, rax
	WinCall		WriteConsole, rax, r8, r9, 0, 0

	mov		rcx, temp
	ret
PrintStrSized endp

; bool PrintNewLine(void)
align qword
PrintNewLine proc
	local		holder: qword
	local		nl_lit: qword
	local		nl_lit_size: qword
	local		temp: qword
	
	mov		temp, rcx
	
	lea		rax, consts.newline_literal
	mov		nl_lit, rax
	mov		rax, sizeof consts.newline_literal
	dec		rax
	mov		nl_lit_size, rax

	mov		rax, STD_OUTPUT_HANDLE
	WinCall		GetStdHandle, rax
	WinCall		WriteConsole, rax, nl_lit, nl_lit_size, 0, 0

	mov		rcx, temp
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
	
	mov		character, CHAR_SPACE
	lea		r8, character
	mov		r9, 1
	call		PrintStrSized

print_byte_loop:
	dec		rcx
	jrcxz		print_ending_brace
	
	call		PrintByteHex
	inc		rsi

	mov		character, CHAR_SPACE
	lea		r8, character
	mov		r9, 1
	call		PrintStrSized

	jmp		print_byte_loop

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

	; Temporariliy store bytes
	mov		r8b, byte ptr [rsi]
	mov		char_hi, r8b
	and		char_hi, 0fh

	and		r8b, 0f0h
	shr		r8b, 4
	mov		char_lo, r8b
	
	; Convert higher order byte to ascii
	; NOTE: 'a' - '9' = 27h
	mov		r8b, char_hi
	add		r8b, CHAR_ZERO
	cmp		r8b, CHAR_NINE
	mov		char_hi, r8b
	jbe		conv_lower_byte
	add		r8b, 27h
	mov		char_hi, r8b

conv_lower_byte:
	mov		r8b, char_lo
	add		r8b, CHAR_ZERO
	cmp		r8b, CHAR_NINE
	mov		char_lo, r8b
	jbe		print_bytes
	add		r8b, 27h
	mov		char_lo, r8b

	; Yes, i know the variables are swapped
	; This is intentional
print_bytes:
	lea		r8, char_lo
	mov		r9, 1
	call		PrintStrSized
	
	lea		r8, char_hi	
	mov		r9, 1
	call		PrintStrSized

	ret
PrintByteHex endp
