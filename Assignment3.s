; Implementation of Logic Gates using Neural Networks in ARM Assembly

	THUMB
	PRESERVE8
	AREA  gates_NN, CODE, READONLY
	IMPORT printMsg4p        ;Imported from printMsg.c
	IMPORT print_header		 ;Imported from printMsg.c
	IMPORT _exp				 ;Imported from exp.s
	EXPORT __main
	ENTRY



;******************************************************************
__main FUNCTION

     BL check_sigmoid
     MOV R11,#0                 ;Initializing from case0					
	 ; As there are total 7 cases of logic gates--> AND,OR,NAND,NOR,XOR,XNOR,NOT
	 ; loop runs 7 times from 0 to 6
loop 
	 MOV R0,R11           ;passing current case number to R0 for subsecuent print_header function in C
	 BL print_header      ;prints header of table
	 BL compute_logic     ;Compute logic is called
 	 ADD R11,#1           ; R11 is incremented by 1 for next case
	 CMP R11,#7			  ; loop break condition
	 BNE loop
	 
stop B stop
 
	 ENDFUNC	

;******************************************************************
		 
compute_logic FUNCTION	
	
	 PUSH {LR}; 
	 CMP R11,#6           ;This is exclusively written for case6 if R11 is 6 
	 MOVEQ R0,#6
	 BLEQ compute_not
	 POPEQ {LR}          ;After computing NOT logic it returns to main function from here	
     BXEQ lr;	
	 
	 ; Below part is common for all other cases from case0 to case5
	
	 MOV R4,#0					;x0 Input 
	 MOV R5,#0					;x1 Input 
	 MOV R6,#0					;x2 Input 
     BL load_fpu_reg 			;This function loads inputs x0,x1,x2 to FP registers
	 BL load_logic              ;Based on R11 value respective logic is loaded
	 BL printMsg4p              ;prints a row in the tables
	 
	 MOV R4,#1					;x0 Input 
	 MOV R5,#0					;x1 Input 
	 MOV R6,#1					;x2 Input 
	 BL load_fpu_reg 			;This function loads inputs x0,x1,x2 to FP registers
	 BL load_logic				;Based on R11 value respective logic is loaded
	 BL printMsg4p;             ;prints a row in the tables
	 
	 MOV R4,#1					;x0 Input 
	 MOV R5,#1					;x1 Input 
	 MOV R6,#0					;x2 Input 
     BL load_fpu_reg 			;This function loads inputs x0,x1,x2 to FP registers
	 BL load_logic              ;Based on R11 value respective logic is loaded
	 BL printMsg4p              ;prints a row in the tables
	 
	 MOV R4,#1					;x0 Input 
	 MOV R5,#1					;x1 Input 
	 MOV R6,#1					;x2 Input 
     BL load_fpu_reg 			;This function loads inputs x0,x1,x2 to FP registers
	 BL load_logic              ;Based on R11 value respective logic is loaded
	 BL printMsg4p              ;prints a row in the tables
	 
	 POP {LR};	
     BX lr;						
	 					
	 ENDFUNC 
	 
;****************************************************************** 	 
load_logic FUNCTION   ;This function mainly implements switch-case
		
		 PUSH {LR} 
	     CMP R11,#0               ;Comparing R11 for each possible case
		 BEQ load_and
		 CMP R11,#1
		 BEQ load_or
		 CMP R11,#2
		 BEQ load_nand
		 CMP R11,#3
		 BEQ load_nor
		 CMP R11,#4
		 BEQ load_xor
		 CMP R11,#5
		 BEQ load_xnor

load_and 
		 BL __and		 
		 POP {LR}	  ;retruns to calling function
		 BX lr
load_or
		 BL __or      	 
		 POP {LR}	 ;retruns to calling function
		 BX lr
		 
load_nand
		 BL __nand	 
		 POP {LR}	 ;retruns to calling function
		 BX lr
		 
load_nor
         BL __nor 
		 POP {LR}	 ;retruns to calling function
		 BX lr
		 
