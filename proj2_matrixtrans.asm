#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:        proj2_matrixtrans.asm
# Version:          1.0
# Date:             April 14, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This is an enhanced MIPS instruction that takes the transpose of 
#        a square matrix. The transpose of a matrix is when the rows of the matrix are
#        written as the columns of the matrix. If we transpose matrix A, the 
#        result would be written as A_t. For this instruction, the format is
#        as follows:
#
#                    matrixtrans d, a, b, c
#
#        where a is the address of the matrix, b is the number of rows in the matrix,
#        and c is the number of columns in the matrix. The resulting matrix will be
#	 at the address in d. For this example, we will use
#
#		     matrixtrans $s3, $s0, $s1, $s2
#
# Register usage:  
#        $s0: The address of the matrix provided by user
#        $s1: The number of rows in the matrix
#        $s2: The number of columns in the matrix
#	 $s3: The address of the resulting transposed matrix
#	 $s4: Saved A[i] pointer address 
#	 $s5: Saved T[i] pointer address 
#	 $s6: Resulting T matrix address (also in $s3)
#	 $s7: Copy of $s0
#	 $t0: Number of bytes needed for an integer
#        $t1: Index for number of rows
#        $t2: Index for number of columns
#        $t3: Temp to get address of A[i]
#        $t4: Address of A[i]
#	 $t5: Temp to get address of A[i][j]
#	 $t6: Value of A[i][j]
#	 $t7: Temp to store values into A[i][j]
#	 $t8: Temp A[i] pointer address
#	 $t9: Temp T[i] pointer address 
#
# Notes:     	Matrix A must have integer values. Only four bytes are being allocated
#	 for each element in the matrix.
#
#******************************************************************************************

           #**********************************************************
           #             M A I N     C O D E S E G M E N T  
           #**********************************************************

           .text                        # main (must be global)
           .globl main
