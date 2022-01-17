includelib legacy_stdio_definitions.lib
extrn printf:near
extrn scanf:near

.data
starting_sentence BYTE "Please enter an integer: ", 00h
scanf_format BYTE "%lld", 00h
final_sentence BYTE "The sum of the maximum value and user input (%lld, %lld) : %lld", 0Ah, 00h
public inp_int
inp_int QWORD 4
maxValue QWORD 4
sum QWORD 4

.code
; Parameters: RCX = a, RDX = b
public      gcd_recursion           ; This makes the procedure/function visible to the C++ file.
gcd_recursion:
            test    rdx, rdx        ; if (b == 0)
            jne     recursion       ; if b is not equal to 0, we must use recursion.
            mov     rax, rcx        ; return a if b is equal to 0 though -> remember RAX holds the return value.
            jmp     finish          ; return the new value in RAX.     
recursion:  ; If we have got here, we must use recursion while allocating shadow space appropriately.
            mov     rax, rcx        ; RAX = a
            mov     rcx, rdx        ; RCX = b
            cqo                     ; This allows us to extend a.
            idiv    rcx             ; rdx = a % b
            sub rsp, 32				; max(32, 8x2) = 32 bytes for allocating shadow space.
            call    gcd_recursion   ; gcd_recursion(b, a%b) -> a non-leaf function with arbitrary arguments.
            add rsp, 32				; max(32, 8x2) = 32 bytes for deallocating shadow space.
finish:     ret                     ; return 


public      use_scanf               ; This makes the procedure/function visible to the C++ file.
; Parameters: RCX = array size, RDX = address of array
use_scanf:
            ; RAX will hold the temporary values as we iterate through the array (register used for accessing arguments in loops).
			xor rax, rax
            ; R8 will hold the maximum value in the array temporarily before it is stored into memory to avoid using more registers.
            ; This design choice also has the benefit of allowing us to use r8 later on (we will!) and having the max value in memory for later use.
            xor r8, r8
			;Main loop
L1:			mov rax, [rdx]          ; RAX = value at current index in array.
            cmp r8, rax             ; compare maxValue and array[i].
            jg noChange             ; if maxValue > array[i], no change to maxValue needed.
            mov r8, rax             ; if maxValue < array[i], then maxValue = array[i] to update new maxValue.
noChange:
			add rdx, TYPE QWORD     ; Move to the next element in the array (i.e. i++).
			loop L1                 ; Ensuring we use the LOOP instruction using RCX as the loop counter and not reimplementing it.
            ; Once we reached here, we have successfully stored the final maxValue into r8. Lets store it into memory now.
            mov [maxValue], r8
            ;Now r8 is free for use, and we don't need to for example use r10 later on.
            sub rsp, 32                 ; Allocate stack space for future function calls below.
            ; First, let's call printf.
            lea rcx, starting_sentence  ; RCX = address of the string in memory.
            call printf                 ; printf is called, with the argument RCX holding the string to be printed.
            ; Now let's call scanf.
            lea rcx, scanf_format       ; RCX = address of format "%lld"
            lea rdx, inp_int            ; RDX = address of where the user input should be stored (i.e. at inp_int which is public).
            call scanf                  ; scanf is called, with the argument RCX holding the format, and RDX holding where the result should be stored.
            ; Now the input inp_int (long long/64 bit integer) is stored at address of inp_int.
            ; Let's set up RCX, RDX, R8, and R9 which will be the String output, max value, inp_int, and sum respectively for the last printf call.
            lea rcx, final_sentence     ; RCX = string output
            mov rdx, [maxValue]         ; RDX = maxValue
            mov r8, [inp_int]           ; R8 = User's input
            xor r9, r9                  ; Clear R9 incase it is not 0.
            ; Sum = maxValue + inp_int, so let's add those two to r9.
            mov r9, rdx                 
            add r9, [inp_int] 
            ; Now we can store the sum into memory, this is for 2 reasons:
            ; 1. R9 will be overwritten regardless after the printf call, and we still need the sum value to return it.
            ; 2. By storing it in memory we don't have to use registers such as RBX or RBP which are callee preserved registers.
            mov [sum], r9
            call printf
            mov rax, [sum]              ; RAX = sum (return sum)
            add rsp, 32                 ; Deallocate stack space for previous function calls.
            ret

; Parameters: RCX = a, RDX = b, R8 = c
public      min						    ; This makes the procedure/function visible to the C++ file.
            ; By making RAX = v, we can simply return at the end of the function since V will be returned (less registers used) without an extra mov instruction.
min:        mov     rax, rcx	        ; V (RAX) = A (RCX)
            cmp     rax, rdx	        ; Compare b and v.
            jl      vLessB              ; if (b < v)
            mov     rax, rdx		    ; v = b
vLessB:     cmp     rax, r8		        ; Compare c and v.
            jl      vLessC              ; if (c < v)
            mov     rax, r8		        ; v = c
vLessC:		ret   


; Parameters: RCX = i, RDX = j, R8 = k, R9 = l
public      min5			; This makes the procedure/function visible to the C++ file.
min5:
    ; Push k and l to the stack, as we will need them later on, this saves us using extra registers!
	push r8					;	Push k to the stack
	push r9					;	Push l to the stack
    ; Now we can use R8
	mov r8, inp_int			;   R8 = inp_int
	sub rsp, 32				;	Allocate shadow space.
    ; Now RCX = i, RDX = j, R8 = inp_int, so we can get the minimum of those 3 (the ordering of the parameters does not matter).
	call min				;	RAX = min(g, i, j)
	add rsp, 32				;	Deallocate shadow space.
	mov rcx, rax			;	RCX = previousMinimum
	pop r8					;	Pop off l from the stack
	pop rdx					;	Pop off k from the stack
	sub rsp, 32				;	Allocate shadow space.
    ; Now RCX = previousMinimum, RDX = k, R8 = l, so we can get the minimum of those 3 (the ordering of the parameters does not matter).
	call min				;	RAX = min(previousMinimum, l, k)
	add rsp, 32				;	Deallocate shadow space.
	ret
end