load_xor
		 
		 BL __xor
		 POP {LR}	 ;retruns to calling function
		 BX lr
		  
load_xnor

		 BL __xnor;
		 POP {LR}	 ;retruns to calling function
		 BX lr

	 ENDFUNC	 
;****************************************************************** 

check_sigmoid FUNCTION  ;Checks exp function by computing sigmoid by varying z from -5 to 5 
	 ;Values from S9 is recorded manually and plotted in excel as shown in attached image
	 PUSH {LR}
	 VLDR.F32 S21, = -5.0
	 VLDR.F32 S22, = 1.0
	 VLDR.F32 S23, = 6.0
loop1 
     VNEG.F32 S0, S21				; z --> (-z)
 	 BL _exp						; Compute e^(-z), S0 has (-z)
	 BL _sigmoid
	 VADD.F32 S21, S21, S22         ; adding 1 for next value of z
	 VCMP.F32 S21, S23			    ; Compare NN output with 0.5		
	 VMRS    APSR_nzcv, FPSCR;
	 BNE loop1
	 POP {LR};	
	 BX lr;
	 
	ENDFUNC
;****************************************************************** 	 
_sigmoid FUNCTION ;This function if called from sigmoid_fun to compute sigmoid of z
	 
	 ; Computes sigmoid function with output in S9
	 
	 PUSH {LR}
	 VLDR.F32 S8, =1			
	 VADD.F32 S9, S7, S8			; compute (e^-z)+1
	 VDIV.F32 S9, S8, S9			; S9 has 1/(e^-z)+1
	 POP {LR};	
	 BX lr;
	 
	ENDFUNC
;******************************************************************  

sigmoid_fun FUNCTION     ;This function is called after calculating z value in each gate.
	 PUSH {LR}
	 BL _exp						; Computes e^(-z), S0 has (-z)
	 BL _sigmoid					; Sigmoid function output in S9
	 
	 VLDR.F32 S14, =0.5				
	 VCMP.F32 S9,S14				; Compare output with 0.5		
	 VMRS    APSR_nzcv, FPSCR;
	 MOV R0, R4;                    ; Passign arguments to R0, R1, R2 for printMsg4p function
	 MOV R1, R5;
	 MOV R2, R6;
	 MOVGT	R3, #1					; If output > 0.5, output is 1
	 MOVLT	R3, #0					; If output < 0.5, output is 0
	 POP {LR}
	 BX lr
	 
	 ENDFUNC	 

;******************************************************************  

load_fpu_reg FUNCTION ;It loads FPU registers with inputs x0,x1,x2 
	
	 PUSH {LR};
	 
	 VMOV.F32 S0,R4;			Move x0 to S0 (FP register)
     VCVT.F32.S32 S0,S0; 		Convert TO signed 32-bit
	 VMOV.F32 S1,R5;			Move x1 to S1 (FP register)
     VCVT.F32.S32 S1,S1; 		
	 VMOV.F32 S2,R6;			Move x2 to S2 (FP register)
     VCVT.F32.S32 S2,S2; 		
	 POP {LR};
	 
	 BX lr;
	 ENDFUNC
	
;******************************************************************	
;		AND
__and FUNCTION
	 PUSH {LR};	 
	 VLDR.F32 S4, = -0.1			; w1
	 VLDR.F32 S5, = 0.2				; w2
	 VLDR.F32 S6, = 0.2				; w3
	 VLDR.F32 S7, = -0.2				; Bias
	 
	 VMUL.F32 S0, S0, S4			; x0*w1
	 VMUL.F32 S1, S1, S5			; x1*w2
	 VMUL.F32 S2, S2, S6			; x2*w3
	 VADD.F32 S3, S0, S1			; x0*w1 + x1*w2 
	 VADD.F32 S3, S3, S2			; x0*w1 + x1*w2 + x2*w3 
	 VADD.F32 S3, S3, S7			; x0*w1 + x1*w2 + x2*w3 + Bias
	 
	 VNEG.F32 S3, S3				; x --> (-x)
	 VMOV.F32 S0, S3				;(-x) is stored in S0
	 BL sigmoid_fun                 ;called for sigmoid computation;
	 
	 POP {LR};	
	 BX lr;
	 ENDFUNC

