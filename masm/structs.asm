;; Program specific structs

; initialized_once_state: struct {
; 	input_text_start = input_text,
; 	input_text_size  = input_text_size,
; 	input_text_end   = input_text + sizeof char * input_text_size,
;
; 	output_text_start = output_text,
; 	output_text_size  = output_text_size,
; 	output_text_end   = output_text + sizeof char * output_text_size,
; }
initialized_once_state_t struct
	input_text		qword	0
	output_text		qword	0
	input_text_size		qword	0
	output_text_size	qword	0
initialized_once_state_t ends
init_consts initialized_once_state_t <>

global_const_state_t struct
program_logo	byte 'Hex2Bin MASM edition v0.1.0 for Windows x64', 0dh, 0ah,
		     'Console printing functionality ok', 0dh, 0ah, 0h

newline_literal		     byte  0dh, 0ah, 0


global_const_state_t ends
consts global_const_state_t <>

error_strings_collection struct
normal byte 'String extraction successful', 0
unknown byte 'Program has encountered an unspecified error ',
    	     'while extracting valid characters', 0
invalid_char byte 'Program has detected an invalid character in input: ', 0
no_memory byte 'Program has run out of memory to write filtered characters', 0
impossible_status byte 'Program has reached an impossible state ',
    	     	       'while extracting valid characters', 0
unterminated_multiline_cmnt byte 'Unterminated multi line comment detected', 0
error_strings_collection ends
estrs error_strings_collection <>

var_state_t struct
	source_string byte '0123456789',
			   'abcdefghijklmnopqrstuvwxyz',
			   'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 0
				     
	;source_string byte 'abc de f', CHAR_TAB,
	;	      	   'A BC DEF', CHAR_TAB,
	;		   '01 23 45 67 89', CHAR_TAB,
	;		   '/* This is a comment */', CHAR_TAB,
	;		   '/* This is a /* nested */ comment */', 0dh, 0ah,
	;		   '/* This comment is unterminated', 0
	dest_string		byte 040h dup ( 025h )
	operation_status	qword 0
	comment_nest_level	qword 0
var_state_t ends

vars var_state_t <>

;wcl		label	WNDCLASSEX
;dword		sizeof ( WNDCLASSEX ) ; cbSize
;dword		classStyle	      ; dwStyle
;qword		mainCallback	      ; lpfnCallback
;dword		0		      ; cbClsExtra
;dword		0		      ; cbWndExtra
;qword		?		      ; hInst
;qword		?		      ; hIcon
;qword		?		      ; hCursor
;qword		?		      ; hbrBackground
;qword		mainName	      ; lpszMenuName
;qword		mainClass	      ; lpszClassName
;qword		?		      ; hIconSm
