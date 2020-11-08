; exp series implementation 
; exp(z) = 1+(z^1/1!)+(z^2/2!)+(z^3/3!).....(z^n/n!)

	AREA exp_series, CODE, READONLY
	EXPORT  _exp
	ENTRY

; S0 -> Value of z (z is input provided for which exp is to be calculated)
; S1 -> Value of index n (current number of term) 
; S2 -> The number of terms up to which serie needs to be expanded
; S3 -> stores numeravalue of z 
; S4 -> Holds next term which is to be added to the series in S7
; S6 -> Stores factorial of current index 
; S7 -> Stores total sum of all terms i.e. result
; S8 -> Stores 1 to increament n by 1 in each iteration
  
_exp FUNCTION
	
	;S0 is already loaded with input z before calling this function

	VLDR.F32 S1, =1					; Current term index i.e. value of n

	VLDR.F32 S2, =30				; Maximum number of terms to be considered 

	VMOV.F32 S3, S0					; z is stored to S3, this will be updated on each iteration.

	VLDR.F32 S6, =1					; This register stores factorial of current index i.e. n!

	VLDR.F32 S7, =1                 ; Result, it starts with 1 as first term is 1 and it gets updated on each iteration

	VLDR.F32 S8, =1                 ; Index incremented by 1 which is stored in S7
	
loop
	VDIV.F32 S4, S3, S6			    ; Calculating current term i.e. dividing z^n by n!

	VADD.F32 S7, S7, S4				; Updating result register by adding current term
	
    VADD.F32 S1, S1, S8		        ; Updates n i.e. n=n+1

	VMUL.F32 S3, S3, S0				; Updates numerator (multiplying by 'z')
    
	VMUL.F32 S6, S6, S1				; computing factorial

	VCMP.F32 S1, S2					; Checks stop condition (when n reaches 30)

	VMRS APSR_nzcv, FPSCR			; Transfer FP status register to ARM APSR. This instuction is required for subsequent branch conditional instruction.

	BNE loop						; when exit condition is NOT satisfied

    BX LR

	
	ENDFUNC
	END 