;******************************************************************
;		OR

__or FUNCTION
	 PUSH {LR};	 
	 VLDR.F32 S4,= -0.1				; w1
	 VLDR.F32 S5,= 0.7				; w2
	 VLDR.F32 S6,= 0.7				; w3
	 VLDR.F32 S7,= -0.1				; Bias
	 
	 VMUL.F32 S0,S0,S4				; x0*w1
	 VMUL.F32 S1,S1,S5				; x1*w2
	 VMUL.F32 S2,S2,S6				; x2*w3
	 VADD.F32 S3,S0,S1				; x0*w1 + x1*w2 
	 VADD.F32 S3,S3,S2				; x0*w1 + x1*w2 + x2*w3 
	 VADD.F32 S3,S3,S7				; x0*w1 + x1*w2 + x2*w3 + Bias
	 
	 VNEG.F32 S3, S3
	 VMOV.F32 S0, S3				; S0 has the value of x
	 BL sigmoid_fun                 ;called for sigmoid computation;
	 POP {LR};	
	 BX lr;
	 ENDFUNC
	 
;******************************************************************
;		XOR

__xor FUNCTION
	
	 PUSH {LR}
	 VLDR.F32 S4,= -0.2				; w1
	 VLDR.F32 S5,= -0.8				; w2
	 VLDR.F32 S6,= -0.8				; w3
	 VLDR.F32 S7,= 0.9				; Bias
	                            
	 VMUL.F32 S0, S0, S4			; x0*w1
	 VMUL.F32 S1, S1, S5			; x1*w2
	 VMUL.F32 S2, S2, S6			; x2*w3
	 VADD.F32 S3, S0, S1			; x0*w1 + x1*w2 
	 VADD.F32 S3, S3, S2			; x0*w1 + x1*w2 + x2*w3 
	 VADD.F32 S3, S3, S7			; z = x0*w1 + x1*w2 + x2*w3 + Bias
	                            
	 VNEG.F32 S3, S3                ; z changes to (-z) for sigmoid computation
	 VMOV.F32 S0, S3;		        ;(-z) is stored in S0
	 
	 BL sigmoid_fun                 ;called for sigmoid computation;
	 POP {LR}
	 BX lr
	 ENDFUNC
	 
	 LTORG

;******************************************************************
;		XNOR

__xnor FUNCTION
	 PUSH {LR}
	 VLDR.F32 S4,= 0.7			    ; w1
	 VLDR.F32 S5,= -0.4				; w2
	 VLDR.F32 S6,= -1				; w3
	 VLDR.F32 S7,= 0.7				; Bias
	                            
	 VMUL.F32 S0, S0, S4			; x0*w1
	 VMUL.F32 S1, S1, S5			; x1*w2
	 VMUL.F32 S2, S2, S6			; x2*w3
	 VADD.F32 S3, S0, S1			; x0*w1 + x1*w2 
	 VADD.F32 S3, S3, S2			; x0*w1 + x1*w2 + x2*w3 
	 VADD.F32 S3, S3, S7			; z = x0*w1 + x1*w2 + x2*w3 + Bias
	 MOV R3, #0                     ; keeping zero on default in R3      
	 VNEG.F32 S3, S3                ; z changes to (-z) for sigmoid computation
	 VMOV.F32 S0, S3;		        ;(-z) is stored in S0
	 
	 BL sigmoid_fun                 ;called for sigmoid computation;
	 POP {LR}
	 BX lr
	 ENDFUNC

;******************************************************************
;		NAND

