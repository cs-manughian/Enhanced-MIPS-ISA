#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:        proj2_matrixdet.asm
# Version:          1.0
# Date:             April 14, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This is an enhanced MIPS instruction to take the determinant
#		of a 2 x 2 matrix. The formula for a determinant of a 2 x 2 is 
#		det = M00*M11 - M01*M10. For this instruction, the format is as follows:
#
#				matrixdet d, a
#
#		where a holds the base address of the matrix and d is the resulting
#		determinant (a scalar). For this example, we will use
#
#				matrixdet $s0, $s1
#
# Register usage:  
#        $s0: Contains the determinant
#        $s1: Base address of the matrix
#	 $t0: Temp for matrix values
#        $t2: Hold i*4
#        $t3: Row pointer
#        $t4: Address of M[i][j]
#	 $t5: Value of M[i][j]
#	 $t6: Identify row
#	 $t7: Identify column
#	 $t8: Temp for matrix values
#	 $t9: Temp for multiplying matrix values
#
# Notes:    	This instruction requires matrix elements to be integers.	 	
#
#******************************************************************************************

           #**********************************************************
           #             M A I N     C O D E S E G M E N T  
           #**********************************************************

           .text                        # main (must be global)
           .globl main

main:	   #Initializations
	   la $s1, M			# Load address of matrix M into register $s1.
					# This is for testing purposes.
					# Matrix address will be provided by user.
	   
	   # Determinant = M00*M11 - M01*M10
	   #		 = a*d - b*c
	   #
	   #	    0        1
	   #	0[  a 	][   b	] 	
	   #	1[  c	][   d	]
	   #
	   
	   # Get elements
	   addi  $t6, $zero, 0		 # Get row 0 (0-1)
	   addi  $t7, $zero, 0		 # Get column 0 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s1		 # Address of pointer M[i]
	   lw	$t3, 0($t2)		 # Address of M[i] in $t3
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3,$t4		 # Address of M[i][j]
	   lw	$t0, 0($t4)		 # Load value of M[i][j]

 	   # We have M[0][0] in $t0
 	   				 
 	   addi  $t6, $zero, 1		 # Get row 1 (0-1)
	   addi  $t7, $zero, 1		 # Get column 1 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s1		 # Address of pointer M[i]
	   lw	$t3, 0($t2)		 # Address of M[i] in $t3
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3,$t4		 # Address of M[i][j]
	   lw	$t5, 0($t4)		 # Load value of M[i][j]

 	   # We have M[1][1] in $t5
 	    	   			   
  	   mul  $t8, $t0, $t5		 # Multiply M[0][0]*M[1][1]
  	   
  	   # We have M[0][0]*M[1][1] in $t8
  	   
  	   addi  $t6, $zero, 0		 # Get row 0 (0-1)
	   addi  $t7, $zero, 1		 # Get column 1 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s1		 # Address of pointer M[i]
	   lw	$t3, 0($t2)		 # Address of M[i] in $t3
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3,$t4		 # Address of M[i][j]
	   lw	$t0, 0($t4)		 # Load value of M[i][j]

 	   # We have M[0][1] in $t0
 	   				 
 	   addi  $t6, $zero, 1		 # Get row 1 (0-1)
	   addi  $t7, $zero, 0		 # Get column 0 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s1		 # Address of pointer M[i]
	   lw	$t3, 0($t2)		 # Address of M[i] in $t3
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3,$t4		 # Address of M[i][j]
	   lw	$t5, 0($t4)		 # Load value of M[i][j]

 	   # We have M[1][0] in $t5
 	    	   			 
 	   mul  $t9, $t0, $t5		 # Multiply M[0][1]*M[1][0]
  	   
  	   # We have M[0][1]*M[1][0] in $t9
  	   
  	   # Calculate determinant
  	   sub $s0, $t8, $t9		 # $s2 = M[0][0]*M[1][1] - M[0][1]*M[1][0]
            
           #-----------------------------------------------------------
           # "Due diligence" to return control to the kernel
           #-----------------------------------------------------------
exit:      ori        $v0, $zero, 10         # $v0 <-- function code for "exit"
           syscall                           # Syscall to exit


           #************************************************************
           #  P R O J E C T    R E L A T E D    S U B R O U T I N E S
           #************************************************************
proc1:     j         proc1               # "placeholder" stub



           #************************************************************
           # P R O J E C T    R E L A T E D    D A T A   S E C T I O N
           #************************************************************
           .data                         # place variables, arrays, and
                                         #   constants, etc. in this area

      	   .align 2          		 # Alignment on word (4 byte) boundary    
      	        
	   # 2x2 Matrix M #
	   M0:	.word 0x3, 0x2	 	 # Initialize the first row of M
	   M1:	.word 0x2, 0x4	 	 # Initialize the second row of M
	   M:	.word M0, M1		 # Row pointer

