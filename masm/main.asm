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

	;; Needed for WinCall
	local		holder:qword

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
	local		holder:qword

	mov		rax, STD_OUTPUT_HANDLE
	WinCall		GetStdHandle, rax

	lea		r9, printString
	mov		r10, sizeof printString 
	WinCall		WriteConsole, rax, r9, r10, 0, 0
	
	mov		rax, 5
	ret
	WinMain endp

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

; assume(is_valid_ptr(input_text))
; assume(is_valid_ptr(output_text))
; assume(input_text_size >= output_text_size)
; try_extract_valid_chars(input_text, input_text_size,
;                         output_text, output_text_size)
;   input_end_ptr = input_text + sizeof char * input_text_size
;   output_end_ptr = output_text + sizeof char * output_text_size
;   iptr = input_text
;   optr = output_text
;
;   // insert other state here
;
;   loop
;      should_break = try_extract_valid_chars_single_step(state, iptr, optr)
;
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

	end
