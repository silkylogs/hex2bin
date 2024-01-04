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
	
	WinCall		macro call_dest:req, argnames:vararg 

        local jump_1, lpointer, numArgs       ; Declare local labels
        numArgs = 0                             ; Initialize # arguments passed

        for argname, <argnames>  ; Loop through each argument passed
        	numArgs           = numArgs + 1        ; Increment local # arguments count
        endm                                     ; End of FOR looop

        if numArgs lt 4                          ; If # arguments passed < 4
        numArgs = 4                                       ; Set count to 4
        endif                                               ; End IF

        mov  holder, rsp              ; Save the entry RSP value

        sub  rsp, numArgs * 8         ; Back up RSP 1 qword for each parameter passed

        test rsp, 0Fh                 ;
        jz   jump_1                   ;
        and  rsp, 0FFFFFFFFFFFFFFF0h  ; Clear low 4 bits for para alignment
jump_1:
        lPointer            = 0       ; Initialize shadow area @ RSP + 0

        for        argname, <argnames>  ; Loop through arguments
        if       lPointer gt 24         ; If not on argument 0, 1, 2, 3
        mov    rax, argname             ; Move argument into RAX
        mov    [ rsp + lPointer ], rax  ; Shadow the next parameter on the stack
        elseif   lPointer eq 0          ; If on argument 0
        mov    rcx, argname             ; Argument 0 -> RCX
        elseif   lPointer eq 8          ; If on argument 1
        mov    rdx, argname             ; Argument 1 -> RDX
        elseif   lPointer eq 16         ; If on argument 2
        mov    r8, argname              ; Argument 2 -> R8
        elseif   lPointer eq 24         ; If on argument 3
        mov    r9, argname              ; Argument 3 -> R9
        endif                           ; End IF
        lPointer = lPointer + 8         ; Advance the local pointer by 1 qword
        endm                            ; End FOR looop

        call                call_dest   ; Execute call to destination function
        mov                 rsp, holder ; Reset the entry RSP value

        endm 

	
