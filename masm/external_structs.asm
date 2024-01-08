;; Windows structs
WNDCLASSEX struct
	cbSize		dword	?
	dwStyle		dword	?
	lpfnCallback	qword	?
	cbClsExtra	dword	?
	cbWndExtra	dword	?
	hInst		qword	?
	hIcon		qword	?
	hCursor		qword	?
	hbrBackground	qword	?
	lpszMenuName	qword	?
	lpszClassName	qword	?
	hIconSm		qword	?	
WNDCLASSEX ends

STARTUPINFO struct
	; what is cbSize?
	cb		qword	sizeof ( STARTUPINFO )
	lpReserved	qword	?
	lpDesktop	qword	?
	lpTitle		qword	?
	
	dwX		dword	?
	dwY		dword	?
	dwXSize		dword	?
	dwYSize		dword	?
	dwXCountChars	dword	?
	dwYCountChars	dword	?
	dwFillAttribute	dword	?
	dwFlags		dword	?
	wShowWindow	word	?
	
	cbReserved2	word	3 dup ( ? )
	lpReserved2	qword	?
	
	hStdInput	qword	?
	hStdOutput	qword	?
	hStdError	qword	?
STARTUPINFO ends

;; Declarations
startup_info STARTUPINFO <>
