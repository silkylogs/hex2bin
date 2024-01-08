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
	WinCall	WriteConsole, rax, r8, r9, 0, 0

	ret
PrintStrSized endp

;; bool PrintStr(string: r8 char*, len: r9 u64)
;; Prints len characters minus one
;; (because WriteConsole also advances the cursor when NUL is printed)
align qword
PrintStr proc
	dec	r9
	call	PrintStrSized
	ret
PrintStr endp

;; bool StrEquals(str1: rsi char*, str2: rdi char *, len: rcx u64)
StrEquals proc
loop_label:
	; Decrement and check counter
	dec		rcx
	jrcxz		equal

	; Compare chars
	mov		dl, byte ptr [rsi]
	cmp		dl, byte ptr [rdi]
	jne		not_equal

	inc		rsi
	inc		rdi
	jmp		loop_label

not_equal:
	mov		rax, 0
	jmp		finished

equal:
	mov		rax, -1

finished:
	ret
StrEquals endp
