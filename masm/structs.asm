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
	input_text_start	qword	0
	input_text_size		qword	0
	input_text_end		qword	0

	output_text_start	qword	0
	output_text_size	qword	0
	output_text_end		qword	0
initialized_once_state_t ends
init_consts initialized_once_state_t <>

global_const_state_t struct
program_logo	byte 'Hex2Bin MASM edition v0.1.0 for Windows x64', 0dh, 0ah,
		     'Console printing functionality ok', 0dh, 0ah, 0h
			
string		byte 'Comparing strings:', 0dh, 0ah, 0h
str1		byte 'Hello, world!', 0dh, 0ah, 0h
str2		byte 'Hello, world!', 0dh, 0ah, 0h

multiline_cmt_start  	     byte '/*', 0
multiline_cmt_start_size     qword 2
multiline_cmt_end    	     byte '*/', 0
multiline_cmt_end_size	     qword 2

singleline_cmt_start	     byte '//', 0
singleline_cmt_start_size    qword 2
singleline_cmt_end	     byte 00ah, 0
singleline_cmt_end_size	     qword 2
global_const_state_t ends
consts global_const_state_t <>

; var_state: struct {
;	iptr: mut char* = input_text
;	optr: mut char* = output_text
;	operation_status: u64 enum = ongoing
;	comment_nest_level = 0,
; }
var_state_t struct
	in_ptr			qword	0
	out_ptr			qword	0
	operation_status	qword	0
	comment_nest_level	qword	0
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