main:
	   #Initializations
	   li $s1, 3			#Load $s1 (#rows) with value for testing
	   li $s2, 3			#Load $s2 (#columns) with value for testing
	   li $t0, 4			#Number of bytes needed for an integer
    	   add $t1, $zero, $s1		#Save number of rows i
    	   add $t2, $zero, $s2		#Save number of columns j
    	   addi $t7, $zero, 0x3		#Use to intialize matrix with values

    	   #Create matrix A for testing
	   mul $a0, $s1, $s2		#( #row in $s1 X #column in $s2 )
	   mul $a0, $a0, $t0		#( #row in $s1 X #column in $s2 ) X 4 bytes per integer element
    	   li $v0, 9			#System code to allocate heap memory for matrix
    	   syscall			#Allocate memory
    	   add $s0, $zero, $v0		#Put matrix address in $s0 for testing   
    	   add $s7, $zero, $v0		#Put matrix address in $s7 too  
    	   
    	   mul $a0, $s1, $t0		#Allocate i bytes to save row pointers A[i]
    	   li $v0, 9			#System code to allocate heap memory for row pointers
    	   syscall			#Allocate memory
    	   add $t8, $zero, $v0		#Put A[i] pointer address in $t8
	   add $s4, $zero, $v0		#Also save A[i] pointer address in $s4
	   
    	   #Create matrix T for transpose
    	   				#It is the same dimensions as A
	   mul $a0, $s1, $s2		#( #row in $s1 X #column in $s2 )
	   mul $a0, $a0, $t0		#( #row in $s1 X #column in $s2 ) X 4 bytes per integer element
    	   li $v0, 9			#System code to allocate heap memory for matrix
    	   syscall			#Allocate memory
    	   add $s3, $zero, $v0		#Put resulting T matrix address in $s3 
    	   add $s6, $zero, $v0		#Also save it in $s6
    	   
    	   mul $a0, $s1, $t0		#Allocate i bytes to save row pointers A[i]
    	   li $v0, 9			#System code to allocate heap memory for row pointers
    	   syscall			#Allocate memory
    	   add $t9, $zero, $v0		#Put T[i] pointer address in $t9
    	   add $s5, $zero, $v0		#Also save T[i] pointer address in $s5
    	      	       	   		
    	      	       	   
    	   #Initialize matrix A with values

    	   #   for( int i = rows; i > 0; i--)
    	   #     for( int j = cols; j > 0; j--)				
    
    initAi:
    
    	   add  $t2, $zero, $s2		#Re-initialize j for inner loop
    	   sw   $s0, 0($t8)		#Store row pointer A[i] at $t8
    	   addi $t8, $t8, 4		#Increment pointer for A[i+1]
    	   			   					   					   				
	initAj:    	   				

	   sw   $t7, 0($s0)		#Store value into A to initialize
	   addi $s0, $s0, 4		#Increment pointer for next element   
	   addi $t7, $t7, 0x1		#Change value of next element to have variation for testing
    	   
    	   addi $t2, $t2, -1		#Decrement j to intialize
    	   bne  $t2, $zero, initAj	#Keep initializing with i fixed and j decrementing
    	   
    	   addi $t1, $t1, -1		#Decrement i to intialize
    	   bne  $t1, $zero, initAi	#Keep initializing with j fixed and i decrementing
    	   
    	   add  $s0, $zero, $s7		#Restore original $s0 value
    	   
    	   
    	   #Get column pointers for matrix T
    	   
    	   add $t1, $zero, $s1		#Reset number of rows i
    	   add $t2, $zero, $s2		#Reset number of columns j   	  
    	   add $t9, $zero, $s5 		#Reset base pointer to T[i]
    	    
    	   #   for( int i = cols > 0; i--)
    	   #     for( int j = rows; j > 0; j--)	 
    	   		
    outer_pT:
    
       	   add  $t1, $zero, $s1		#Re-initialize j for inner loop
    	   sw   $s6, 0($t9)		#Store pointer T[i] at $t9
    	   addi $t9, $t9, 4		#Increment pointer for T[i+1]
    	   
    	inner_pT:

    					#$s6 holds base address to matrix T
    	   addi $s6, $s6, 4		#Increment pointer for next element 
    	
    	   addi $t1, $t1, -1		#Decrement number of rows for next iteration	   
    	   bne  $t1, $zero, inner_pT	#Branch if rows != 0	   
    	   
    	   addi $t2, $t2, -1		#Decrement number of cols for next iteration
    	   bne  $t2, $zero, outer_pT	#Branch if columns != 0   
    	        	   	
    	   
    	   #Transpose matrix A and put into T
    	   
    	   #   for ( i = 0; i < ROWS; i++ )
      	   #     for( j = 0; j < COLS; j++ )
           #		transpose[j][i] = matrixA[i][j];

    	   add  $t1, $zero, $s1		#Reset number of rows i
    	   add  $t2, $zero, $s2		#Reset number of columns j   	  
    	   add  $t8, $zero, $s4 	#Reset base row pointer to A[i]
    	   add  $t9, $zero, $s5 	#Reset base column pointer to T[i] 
    	   
    	   				#No longer need $s7 or $t7 so reuse them
    	   add $t7, $zero, $zero	#Start i = 0
    	   add $s7, $zero, $zero	#Start j = 0
 	  	     	   
    outerLoopT:
    	   
    	   add  $s7, $zero, $zero	#Re-initialize j for inner loop
	   
    	innerLoopT:
    	
     	   #Get matrix A[i][j]
    	   sll	$t3, $t7, 2		#Shift left twice (same as i * 4)
	   add	$t3, $t3, $t8		#Address of pointer A[i], i * 4 + base address of A
	   lw	$t4, 0($t3)		#Get address of an array A[i] and put it into register $t4
	   
	   sll	$t5, $s7, 2		#Shift left twice (same as j * 4)
	   add	$t5, $t4, $t5		#Address of A[i][j]
	   lw	$t6, 0($t5)		#Load value of A[i][j] into $t6
    	
    	   #Store A[i][j] into T[j][i]
    	   
    	   sll	$t3, $s7, 2		#Shift left twice (same as j * 4)
	   add	$t3, $t3, $t9		#Address of pointer T[j], j * 4 + base address of A
	   lw	$t4, 0($t3)		#Get address of an array T[j] and put it into register $t4
	   
	   sll	$t5, $t7, 2		#Shift left twice (same as i * 4)
	   add	$t5, $t4, $t5		#Address of T[j][i]
	   sw	$t6, 0($t5)		#Store value from A into T[j][i]
    	
    	
    	   addi $s7, $s7, 1		#Increment number of cols for next iteration
    	   bne  $s7, $t2, innerLoopT	#Branch if if j >= number of columns
    	        	   	
    	   addi $t7, $t7, 1		#Increment number of rows for next iteration	   
    	   bne  $t7, $t1, outerLoopT	#Branch if i >= number of rows
        
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
                      

