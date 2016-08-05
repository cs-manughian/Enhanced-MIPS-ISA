#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:    	proj2_vectordisp.asm
# Version:      	1.0
# Date:         	April 10, 2015  
# Programmer:   	Cosi Manughian-Peter
#
# Description:  	This is an enhanced MIPS instruction calculates the displacement
#   			between two points. This involves scalar subtraction and results in
#   			a vector. For example, say there are two points (x1, y1) and (x2, y2). 
#			The displacement would be < x2-x1, y2-y1 >. 
#			Note that this is a signed operation. The instruction format is as follows:
#   						 
#   						vectordisp d, a, b
#
#   			 where a and b are the two points, and d is the resulting vector.
#   			 A single point is contained in two sequential registers. For example,
#   			 if the register used for a was $s0, the point's x value would be
#   			 in $s0 and the y value in $s1. The same is true for the resulting
#   			 vector. If the register used for d was $s0, the x-component of the
#   			 vector would be in $s0 and the y-component would be in $s1. Therefore,
#   			 only even numbered registers may be used. For this example, we will
#   			 use the following registers:
#
#   						vectordisp $s0, $t0, $t2
#
#
# Register usage:  
#    	 $s0: High 32 bits of resulting vector
#    	 $s1: Low 32 bits of resulting vector
#   	 $t0: x-component of point 1
#   	 $t1: y-component of point 1
#   	 $t2: x-component of point 2
#   	 $t3: y-component of point 2
#   	 $t4: Stores temp displacement
#
# Notes:	 
#
#******************************************************************************************

       	#**********************************************************
       	#         	M A I N 	C O D E S E G M E N T  
       	#**********************************************************

       	.text                    	# main (must be global)
       	.globl main

main:
		#Initializations
		
		#Point 1 for testing
		addi $t0, $zero, 3		#x1
		addi $t1, $zero, 2		#y1
		
		#Point 2 for testing	
		addi $t2, $zero, 5		#x2
		addi $t3, $zero, 3		#y2
		
	 					 #This is a signed operation
   		sub $t4, $t2, $t0   		 #Subtract the x-components x2-x1
   		
   		add $s0, $zero, $t4   		 #Store value x2 - x1 into high 32 bits of result vector, $s0
   	    
   		sub $t4, $t3, $t1   		 #Subtract the y-components       
   		
   		add $s1, $zero, $t4   		 #Store value y2 - y1 into low 32 bits of result vector, $s1

   		 
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


   	    	 
                 	 


