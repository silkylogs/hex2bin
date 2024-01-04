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
	;include strings.asm
	include structs.asm
	include variables.asm

	;; Executable code
	.code
	printString	byte	'Hello, world!', 0dh, 0ah, 0h 

	;; Program main execution point
	align	qword
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
	local		printStringPtr:qword

	lea		rcx, printString
	mov		printStringPtr, rcx

	mov		rax, 0FFFFFFFFFFFFFFF5h
	WinCall		GetStdHandle, rax
	WinCall		WriteConsole, rax, printStringPtr, 16, 0, 0
	
	mov		rax, 5
	ret
	WinMain endp

	end
