	;; Needed for initialization:
	extrn __imp_GetCommandLineA:qword
	GetCommandLine textequ <__imp_GetCommandLineA>

	extrn __imp_GetModuleHandleA:qword
	GetModuleHandle textequ <__imp_GetModuleHandleA>

	extrn __imp_GetStartupInfoA:qword
	GetStartupInfo  textequ <__imp_GetStartupInfoA>

	; BOOL WINAPI WriteConsole(
	;  _In_             HANDLE  hConsoleOutput,
	;  _In_       const VOID    *lpBuffer,
	;  _In_             DWORD   nNumberOfCharsToWrite,
	;  _Out_opt_        LPDWORD lpNumberOfCharsWritten,
	;  _Reserved_       LPVOID  lpReserved); // must be null
	extrn __imp_WriteConsoleA:qword
	WriteConsole	textequ <__imp_WriteConsoleA>

	; HANDLE WINAPI GetStdHandle(_In_ DWORD nStdHandle);
	extrn __imp_GetStdHandle:qword
	GetStdHandle	textequ <__imp_GetStdHandle>

	; _Post_equals_last_error_ DWORD GetLastError();
	extrn __imp_GetLastError:qword
	GetLastError	textequ <__imp_GetLastError>
