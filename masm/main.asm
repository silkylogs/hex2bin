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
include printing.asm

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
Winmain proc
	lea		r8, consts.program_logo
	mov		r9, sizeof consts.program_logo
	call		PrintStr

	; Print input
	lea		r8, vars.source_string
	mov		r9, sizeof vars.source_string
	call		PrintLineSized

	;lea		rsi, vars.source_string
	;mov		rcx, sizeof vars.source_string
	;lea		rdi, vars.dest_string
	;mov		rdx, sizeof vars.dest_string
	;call		TryExtractValidChars
	
	; call		TryExtractSingleLineComments
	; call		TryExtractMultiLineComments
	; call		RemoveWhiteSpace
	; call		TryExtractHexChars
	; call		ConvertHexCharsToBytes

	lea		rsi, vars.source_string
	mov		rcx, sizeof vars.source_string
	call		PrintByteArrayHex
	call		PrintNewLine

	; Print output
	lea		r8, vars.dest_string
	mov		r9, sizeof vars.dest_string
	call		PrintLineSized

	mov		rax, 0
	ret
WinMain endp

;; bool StrEquals(str1: rsi char*, str2: rdi char *, len: rcx u64)
align qword
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


;-- Dead code ----------------------------------------------------

; assume is_valid_ptr(input_text)
; assume is_valid_ptr(output_text)
; assume input_text_size >= output_text_size
; void TryExtractValidChars(
;	input_text:  rsi mut char*, input_text_size:  rcx mut char*,
;	output_text: rdi mut char*, output_text_size: rdx mut char*)
;TryExtractValidChars proc
;	mov		init_consts.input_text, rsi
;	mov		init_consts.output_text, rdi
;	mov		init_consts.input_text_size, rcx
;	mov		init_consts.output_text_size, rdx
;
;	mov		vars.operation_status, STATUS_ONGOING
;loop_label:
;	call		TryExtractValidCharsSingleStep
;	cmp	     	vars.operation_status, STATUS_ONGOING
;	je	     	loop_label
;
;	call	     	ReportCharExtractionErrors
;
;	ret
;TryExtractValidChars endp
;
;; bool ReportCharExtractionErrors(rsi, operation_status)
;ReportCharExtractionErrors proc
;	cmp		vars.operation_status, STATUS_EXITED_NORMALLY
;	je		print_normal
;
;	cmp		vars.operation_status, STATUS_UNKNOWN_ERROR
;	je		print_unknown_error
;
;	cmp		vars.operation_status, STATUS_INVALID_CHAR
;	je		print_invalid_char
;
;	cmp		vars.operation_status, STATUS_OUTPUT_NO_MEMORY
;	je		print_no_memory
;
;	cmp		vars.operation_status, STATUS_ONGOING
;	je		print_impossible_status
;
;print_normal:
;	lea		r8, estrs.normal
;	mov		r9, sizeof estrs.normal
;	call		PrintLn
;	jmp		retlabel
;
;print_unknown_error:
;	lea		r8, estrs.unknown
;	mov		r9, sizeof estrs.unknown
;	call		PrintLn
;	jmp		retlabel
;
;print_invalid_char:
;	lea		r8, estrs.invalid_char
;	mov		r9, sizeof estrs.invalid_char
;	call		PrintStr
;	call		PrintInputCursorDetails
;
;	jmp		retlabel
;
;print_no_memory:
;	lea		r8, estrs.no_memory
;	mov		r9, sizeof estrs.no_memory
;	call		PrintLn
;	jmp		retlabel
;
;print_impossible_status:
;	lea		r8, estrs.impossible_status
;	mov		r9, sizeof estrs.impossible_status
;	call		PrintLn
;	jmp		retlabel
;
;retlabel:
;	ret
;ReportCharExtractionErrors endp
;
;; Prints what rsi is pointing at
;; TODO: print location information (line and column number)
;PrintInputCursorDetails proc
;	local		rsi_char: byte
;
;	mov		al, byte ptr [rsi]
;	mov	     	rsi_char, al
;	lea		r8, rsi_char
;	mov		r9, sizeof rsi_char
;	call		PrintlnSized
;
;	nop
;	ret
;PrintInputCursorDetails endp
;
;; This exists to coerce emacs into indenting properly
;FunctionThatDoesNothing proc
;	mov	     	rax, rax
;	nop
;	ret
;FunctionThatDoesNothing endp
;
;; void TryExtractValidCharsSingleStep(rsi, rcx, rdi, rdx)
;TryExtractValidCharsSingleStep proc
;	;; Check wether we need to leave
;	cmp	     	rcx, 0
;	je	     	exit_normal
;	cmp	     	rdx, 0
;	je	     	exit_no_memory
;
;	;; Filter characters
;	; Char is null terminator
;	cmp	     byte ptr [rsi], 0
;	je	     exit_normal
;
;	; Char is whitespace (space or tab)
;	cmp	     byte ptr [rsi], CHAR_TAB
;	je	     ignore_this_char
;	cmp	     byte ptr [rsi], CHAR_SPACE
;	je	     ignore_this_char
;
;	; Char is start of multi line comment
;	call	     DetectSkipMultiLineComment
;
;	; Char is start of single line comment
;	call	     DetectSkipSingleLineComment
;
;	; Char is newline character (\r or \n)
;	cmp	     byte ptr [rsi], CHAR_CR
;	je	     ignore_this_char
;	cmp	     byte ptr [rsi], CHAR_NL
;	je	     ignore_this_char
;
;	; Char is valid hexadecimal character (0-9, a-f, A-F)
;	call	     IsValidHexChar
;	cmp	     rax, 0
;	jne	     add_this_char
;
;	; Invalid character
;	jmp	     exit_invalid_char
;
;ignore_this_char:
;	inc	     rsi
;	dec	     rcx
;	jmp	     continue_loop
;
;add_this_char:
;	mov	     al, byte ptr [rsi]
;	mov	     byte ptr[rdi], al
;
;	inc	     rsi
;	inc	     rdi
;
;	dec	     rcx
;	dec	     rdx
;	jmp	     continue_loop
;
;
;	;; Loop exit handling
;exit_invalid_char:
;	mov	     vars.operation_status, STATUS_INVALID_CHAR
;	jmp	     return_from_func
;exit_normal:
;	mov	     vars.operation_status, STATUS_EXITED_NORMALLY
;	jmp	     return_from_func
;exit_no_memory:
;	mov	     vars.operation_status, STATUS_OUTPUT_NO_MEMORY
;	jmp	     return_from_func
;
;continue_loop:
;	mov	     vars.operation_status, STATUS_ONGOING
;return_from_func:
;	ret
;TryExtractValidCharsSingleStep endp
;
;; bool IsValidHexChar(rsi: char*)
;; Note: -- 0 .. 9 -- A .. F -- a .. f --
;; Dashes are invalid ranges
;IsValidHexChar proc
;	local	     zero_nine: byte
;	local	     upper_af: byte
;	local	     lower_af: byte
;
;is_zero_through_nine:
;	cmp	     byte ptr [rsi], '0'
;	setae	     zero_nine
;	cmp	     byte ptr [rsi], '9'
;	setbe	     al
;	and	     zero_nine, al
;
;is_upper_a_through_f:
;	cmp	     byte ptr [rsi], 'A'
;	setae	     upper_af
;	cmp	     byte ptr [rsi], 'F'
;	setbe	     al
;	and	     upper_af, al
;
;is_lower_a_through_f:
;	cmp	     byte ptr [rsi], 'a'
;	setae	     lower_af
;	cmp	     byte ptr [rsi], 'f'
;	setbe	     al
;	and	     lower_af, al
;
;	or	     al, zero_nine
;	or	     al, upper_af
;	or	     al, lower_af
;	ret
;IsValidHexChar endp
;
;; Detects a multi-line comment, and upon success,
;; moves rsi until the end comment (nested)
;
;;;void DetectSkipMultiLineCmt(char *&src, uint64_t &size){
;;;    uint64_t cmt_nest_lvl = 0;
;;;
;;;    if (size == 1) return;
;;;    if (*(uint16_t*)src == *(uint16_t*)"/*") {
;;;        cmt_nest_lvl++;
;;;        src += 2; size -= 2;
;;;    } else return;
;;;
;;;    while (true) {
;;; 	if (cmt_nest_lvl == 0 || size == 0) break;
;;;
;;;	if (size == 1) return;
;;;	if (*(uint16_t*)src == *(uint16_t*)"/*") {
;;;	    cmt_nest_lvl++;
;;;	    src += 2; size -= 2;
;;;	    continue;
;;;	}
;;;	if (*(uint16_t*)src == *(uint16_t*)"*/") {
;;	    cmt_nest_lvl--;
;;	    src += 2; size -= 2;
;;	    continue;
;;	}
;;	src++; size--;
;;	}
;;   if (cmt_nest_lvl != 0) printf("Error: unterminated comment\n");
;; }
;; Note: this proc is a mess
;DetectSkipMultiLineComment proc
;	local		cmt_nest_level: qword
;	mov		cmt_nest_level, 0
;
;	;; To prevent potentially reading from out of bounds memory
;	;; as each delimiter of multi line comments are two bytes long,
;	;; exit when rsi points to the last character
;	cmp		rcx, 1
;	je		func_return
;
;	cmp		word ptr [rsi], MULTILINE_CMT_START
;	jne		func_return
;	inc		cmt_nest_level
;	add		rsi, 2
;	sub		rcx, 2
;
;loop_start:
;	cmp		rcx, 0
;	je		loop_exit
;	cmp		cmt_nest_level, 0
;	je		print_unterminated_multiline_cmnt_and_exit
;	cmp		rcx, 1
;	je		func_return
;
;check_multiline_cmt_start:
;	cmp		word ptr [rsi], MULTILINE_CMT_START
;	jne		check_multiline_cmt_end
;	inc		cmt_nest_level
;	add		rsi, 2
;	sub		rcx, 2
;	jmp		loop_start
;
;check_multiline_cmt_end:
;	cmp		word ptr [rsi], MULTILINE_CMT_END
;	jne		skip_this_char
;	dec		cmt_nest_level
;	add		rsi, 2
;	sub		rcx, 2
;	jmp		loop_start
;
;skip_this_char:
;next_char:
;	inc		rsi
;	dec		rax
;	jmp		loop_start
;
;loop_exit:
;print_unterminated_multiline_cmnt_and_exit:
;	lea		r8, byte ptr estrs.unterminated_multiline_cmnt
;	mov		r9, sizeof estrs.unterminated_multiline_cmnt
;	call		PrintLn
;func_return:
;	ret
;DetectSkipMultiLineComment endp
;
;;; Detects a singl
;DetectSkipSingleLineComment proc
;	mov		rax, 0
;	ret
;DetectSkipSingleLineComment endp
;
;; // Overall program operation
;; // It is implied that after every line there is some mechanism
;; // that reports errors, if any
;; tokenized_cmdline = try_tokenize_cmdline_input(lpCmdLine)
;;
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
