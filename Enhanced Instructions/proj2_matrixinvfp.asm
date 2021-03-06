#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:        proj2_matrixinvfp.asm
# Version:          1.0
# Date:             April 15, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This is an enhanced MIPS instruction to take the inverse
#		of a 2 x 2 matrix. The formula for the inverse of a 2 x 2  
#		matrix M is
#
#		M = [  a  ][  b  ]	M_inv =      1/	     * [  d  ][  -b ]
#		    [  c  ][  d  ]	       determinant(M)  [  -c ][  a  ]
#
#		For this instruction, the format is as follows:
#
#				matrixinvfp d, a
#
#		where a holds the base address of the matrix and d is the address
#		of the resulting inverted matrix. For this example, we will use
#
#				matrixinvfp $s0, $s1
#
# Register usage:  
#        $s0: Contains the address of the resulting inverted matrix
#        $s1: Base address of the matrix
#	 Sf2: Has determinant
#	 $s3: Temp for arithmetic ops
#	 $f0: Temp for matrix values
#        $t2: Hold i*4
#        $t3: Row pointer
#        $t4: Address of M[i][j]
#	 $t5: Value of M[i][j]
#	 $t6: Identify row
#	 $t7: Identify column
#	 $t8: Temp for matrix addresses and math
#	 $t9: Temp for matrix addresses and math
#	 $f8: Negation of M value
#	 $f9: Negation of M value
#
# Notes:    	This instruction requires matrix elements to be floating point numbers.	 	
#
#******************************************************************************************

           #**********************************************************
           #             M A I N     C O D E S E G M E N T  
           #**********************************************************

           .text                        # main (must be global)
           .globl main

