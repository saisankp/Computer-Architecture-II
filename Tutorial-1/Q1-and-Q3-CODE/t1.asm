.686 ; Identifies this as a 32-bit assembly.
.model flat, C ; Defines the memory model and calling convention.

; Assembly programs are divided into two sections, data and code.

.data

.code
public poly					; This makes the procedure/function visible to the C++ file.
poly: 
	; Prologue
	push ebp ; Pushing the base pointer onto the stack.
	mov ebp, esp ; Establishing the stack frame.

	; Now, we can focus on the main function body.
	; Remember, this function in C is represented as poly(int arg)
	
	; As the Callee, we must preserve the EBX register if we want to use it (we will later on!).
	push ebx

	mov ecx, [ebp+8]		; ECX = arg
	mov eax, ecx			; EAX = arg

	; As we are the caller to pow(arg, 2), we must save ECX as we will use it later.
	push ecx

	; We can use EBX to represent the variable pow2, which is the result of the function call pow(arg, 2).
	; Remember, we are now a Caller to pow(arg, 2), hence we must push arguments (right-to-left) onto the stack.
	push 2					; Push 2 to the stack. This will be the right parameter.
	push eax				; Push EAX (i.e. arg) onto the stack. This will be the left parameter.
	call pow				; Call the function power
	
	; As we were the caller to pow(arg, 2), we can pop ecx off the stack to get back it's previous value before the function call to pow(arg, 2).
	pop ecx

	add esp, 8				; Pop parameters from stack
	mov ebx, eax			; EBX = result of pow(arg, 2)

	mov eax, ecx			; EAX = arg (we reset EAX = arg because it EAX was overwritten after the first function call for pow(arg,2))
	
	; As we are the caller to pow(arg, 3), we must save ECX as we will use it later.
	push ecx

	; We can use EDX to represent the variable pow3, which is the result of the function call pow(arg, 3).
	; Remember, we are now a Caller to pow(arg, 3), hence we must push arguments (right-to-left) onto the stack.
	push 3					; Push 2 to the stack. This will be the right parameter.
	push eax				; Push EAX (i.e. arg) onto the stack. This will be the left parameter.
	call pow				; Call the function power

	; As we were the caller to pow(arg, 3), we can pop ecx off the stack to get back it's previous value before the function call to pow(arg, 3).
	pop ecx
	add esp, 8				; Pop parameters from stack
	mov edx, eax			; EDX = result of pow(arg, 3)

	; So now, we can say that:
	; ECX = arg
	; EBX = result of pow(arg,2)
	; EDX =  result of pow(arg,3)
	
	; Now we can clear EAX, which will soon contain the final result we will return (res).
	xor eax, eax ; This clears the register quicker than mov eax, 0

	; res = 0
	add eax, ebx			; res += pow(arg,2)
	add eax, edx			; res += pow(arg,3)
	add eax, 1				; res += 1
	add eax, ecx			; res += arg

	; We preserved the EBX register, now we can pop it off the stack as we don't need it anymore
	pop ebx

	; Epilogue
	mov esp, ebp			; Moving the value of the base pointer back to the stack.
	pop ebp					; Popping the base pointer off the stack.
	ret						; return with result in EAX.

; Note: We cannot use public pow on this line and include it in the t1.h file because we would get the error -> 'pow': you cannot overload a function with 'extern "C"' linkage. 
; This does not matter, as we could simply change it's name to power for example, and add public power and include it in the t1.h file. But this is unecessary as pow is just serves as a private helper function.
pow:
	; Prologue
	push ebp ; Pushing the base pointer onto the stack.
	mov ebp, esp ; Establishing the stack frame.

	; Now, we can focus on the main function body.
	; Remember, this function in C is represented as pow(int arg0, int arg1)
	
	; As the Callee, we must preserve the ESI register if we want to use it (we will later on!).
	push esi

	mov ecx, [ebp+12]		; ECX = arg1
	mov esi, [ebp+8]		; ESI = arg0 
	mov eax, 1				; result = 1

L1:	mul esi					; eax = eax * esi (i.e. result = result * arg0)
	dec ecx					; arg1 -= 1
	jnz L1					; Jump to L1 as long as the zero flag is clear (i.e. ECX [arg1] is not zero).
	
	; We preserved the ESI register, now we can pop it off the stack as we don't need it anymore
	pop esi

	; Epilogue
	mov esp, ebp			; Moving the value of the base pointer back to the stack.
	pop ebp					; Popping the base pointer off the stack.
	ret						; return with result in EAX.

