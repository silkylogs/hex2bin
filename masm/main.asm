;; Emacs likes to get funky with .asm files, just use master-mode

;; Constant data
include macros.asm
include external_includes.asm
include windows_constants.asm
include program_constants.asm

;; Variable data
.data
include external_structs.asm
include structs.asm
include variables.asm

;; Executable code
.code
include utility.asm

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

align qword
WinMain proc
	lea		r8, consts.program_logo
	mov		r9, sizeof consts.program_logo
	call		PrintStr

	; Print input
	lea		r8, vars.source_string
	mov		r9, sizeof vars.source_string
	call		Println

	lea		rsi, vars.source_string
	mov		rcx, sizeof vars.source_string	
	lea		rdi, vars.dest_string
	mov		rdx, sizeof vars.dest_string
	call		TryExtractValidChars

	; Print output
	lea		r8, vars.dest_string
	mov		r9, sizeof vars.dest_string
	call		Println

	mov		rax, 0
	ret
WinMain endp



; assume is_valid_ptr(input_text)
; assume is_valid_ptr(output_text)
; assume input_text_size >= output_text_size
; void TryExtractValidChars(
;	input_text:  rsi mut char*, input_text_size:  rcx mut char*,
;	output_text: rdi mut char*, output_text_size: rdx mut char*)
TryExtractValidChars proc
	mov	     init_consts.input_text, rsi
	mov	     init_consts.output_text, rdi
	mov	     init_consts.input_text_size, rcx
	mov	     init_consts.output_text_size, rdx

	mov	     vars.operation_status, STATUS_ONGOING
loop_label:
	call	     TryExtractValidCharsSingleStep
	cmp	     vars.operation_status, STATUS_ONGOING
	je	     loop_label

	ret
TryExtractValidChars endp

; void TryExtractValidCharsSingleStep(rsi, rcx, rdi, rdx)
TryExtractValidCharsSingleStep proc
	;; Check wether we need to leave
	cmp	     rcx, 0
	je	     exit_loop
	cmp	     rdx, 0
	je	     exit_loop

	;; Filter characters
	; Char is whitespace (space or tab)
	cmp	     byte ptr [rsi], CHAR_TAB
	je	     ignore_this_char
	cmp	     byte ptr [rsi], CHAR_SPACE
	je	     ignore_this_char

	; Char is newline character (\r or \n)
	cmp	     byte ptr [rsi], CHAR_CARRIAGE_RETURN
	je	     ignore_this_char
	cmp	     byte ptr [rsi], CHAR_NEWLINE
	je	     ignore_this_char

	; Char is valid hexadecimal character (0-9, a-f, A-F)
	call	     IsValidHexChar
	cmp	     rax, 0
	jne	     add_this_char

	; Char is start of multi line comment
	; Char is start of single line comment
	; Invalid character
	mov	     vars.operation_status, STATUS_INVALID_CHAR
	jmp	     return_from_func


ignore_this_char:
	inc	     rsi
	dec	     rcx
	jmp	     return_from_func

add_this_char:
	mov	     rax, [rsi]
	mov	     [rdi], rax
	
	inc	     rsi
	inc	     rdi
	
	dec	     rcx
	dec	     rdx
	jmp	     return_from_func

exit_loop:
	mov	     vars.operation_status, STATUS_EXITED_NORMALLY
	jmp	     return_from_func
continue_loop:
	mov	     vars.operation_status, STATUS_ONGOING
	jmp	     return_from_func
return_from_func:
	ret
TryExtractValidCharsSingleStep endp

IsValidHexChar proc
	mov	     rax, 1
	ret
IsValidHexChar endp

; assume(state != NULL)
; assume(var_state != NULL)
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

end
