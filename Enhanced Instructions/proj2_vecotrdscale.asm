#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:    	proj2_vectordscale.asm
# Version:      	1.0
# Date:         	April 10, 2015  
# Programmer:   	Cosi Manughian-Peter
#
# Description:  	This is an enhanced MIPS instruction that divides a vector by a scalar.   					 
#   		 The instruction format is as follows:
#
#   				vectordscale d, a, b, c
#
#   		 where a contains the base address of the vector to be scaled, b contains the value
#   		 used to scale the vector, and d contains the resulting vector. The c will contain
#   		 the number of elements in vector a. The vector a can have an arbitrary 1-8 
#		 elements, which means that the vector can be 1-8 words wide or 8-256 bits wide.
#   		 In this example, we will use:
#    
#   			 	vectordscale $s0, $s1, $s2, $s3
#
# Register usage:  
#    	 $s0: Base address of the resulting vector
#    	 $s1: Holds base address of vectora
#    	 $s2: The value to scale vectora
#   	 $s3: Number of elements in vectora
#   	 $t0: Copy of vectora address for indexing
#   	 $t1: Copy of vectord address for indexing
#   	 $t2: Temp
#   	 $t3: Counter
#
# Notes:	 
#
#******************************************************************************************

       	#**********************************************************
       	#         	M A I N 	C O D E S E G M E N T  
       	#**********************************************************

       	.text                    	# main (must be global)
       	.globl main

main:		 #Initializations
   						 #User will load vector address in $s1
   		 la $s1, vectora         	 #Get base address of vector a and store in $s1
   		 la $s0, vectord   		 #Put base address of vector d in $s0

   		 addi $t4, $zero, 4	   	 #Put values into vector a for testing
            	 sw   $t4, 0($s1)	
            	 addi $t4, $zero, 0xa	   	 #Value 2
            	 sw   $t4, 4($s1)		
            	 addi $t4, $zero, 8	   	 #Value 3
           	 sw   $t4, 8($s1) 

	    	 addi $s3, $zero, 3	   	 #User will set number of elements
	    	 addi $s2, $zero, 2	   	 #User will set value to scale vector a
	    	 
	    	 
   		 add $t0, $zero, $s1   		 #Copy of vector a address
   		 add $t1, $zero, $s0   		 #Copy of vector d address
   		 add $t3, $zero, $s3   		 #Load counter with number of elements in vector a
   								 
   		 #Multiply each element by the scaling constant   	 
contDiv:
   		 lw  $t2, 0($t0)   	     	 #Load vectora[i] into $t2
   		 div $t2, $s2   	     	 #Divide the element by the scaling constant
   						 #Result is stored in LO

   		 
   		 mflo $t2   		     	 #Put result from LO into $t2
   		 sw $t2, 0($t1)   		 #Put the result ($t2) into vector d   	 
   		 addi $t1, $t1, 4        	 #Increment vectord index
   		 addi $t0, $t0, 4        	 #Increment vectora index
   		 addi $t3, $t3, -1   		 #Decrement counter
   		 bne  $t3, $zero, contDiv   	 #Continue until we reached the end of the vector

   		 
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
vectord:   .space 32   	 #Vector D holds 8 words   		    	 
                 	 