public multiple_k			; This makes the procedure/function visible to the C++ file.
multiple_k:
	; Prologue
	push ebp ; Pushing the base pointer onto the stack.
	mov ebp, esp ; Establishing the stack frame.

	; Now, we can focus on the main function body.
	; Remember, this function in C is represented as multiple_k(uint16_t, uint16_t, uint16_t, uint16_t*)
	
	; As the Callee, we must preserve the EBX, EDI and ESI registers if we want to use them (we will later on!).
	push ebx
	push edi
	push esi

	mov edx, [ebp+20]		; EDX = array pointer (32 bits)
	mov bx, [ebp+16]		; BX = K (16 bits)
	mov cx, [ebp+12]		; CX = N (16 bits)
	mov si, [ebp+8]			; SI = M (16 bits)

	mov di, si				; i = M;
	; Now we can clear EAX with xor -> this clears the register quicker than mov eax, 0
	xor eax, eax 
	mov ax, di				; AX = M
	; Now we make the address of current array index balance out with where I starts
	mov si, 2				; SI = 2
	push edx				; Push edx to save it, as it is overwritten by the mul instruction!
	mul si					; eax = eax * esi
	pop edx					; Pop edx to get back edx's original value after the mul instruction changed it!
	add edx, eax			; Add the offset to the original address of the start of the array to get a particular index's address.
	mov si, dx				; SI = address of index M in the array.

L2:	
	
	push edx				; Push EDX as we will overwrite it soon, we want it later!
	push ecx				; Push ECX as we will overwrite it soon, we want it later!

	;Now we can complete the modulo operation using CWD and IDIV
	mov cx, bx				; CX = The 2nd argument after the modulo (%)
	mov ax, di				; AX = The 1st argument before the modulo (%)
	cwd						; This copies the sign (bit 15) of the value in the AX register into every bit position in the DX register.
	idiv cx					; Use idiv to get the modulo of ax and cx
	mov ax, dx				; EAX will have i % K now.

	pop ecx					; Restore EDX
	pop edx					; Restore ECX

	cmp eax, 0				; if(i%K == 0)
	jnz nonZero				
zero:
	mov eax, 1				; EAX = 1
	mov [edx], eax			; array[i] = EAX (i.e. 1)
	jmp done				; Finished this iteration of the loop.
nonZero:
	mov	eax, 0				; EAX = 0
	mov [edx], eax			; array[i] = EAX (i.e. 0)
done: 
	; Now we need to increment the address of the array pointer to the next index!
	add edx, 2				; Increment the address by 2 bytes to go to the next index
	add di, 1				; Increment the counter
	cmp di, cx				; if(i < N)
	jnz L2					; Continue looping.
	mov eax, edx			; Move the result to EAX before finishing.
	
	; We preserved the EBX, EDI and ESI registers, now we can pop them off the stack as we don't need them anymore
	pop esi
	pop edi
	pop ebx

	; Epilogue
	mov esp, ebp			; Moving the value of the base pointer back to the stack.
	pop ebp					; Popping the base pointer off the stack.
	ret						; return with result in EAX.

public factorial ; This makes the procedure/function visible to the C++ file.
factorial:
	; Prologue
	push ebp ; Pushing the base pointer onto the stack.
	mov ebp, esp ; Establishing the stack frame.
	
	; As the caller of factorial recursively, we must preserve EDX and ECX if we want to use them again (we will soon!).
	push edx				
	push ecx

	mov edx, [ebp+8]		; EDX = N
	cmp edx,0				; if (N == 0)
    je returnOne			;  return 1
    mov ecx,edx				; else
    sub ecx,1				; ECX = N-1
    push ecx				; Push argument to stack for factorial function call.
    call factorial			; EAX =  factorial(N-1)
    add esp,4				; Pop argument from stack.
    mul edx					; EAX = N * factorial(N-1)
    jmp finish				; Finished
returnOne:
     mov eax,1				; Return 1
finish:

	; We preserved the ECX and EDX registers, now we can pop them off the stack as we don't need them anymore
	pop ecx
	pop edx

	; Epilogue
	mov esp, ebp			; Moving the value of the base pointer back to the stack.
	pop ebp					; Popping the base pointer off the stack.
	ret						; return with result in EAX
end