__nand FUNCTION
	 PUSH {LR}
	 VLDR.F32 S4, = 0.6				; w1
	 VLDR.F32 S5, =-0.8				; w2
	 VLDR.F32 S6, =-0.8				; w3
	 VLDR.F32 S7, = 0.3				; Bias
	                            
	 VMUL.F32 S0, S0, S4			; x0*w1
	 VMUL.F32 S1, S1, S5			; x1*w2
	 VMUL.F32 S2, S2, S6			; x2*w3
	 VADD.F32 S3, S0, S1			; x0*w1 + x1*w2 
	 VADD.F32 S3, S3, S2			; x0*w1 + x1*w2 + x2*w3 
	 VADD.F32 S3, S3, S7			; z = x0*w1 + x1*w2 + x2*w3 + Bias
	                            
	 VNEG.F32 S3, S3                ; z changes to (-z) for sigmoid computation
	 VMOV.F32 S0, S3;		        ;(-z) is stored in S0
	 
	 BL sigmoid_fun                 ;called for sigmoid computation;
	 POP {LR}
	 BX lr
	 ENDFUNC

;******************************************************************
;		NOR

__nor FUNCTION
	 PUSH {LR} 
	 VLDR.F32 S4, = 0.5				; w1
	 VLDR.F32 S5, =-0.7			    ; w2
	 VLDR.F32 S6, =-0.7				; w3
	 VLDR.F32 S7, = 0.1				; Bias
	                            
	 VMUL.F32 S0, S0, S4			; x0*w1
	 VMUL.F32 S1, S1, S5			; x1*w2
	 VMUL.F32 S2, S2, S6			; x2*w3
	 VADD.F32 S3, S0, S1			; x0*w1 + x1*w2 
	 VADD.F32 S3, S3, S2			; x0*w1 + x1*w2 + x2*w3 
	 VADD.F32 S3, S3, S7			; z = x0*w1 + x1*w2 + x2*w3 + Bias
	          
	 VNEG.F32 S3, S3   				; z changes to (-z) for sigmoid computation
	 VMOV.F32 S0, S3;		        ;(-z) is stored in S0
	 
	 BL sigmoid_fun                 ;called for sigmoid computation           
	 POP {LR}	
	 BX lr
	 ENDFUNC

;******************************************************************
;		NOT

__not FUNCTION
	 PUSH {LR};	 
	 VLDR.F32 S4,= 0				; w1
	 VLDR.F32 S5,= 0.5				; w2
	 VLDR.F32 S6,= -0.7				; w3
	 VLDR.F32 S7,= 0.1				; Bias
	 VMUL.F32 S0, S0, S4			; x0*w1
	 VMUL.F32 S1, S1, S5			; x1*w2
	 VMUL.F32 S2, S2, S6			; x2*w3
	 VADD.F32 S3, S0, S1			; x0*w1 + x1*w2 
	 VADD.F32 S3, S3, S2			; x0*w1 + x1*w2 + x2*w3 
	 VADD.F32 S3, S3, S7			; z = x0*w1 + x1*w2 + x2*w3 + Bias
	                            
	 VNEG.F32 S3, S3                ; z changes to (-z) for sigmoid computation
	 VMOV.F32 S0, S3;		        ;(-z) is stored in S0
	 BL sigmoid_fun                 ;called for sigmoid computation
	 POP {LR};	
	 BX lr;
	 ENDFUNC
;******************************************************************  
compute_not FUNCTION	
	
	 PUSH {LR} 
	 MOV R4,#1			;x0 input
     MOV R5,#1		    ;x1 input
	 MOV R6,#0			;x2 input
	 BL load_fpu_reg;   ;loading inputs to FP registers
	 BL __not           
	 BL printMsg4p;
	 
	 
	 MOV R4,#1		    ;x0 input
	 MOV R5,#1			;x1 input
	 MOV R6,#1			;x2 input
	 BL load_fpu_reg;   ;loading inputs to FP registers
	 BL __not; 
	 BL printMsg4p;
	 POP {LR};	
	
     BX lr;							
	 ENDFUNC  					
	 ENDFUNC  

;******************************************************************  
	END