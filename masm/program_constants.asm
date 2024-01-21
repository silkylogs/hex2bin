; Application specific constants

; Operation status enum
STATUS_UNKNOWN_ERROR	equ 00h
STATUS_ONGOING		equ 01h
STATUS_EXITED_NORMALLY	equ 02h	
STATUS_INVALID_CHAR	equ 03h
STATUS_OUTPUT_NO_MEMORY	equ 04h

; Common character definitions
CHAR_TAB		equ 09h
CHAR_SPACE		equ 20h
CHAR_CR			equ 0dh
CHAR_NL			equ 0ah
CHAR_BRACKET_SQ_L	equ 5bh
CHAR_BRACKET_SQ_R	equ 5dh
CHAR_COMMA		equ 2ch

CHAR_ZERO		equ 30h
CHAR_ONE		equ 31h
CHAR_TWO		equ 32h
CHAR_THREE		equ 33h
CHAR_FOUR		equ 34h
CHAR_FIVE		equ 35h
CHAR_SIX		equ 36h
CHAR_SEVEN		equ 37h
CHAR_EIGHT		equ 38h
CHAR_NINE		equ 39h

; Idk
MULTILINE_CMT_START	equ 2f2ah ; /*
MULTILINE_CMT_END	equ 2a2fh ; */
SINGLELINE_CMT_START	equ 2f2fh ; //
SINGLELINE_CMT_END	equ 0a0dh ; \n