main:	   # Initializations

	   la $s0, I			# Load address of matrix I into register $s0.
	    
	   la $s1, M			# Load address of matrix M into register $s1.
					# This is for testing purposes.
					# Matrix address will be provided by user.
	  
	   				# Find the determinant using matrixdetfp
	   l.s    $f2, Det 		# We will put calculated value in $f2 for testing
	   
	   sub.s  $f4, $f4, $f4		# $f4 = 0
	   c.eq.s $f2, $f4		# if $f2 == $f4, that means Det = 0 => Matrix is not invertible
	  				# Set FPU condition flag to true
	   add    $s4, $zero, $zero	# Clear $s4				
	   addi   $s5, $zero, 1		# Make $s5 nonzero for condition checking
	   movf   $s4, $s5		# Move $s5 into $s4 if FP condition flag is false
	   				# (If $s4 is nonzero, then det is nonzero)
	   # Check determinant != 0
	   beq    $s4, $zero, exit		# If det = 0, matrix M is not invertible => exit

	   	   
	   # Calculate inverse matrix
	   #
	   # M_inv =         1/	     * [  d  ][  -b ]
	   #	       determinant(M)  [  -c ][  a  ]
	   
	   
	   # Swap elements M[0][0] and M[1][1]
	   
	   
	   # Get M[0][0] and store in I[1][1] (swap) and divide by determinant
	   
	   addi  $t6, $zero, 0		 # Get row 0 (0-1)
	   addi  $t7, $zero, 0		 # Get column 0 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s1		 # Address of pointer M[i]
	   lw	$t3, 0($t2)		 # Address of M[i] in $t3

	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3, $t4		 # Address of M[i][j]
	   lwc1	$f0, 0($t4)		 # Load value of M[i][j]
	   
	   # We have M[0][0] in $t0 
	   	   
	   addi  $t6, $zero, 1		 # Get row 1 (0-1)
	   addi  $t7, $zero, 1		 # Get column 1 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s0		 # Address of pointer I[i]
	   lw	$t8, 0($t2)		 # Address of I[i] in $t8
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t8, $t4		 # Address of I[i][j]

 	   # We have address to I[1][1] in $t4
 	   				    
  	   div.s $f0, $f0, $f2		 # Divide I by determinant
  	  				 # Put M[0][0] / det into $f0
 	   swc1  $f0, 0($t4)		 # Store M[0][0] into I[1][1]
 	   
 	   # Get M[1][1] and store in I[0][0] (swap) and divide by determinant
	   
	   addi  $t6, $zero, 1		 # Get row 1 (0-1)
	   addi  $t7, $zero, 1		 # Get column 1 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s1		 # Address of pointer M[i]
	   lw	$t3, 0($t2)		 # Address of M[i] in $t3

	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3, $t4		 # Address of M[i][j]
	   lwc1	$f0, 0($t4)		 # Load value of M[i][j]
	   
	   # We have M[1][1] in $t0 
	   	   
	   addi  $t6, $zero, 0		 # Get row 0 (0-1)
	   addi  $t7, $zero, 0		 # Get column 0 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s0		 # Address of pointer I[i]
	   lw	$t8, 0($t2)		 # Address of I[i] in $t8
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t8, $t4		 # Address of I[i][j]

 	   # We have address to I[0][0] in $t4
 	   div.s $f0, $f0, $f2		 # Divide I by determinant
  	   			 	 # Put M[1][1] / det into $f0
 	   swc1  $f0, 0($t4)		 # Store M[1][1] into I[0][0]
 	   				 
 	   # Now a and d are swapped
 	   # Next we have to negate b and c and divide by determinant     			   
   
  	   # Get M[0][1]	   
  	   addi  $t6, $zero, 0		 # Get row 0 (0-1)
	   addi  $t7, $zero, 1		 # Get column 1 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s1		 # Address of pointer M[i]
	   lw	$t3, 0($t2)		 # Address of M[i] in $t3
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3,$t4		 # Address of M[i][j]
	   lwc1	$f0, 0($t4)		 # Load value of M[i][j]

 	   # We have M[0][1] in $t0
 	   
 	   # Get M[1][0]			 
 	   addi  $t6, $zero, 1		 # Get row 1 (0-1)
	   addi  $t7, $zero, 0		 # Get column 0 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s1		 # Address of pointer M[i]
	   lw	$t3, 0($t2)		 # Address of M[i] in $t3
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3,$t4		 # Address of M[i][j]
	   add  $t8, $zero, $t4		 # Save address in $t8 negating
	   lwc1	$f5, 0($t4)		 # Load value of M[i][j]

 	   # We have M[1][0] in $t5
 	   
 	   # Negate b and c  	   			 
  	   neg.s  $f8, $f0		 # Multiply M[0][1]*(-1)
    	   neg.s  $f9, $f5		 # Multiply M[1][0]*(-1)
    	   div.s  $f8, $f8, $f2		 # Divide I by determinant
  	   				 # Put M[0][1]*-1 / det into $t8
    	   div.s  $f9, $f9, $f2		 # Divide by I determinant
  	  				 # Put M[1][0]*-1 / det into $t9
  	   
  	   # Store negatives in I
  	   
  	   # Set I[0][1] to -b / det	   
  	   addi  $t6, $zero, 0		 # Get row 0 (0-1)
	   addi  $t7, $zero, 1		 # Get column 1 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s0		 # Address of pointer I[i]
	   lw	$t3, 0($t2)		 # Address of I[i] in $t3
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3,$t4		 # Address of I[i][j]
	   swc1	$f8, 0($t4)		 # Store value of -b in I[i][j]

   	   # Set I[1][0] to -c / det	   
  	   addi  $t6, $zero, 1		 # Get row 1 (0-1)
	   addi  $t7, $zero, 0		 # Get column 0 (0-1)
	   
	   sll	$t2, $t6, 2		 # Shift left twice (same as i * 4)
	   add	$t2, $t2, $s0		 # Address of pointer I[i]
	   lw	$t3, 0($t2)		 # Address of I[i] in $t3
	   
	   sll	$t4, $t7, 2		 # Shift left twice (same as j * 4)
	   add	$t4, $t3,$t4		 # Address of I[i][j]
	   swc1	$f9, 0($t4)		 # Store value of -c in I[i][j]
		
	
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
	   M0:	.float 3.1, 2.2	 	 # Initialize the first row of M
	   M1:	.float 2.3, 4.0	 	 # Initialize the second row of M
	   M:	.word M0, M1		 # Row pointer

	   # 2x2 Matrix I #
	   I0:	.word 0x0, 0x0	 	 # Initialize the first row of I
	   I1:	.word 0x0, 0x0	 	 # Initialize the second row of I
	   I:	.word I0, I1		 # Row pointer
	   
	   # Determinant for testing
	   Det: .float 7.3
