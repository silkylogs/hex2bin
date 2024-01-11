; Application specific constants

; Operation status enum
STATUS_UNKNOWN_ERROR	equ 00h
STATUS_ONGOING		equ 01h
STATUS_EXITED_NORMALLY	equ 02h	
STATUS_INVALID_CHAR	equ 03h
STATUS_OUTPUT_NO_MEMORY	equ 04h

; Common character definitions
CHAR_TAB		equ <09h>
CHAR_SPACE		equ <20h>
CHAR_CARRIAGE_RETURN	equ <0dh>
CHAR_NEWLINE		equ <0ah>

; Idk
MULTILINE_CMT_START	equ <word 2f2ah> ; /*
MULTILINE_CMT_END	equ <word 2a2fh> ; */
SINGLELINE_CMT_START	equ <word 2f2fh> ; //
SINGLELINE_CMT_END	equ <word 0a0dh> ; \n
