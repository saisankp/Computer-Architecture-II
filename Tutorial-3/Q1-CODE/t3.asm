;Name: Prathamesh Sai
;Student ID: 19314123

;Here is the unoptimized & optimized version of min (unoptimized and optimized are the same, since no more optimizations were available)
add r0, #4, r3            ;inp_int is a global variable, in R3
 
min: 
add r26, r0, r1           ; R1 (v) = R26 (a) + R0 (0)
sub r27, r1, r0 {C}       ; if(b < v) condition with flags set.
jge check1                ; jump instruction & NOP after since
xor r0, r0, r0            ; the instruction right after will be
                          ; executed after the jump is fetched
                          ; but before the jump is executed.
add r27, r0, r1           ; R1 (v) = R27 (b) + R0 (0)
check1: 
sub r28, r1, r0 {C}       ; if(c < v) condition with flags set.
jge check2                ; jump instruction & NOP after since
xor r0, r0, r0            ; the jump instruction takes place
                          ; after the next normal non NOP 
                          ; instruction, by the time we fetch 
                          ; the instruction there where we have
                          ; to jump, the next instruction would
                          ; have already been executed.
add r28, r0, r1           ; R1 (v) = R28 (c) + R0 (0)
check2: 
ret (r31)0                ;R31 is used for the return address
xor r0, r0, r0            ;NOP after ret or callr instruction

;Here is my unoptimized version of min5 (U0 = Un-Optimized)
min5UO:
; Min function call 1:
add r3, r0, r10           ; R10 (param 1) = R3 (inp_int) + R0 (0)
add r26, r0, r11          ; R11 (param 2) = R26 (i) + R0 (0)
add r27, r0, r12          ; R12 (param 3) = R27 (j) + R0 (0)
callr r15, min            ; Return address saved in R15 & call min
xor r0, r0, r0            ; NOP after callr

; Min function call 2:
add r1, r0, r10           ; R10 (param 1) = R1 (call 1 result) + R0 (0)
add r28, r0, r11          ; R11 (param 2) = R28 (k) + R0 (0)
add r29, r0, r12          ; R12 (param 3) = R29 (l) + R0 (0)
callr r15, min            ; Return address saved in R15 & call min
xor r0, r0, r0            ; NOP after callr

; Return with R1 containing the result and address in R31.
ret (r31)0                ; R31 is used for the return address.
xor r0, r0, r0            ; NOP after ret


;Here is my optimized version of min5
min5:
; Min function call 1:
add r3, r0, r10           ; R10 (param 1) = R3 (inp_int) + R0 (0)
add r26, r0, r11          ; R11 (param 2) = R26 (i) + R0 (0)
callr r15, min            ; Return address saved in R15 & call min
add r27, r0, r12          ; R12 (param 3) = R27 (j) + R0 (0)

; Min function call 2:
add r1, r0, r10           ; R10 (param 1) = R1 (call 1 result) + R0 (0)
add r28, r0, r11          ; R11 (param 2) = R28 (k) + R0 (0)
callr r15, min            ; Return address saved in R15 & call min
add r29, r0, r12          ; R12 (param 3) = R29 (l) + R0 (0)

; Return with R1 containing the result and address in R31.
ret (r31)0                ; R31 is used for the return address.
xor r0, r0, r0            ; NOP after ret