	;; `WinCall parameter_count, param1, ...`
	;; - Registers `rax` and `r10` will be destroyed in the process.
	;; - Every function that invokes this macro must have a local
	;;   variable called "holder" declared as a qword.
	;;   Example: `local holder:qword`
	;; - In place of this macro, the INVOKE directive cannot be used
	;;   as it doesnt compile in 64 bit mode.
	;; The WinCall macro creates 8 bytes of stack space for each
	;; parameter, with a minimum of 32 bytes created regardless of the
	;; number of parameters. The first four parameters are passed in
	;; RCX, RDX, R8 and R9 respectively.
	;; Any parameters beyond the 4th are placed on the stack.
	;; TODO: cleanup
	
	WinCall macro call_dest:req, argnames:vararg
	local		jump_1, lpointer, num_args_passed

	; Get argument count
	num_args_passed = 0
	for argname, <argnames>
		num_args_passed = num_args_passed + 1
	endm

	; Constrain argument count to >= 4
	if num_args_passed lt 4
		num_args_passed = 4
	endif
	
	mov		holder, rsp			; Save entry RSP value
	sub		rsp, num_args_passed * 8	; Back up RSP 1 qword per parameter

	; Clear low 4 bits for para alignment	
	test		rsp, 0Fh
	jz		jump_1
	and		rsp, 0FFFFFFFFFFFFFFF0h
	
jump_1:
	; Initialize shadow area at RSP + 0
	lPointer = 0
	
	for argname, <argnames>
		if lPointer gt 24
			mov	rax, argname		; Move argument into RAX
			mov	[rsp + lPointer], rax	; Shadow next parameter on stack
		elseif lPointer eq 0
			mov	rcx, argname		; Arg 0 = RCX
		elseif lPointer eq 8
			mov	rdx, argname		; Arg 1 = RDX
		elseif lPointer eq 16
			mov	r8, argname		; Arg 2 = R8
		elseif lPointer eq 24
			mov	r9, argname		; Arg 3 = R9
		endif
		lPointer = lPointer + 8			; Advance local pointer by 1 qword
	endm

	call		call_dest			; Execute call to dest function
	mov		rsp, holder			; Restore RSP

	endm
