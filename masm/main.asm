;;; Emacs likes to get funky with .asm files
;;; `;` is bound to asm-comment in assembly mode. You can either do a quoted insert with C-q ; on a case-by-case basis, or remove the binding and just use M-; (comment-dwim) for fancier commenting. If you want to do the latter, set ";" locally to do a self-insert command:
;;; (defun my-hook ()
;;; (local-set-key ";" 'self-insert-command))
;;; (add-hook 'asm-mode-hook 'my-hook)
;;; If all else fails, when in your nasm buffer, hit M-: to call eval-expression and enter
;;; (local-set-key ";" 'self-insert-command).

;; Constant data	
include program_constants.asm
include external_includes.asm
include macros.asm
include external_structs.asm 
include windows_constants.asm

;; Variable data	
.data
include strings.asm
include structs.asm
include variables.asm

;; Executable code
.code

;; Program main execution point
align qword
Startup proc
	local		holder: qword

	;; hInstance = GetModuleHandle(NULL);
	xor		rcx, rcx
	WinCall		GetModuleHandle, rcx
	mov		hInstance, rax

	;; lpCmdLine = GetCommandLine();
	WinCall		GetCommandLine
	mov		lpCmdLine, rax

	;; GetStartupInfo(&startup_info);
	;; ax = startup_info.wShowWindow;
	lea		rcx, startup_info
	WinCall		GetStartupInfo, rcx
	xor		rax, rax
	mov		ax, startup_info.wShowWindow

	;; return WinMain(
	;;	hInstance, hPrevInstance,
	;;	lpCmdLine, nCmdShow);
	mov		r9, rax
	mov		r8, lpCmdLine
	xor		rdx, rax
	mov		rcx, hInstance
	call		WinMain
	ret
Startup endp

WinMain proc
	local		x: qword

	lea		r8, program_logo
	mov		r9, sizeof program_logo	
	call		PrintStr

	lea		r8, string
	mov		r9, sizeof string
	call		PrintStr

	lea		r8, str1
	mov		r9, sizeof str1
	call		PrintStr

	lea		r8, str2
	mov		r9, sizeof str2
	call		PrintStr

	lea		rsi, str1
	lea		rdi, str2
	mov		rcx, sizeof str2
	call		StrEquals

	;mov		rax, 0
	ret
WinMain endp

;; rax: bool PrintStr(string: r8 char*, len: r9 u64)
PrintStr proc
	local		holder: qword

	; return WriteConsole(
	;	GetStdHandle(STD_OUTPUT_HANDLE),
	;	string, len, nullptr, nullptr);
	mov		rax, STD_OUTPUT_HANDLE
	WinCall		GetStdHandle, rax
	WinCall	WriteConsole, rax, r8, r9, 0, 0
	
	mov		rax, 0
	ret	
PrintStr endp

; rcx = len of both strings
; rsi = str1
; rdi = str2
; TODO: make this work properly
StrEquals proc
	; Compare bytes till not equal
still_comparing:
	dec		rcx
	jrcxz		equal		; If rcx = 0, string matches
	cmp	  	ptr [rsi], ptr [rdi]
	inc		rsi
	inc		rdi
	je		still_comparing
	jne		not_equal
equal:
	mov		rax, 1
	ret
not_equal:
	mov		rax, 0
	ret
StrEquals endp

end


; assume(is_valid_ptr(input_text))
; assume(is_valid_ptr(output_text))
; assume(input_text_size >= output_text_size)
; try_extract_valid_chars(
;	 input_text: rcx mut char*, input_text_size: rcx mut char*,
;	 output_text: r8 mut char*, output_text_size: r9 mut char*,
; ) {
;    const_state: struct {
;    	 input_text_start = input_text,
;	 input_text_size  = input_text_size,
;	 input_text_end   = input_text + sizeof char * input_text_size,
;
;   	 output_text_start = output_text,
;	 output_text_size  = output_text_size,
;	 output_text_end   = output_text + sizeof char * output_text_size,
;    }
;
;    var_state: struct {
;        iptr: mut char* = input_text
;        optr: mut char* = output_text
;	 operation_status: u64 = false
;    }
;
;    loop {
;      	  try_extract_valid_chars_single_step(&state, &mut var_state)
;      	  if state.should_break break
;    }

; // Ignore multi line comment
; - Go through the bytes of input
;   - On multi line comment detection, employ nested semantics
;   - On single line comment detection, employ non-nested semantics
;   - Otherwise
;     - If character is whitespace or newline or tab, ignore
;     - If character is valid hex character, copy to output
;     - Else report offending
;       - byte, char representaion, location
;       - Set failure byte
; - If not failed, write bytes to output


; // Overall program operation
; // It is implied that after every line there is some mechanism
; // that reports errors, if any
; tokenized_cmdline = try_tokenize_cmdline_input(lpCmdLine)
;
; validate_one_or_more_input_filenames(tokenized_cmdline)
; input_filenames = try_extract_input_filenames(tokenized_cmdline)
;
; validate_only_one_output_filename(tokenized_cmdline)
; output_filename = try_extract_first_output_filename(tokenized_cmdline)
;
; master_input_text = malloc()
; for filename in input_filenames
;     file_handle = try_open_file(filename)
;     file_text = try_getting_text(file_handle)
;     try_concatenate_file_contents(file_text to master_input_text)
;
; output_memory_buffer = try_extract_valid_chars(master_input_text_file)
; output_memory_buffer = convert_to_hex(output_memory_buffer)
;
; output_file_handle = try_open_binary_file(output_filename)
; try_writing_data_to_file(output_file_handle)

