	;; Needed for initialization:
	extrn __imp_GetCommandLineA:qword
	GetCommandLine textequ <__imp_GetCommandLineA>

	extrn __imp_GetModuleHandleA:qword
	GetModuleHandle textequ <__imp_GetModuleHandleA>

	extrn __imp_GetStartupInfoA:qword
	GetStartupInfo  textequ <__imp_GetStartupInfoA>
	
	
	extrn __imp_GetClassNameA:qword
	GetClassName textequ <__imp_GetClassNameA>
