	STARTUPINFO struct
	;; cbSize??
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

	startup_info STARTUPINFO <>

	wcl		label	WNDCLASSEX
	dword		sizeof ( WNDCLASSEX ) ; cbSize
	dword		classStyle	      ; dwStyle
	qword		mainCallback	      ; lpfnCallback
	dword		0		      ; cbClsExtra
	dword		0		      ; cbWndExtra
	qword		?		      ; hInst
	qword		?		      ; hIcon
	qword		?		      ; hCursor
	qword		?		      ; hbrBackground
	qword		mainName	      ; lpszMenuName
	qword		mainClass	      ; lpszClassName
	qword		?		      ; hIconSm
	
	
	
	
