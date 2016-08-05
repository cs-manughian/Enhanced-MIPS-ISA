#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:    	proj2_unitvector.asm
# Version:      	1.0
# Date:         	April 10, 2015  
# Programmer:   	Cosi Manughian-Peter
#
# Description:  	This is an enhanced MIPS instruction that calculates the unit vector
#   	 of a vector. The formula for a unit vector is the vector divided by its magnitude:
#   					 u / ||u||   						 
#   	 The instruction format is as follows:
#   	 
#   					unitvector d, a, b
#
#   	We want to find the unit vector of vector a, which has b elements. The address of
#    	vector a is in a, and the base address of vector d, the resulting unit vector, will
#    	be placed in d. The vector a can have an arbitrary 1-8 elements, which means that
#   	the vector can be 1-8 words wide or 8-256 bits wide. In this example, we will use:
#
#   					unitvector $s0, $s1, $s2
#
#   	 where $s1 contains the address of vector a, $s2 contains the number
#   	 of elements of vector a, and $s0 will contain the base address of
#   	 the resulting unit vector.
#
# Register usage:  
#    	 $s0: Base address of the resulting unit vector
#    	 $s1: Holds base address of vectora
#    	 $s2: Number of elements in the vector (number of dimensions)
#    	 $t0: Use to compare number of elements with number of loops
#    	 $t1: Use to get address of vectora[i]
#    	 $t2: Temp used to save a vector element
#    	 $t3: Has magnitude of vector
#   	 $t4: Use as temp and then to get address of vectord[i]
#	 $f4: Holds magnitude of vector a
#
# Notes:	 
#
#******************************************************************************************

       	#**********************************************************
       	#         	M A I N 	C O D E S E G M E N T  
       	#**********************************************************

       	.text                    	# main (must be global)
       	.globl main

main: 	 	 #Initializations
   						 #User will load vector address in $s1
   		 la $s1, vectora         	 #Get base address of vector a and store in $s1
   		 la $s0, vectord   		 #Put base address of vector d in $s0
   		  
   		 addi $s2, $zero, 3		 #Set number of elements to 3
   		 				 #Fill in 3 elements in vector a for testing
		 addi $t4, $zero, 2	   	  
         	 sw   $t4, 0($s1)	
            	 addi $t4, $zero, 5	   	 #Value 2
            	 sw   $t4, 4($s1)		
            	 addi $t4, $zero, 7	   	 #Value 3
            	 sw   $t4, 8($s1) 

   		 add $t1, $zero, $s1    	 #Save base address of vectora in $t1
   		 add $t4, $zero, $s0    	 #Save base address of vectord in $t4
   		 add $t0, $s2, $zero   		 #Use number of elements as counter for loop   								 
   		 
   		 #Find magnitude
   		 #(use other function vectormag)
   		 
   		 				 #Set a number as the magnitude from vectormag instruction
   		 				 #We must put in the value ourselves for testing purposes
   		 l.s $f4, fpmag			 #Load from memory
   		 				 #The value is put into memory in the .data section
   		 				 
   		 cvt.w.s $f4, $f4		 #$f4 holds magnitude of vector a as a result of vectormag
   		 				 #Convert it to a 32-bit integer equivalent
   		 mfc1 $t3, $f4  	 	 #Move magnitude into $t3
   								 
   		 #Divide each element by the magnitude

contDiv:
   		 lw  $t2, 0($t1)   	     	 #Load vectora[i] into $t2
   		 div $t2, $t3   	     	 #Divide the element by the magnitude and it's stored in LO
   		 
   		 
   		 mflo $t2   		     	 #Put resulting division from LO into $t2   	 
   		 sw $t2, 0($t4)   		 #Put the result ($t2) into vector d   	 
   		 addi $t4, $t4, 4        	 #Increment vectord index
   		 addi $t1, $t1, 4        	 #Increment vectora index    
   		 addi $t0, $t0, -1   		 #Decrement counter
   		 bne  $t0, $zero, contDiv    	 #Continue until we reached the end of the vector


       	#-----------------------------------------------------------
       	# "Due diligence" to return control to the kernel
       	#-----------------------------------------------------------
exit:  	ori    	$v0, $zero, 10 	# $v0 <-- function code for "exit"
       	syscall                   	# Syscall to exit


       	#************************************************************
       	#  P R O J E C T	R E L A T E D	S U B R O U T I N E S
       	#************************************************************
proc1: 	j     	proc1           	# "placeholder" stub



       	#************************************************************
       	# P R O J E C T	R E L A T E D	D A T A   S E C T I O N
       	#************************************************************
       	.data                     	# place variables, arrays, and
                                     	#   constants, etc. in this area

vectora:   .space 32   	 #Vector A holds 8 words    
vectord:   .space 32   	 #Vector A holds 8 words 
  		    	 
fpmag:	   .float 8.8	#Use as magnitude of vector from vectormag                 	 



