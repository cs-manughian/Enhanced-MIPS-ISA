#*************************** SIMD MIPS Baseline Instructions *****************************
#
# File name:        vec_madd.asm
# Version:          1.0
# Date:             March 30, 2015  
# Programmer:       Nancy Torres
#
# Description:      This baseline instruction performs a vector multiply and add operation.
#		    Each element of vector a is multiplied to the corresponding element of  
#		    vector b. The product is then added to the corresponding element of 
#		    vector c. The result is stored in the corresponding element of vector d.
#		    It is formatted as follows:
#					vec_madd d, a, b, c
#		    We used two 32-bit registers to create each vector, for example
#					vec_madd $s6, $t2, $t4, $s2
#		    where vector a uses registers $t2 and $t3, vector b uses registers
#		    $t4 and $t5, and vector c uses registers $s2 and $s3 to perform a 64 bit 
#		    vector multiply and add. The result is stored in $s6 and $s7, where $s6 
#		    holds the upper 32 bits and $s7 holds the lower 32 bits.
#
# Register usage:   $s0: 8-bit element of vector b 
#		    $s1: Shift amount when using lo
#		    $s2: Upper 32 bits of vector c
#		    $s3: Lower 32 bits of vector c
#		    $s4: Boolean that is set when lo is accessed
#		    $s5: Shift amount when using hi
#		    $s6: Upper 32 bits of vector d
#		    $s7: Lower 32 bits of vector d
#		    $t0: 8-bit element of vector c 
#		    $t1: Sum of current elements from vectors a and b multiplied with current 
#			 element from vector d
#		    $t2: Upper 32 bits of vector a
#		    $t3: Lower 32 bits of vector a
#		    $t4: Upper 32 bits of vector b
#		    $t5: Lower 32 bits of vector b
#		    $t6: Rightmost element of upper 32 bits
#		    $t7: Boolean that is set to true when using lower 32 bits
#		    $t8: 8-bit element of vector a
#		    $t9: Masks rest of the bits, allowing us to access current 8-bit element
#		    $v1: Counter for vector elements
#
# 
# Notes:     
#
#******************************************************************************************

           #**********************************************************
           #             M A I N     C O D E S E G M E N T  
           #**********************************************************

           .text                        # main (must be global)
           .globl main

main:      #Initializations
           addi $s7, $zero, 0			#Clear register to store lower 32 bits
           addi $s6, $zero, 0			#Clear register to store upper 32 bits
           addi $v1, $zero, 8			#Initialize register to count bytes from 8 to 0
           addi $t6, $zero, 4			#Use to check value of $v1
           addi $t9, $zero, 0x000000FF		#Use to access bytes
           addi $s1, $zero, 0			#Set shift amount to zero
           addi $s5, $zero, 32			#Set shift amount to 32
           
           #Set by user
           addi $t2, $zero, 0x120C1A0D 	        #Initialize upper 32 bits of vector a
           addi $t3, $zero, 0x23051912		#Initialize lower 32 bits of vector a
           addi $t4, $zero, 0x3D0C104D 		#Initialize upper 32 bits of vector b       
           addi $t5, $zero, 0x057F192B		#Initialize lower 32 bits of vector b
           addi $s2, $zero, 0x60091B05		#Initialize upper 32 bits of vector c
           addi $s3, $zero, 0x501E0660		#Initialize lower 32 bits of vector c
	
loop:
	   and $t8, $t2, $t9			#Get byte for upper 32 bits of vector a
	   and $s0, $t4, $t9			#Get byte for upper 32 bits of vector b
	   and $t0, $s2, $t9			#Get byte for upper 32 bits of vector c
			
	   slti $t7, $v1, 5			#If v1 <= 4 (if we're using the upper 32 bits)
	   bne $t7, $zero, upperReg		#Skip 
	
						#We're using lower 32 bits
	   and $t8, $t3, $t9			#Get byte for lower 32 bits of vector a
	   and $s0, $t5, $t9			#Get byte for lower 32 bits of vector b
	   and $t0, $s3, $t9			#Get byte for lower 32 bits of vector c
	
upperReg:
	   
	   mult $t8, $s0			#Multiply current elements from vectors a and b
	   
	   
	   slti $s4, $s1, 9 			#Check if we are using the hi register
	   beq $s4, $zero, hi 			#If we're using the hi register we skip
	   
	   					#We're using the lo register
	   mflo  $t1				#Move the value of lo register into $t1
	   srlv $t1, $t1, $s1			#Shift product to correct index
	   add $t1, $t1, $t0			#Add element from vector c to the product
	   	
hi:	   slti $s4, $s1, 9 			#Check if we're using the lo register
	   bne $s4, $zero, lo	 		#If we're using the lo register we skip

 	   					#We're using the hi register
	   mfhi  $t1				#Move the value of hi register into $t1
	   srlv $t0, $t0, $s5			#shift element from vector c to line up with sum
	   					#this avoids overflow error when adding to the
	   					#last byte
	   add $t1, $t1, $t0			#Add element from vector c to the product
	   sllv $t1, $t1, $s5			#Shift result to correct index
	   
lo:	   and $t1, $t1, $t9			#Carry out will not be saved
		     					
	
	   beq $v1, $zero, exit		        #if v1 == 0, we're done

       	   add $s7, $s7, $t1			#Save lower 32 bits in $s7
	
	   slti $t7, $v1, 5			#if $v1 <= 4 (we are using upper 32 bits)
	   beq $t7, $zero, storeLowerReg	
	   sub $s7, $s7, $t1			#Undo the add because we're using $s6 now
	   add $s6, $s6, $t1			#Save upper 32 bits in $s6
	
storeLowerReg:
	   addi $v1, $v1, -1			#Decrement byte counter
	   sll $t9, $t9, 8			#Access next byte
	   addi $s1, $s1, 8			#Change shift amount for lo
	   addi  $s5, $s5, -8			#Change shift amount for hi
	   
	   bne $v1, $t6, v1checked		#Check if we're switching to upper 32 bits (v1 = 4)
	   addi $t9, $zero, 0x000000FF		#Reset to access first byte of register
	   addi $s1, $zero, 0			#Reset lo shift amount to zero
	   addi $s5, $zero, 32			#Reset hi shift amount to 16
v1checked:
	   
	   bne $v1, $zero, loop			#Loop back up to do another byte multiplication and addition
			
	 			

           #-----------------------------------------------------------
           # "Due diligence" to return control to the kernel
           #-----------------------------------------------------------
exit:      ori        $v0, $zero, 10     # $v0 <-- function code for "exit"
           syscall                       # Syscall to exit


           #************************************************************
           #  P R O J E C T    R E L A T E D    S U B R O U T I N E S
           #************************************************************
proc1:     j         proc1               # "placeholder" stub



           #************************************************************
           # P R O J E C T    R E L A T E D    D A T A   S E C T I O N
           #************************************************************ 
           .data                         # place variables, arrays, and
                                         # constants, etc. in this area

        
                      
	
