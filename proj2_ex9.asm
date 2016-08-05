#*************************** SIMD MIPS Baseline Instructions *****************************
#
# File name:        vec_pack.asm
# Version:          1.0
# Date:             March 30, 2015  
# Programmer:       Nancy Torres
#
# Description:      This baseline instruction performs a vector pack operation. Each high
#		    element of vector d is truncation of the corresponding element of vector
#		    a. Each low element of vector d is the truncation of the corresponding
#		    element of vector b. It is formatted as follows:
#					vec_pack d, a, b
#		    We used two 32-bit registers to create each vector, for example
#					vec_pack $s6, $t2, $t4
#		    where vector a uses registers $t2 and $t3, and vector b uses registers
#		    $t4 and $t5. Each element of vector a and vector b is truncated to 4 bits.
#		    The truncated result is stored in $s6 and $s7, where $s6 holds the upper 
#		    32 bits (from vector a) and $s7 holds the lower 32 bits (from vector b). 
#
# Register usage:  $s0: lower 4 bits of element from vector b
#		    $s1: Shift amount for lower 32 bits
#		    $s2: Shift amount for upper 32 bits
#		    $s6: Upper 32 bits of vector d
#		    $s7: Lower 32 bits of vector d 
#		    $t2: Upper 32 bits of vector a
#		    $t3: Lower 32 bits of vector a
#		    $t4: Upper 32 bits of vector b
#		    $t5: Lower 32 bits of vector b
#		    $t6: Rightmost element of upper 32 bits
#		    $t7: Boolean that is set to true when using lower 32 bits
#		    $t8: lower 4 bits of element from vector a
#		    $t9: Masks rest of the bits, allowing us to access the lower 4 bits of the
#			 current element
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
           addi $v1, $zero, 8			#Initialize register to count every other 4 
           					#bits from indexes 7 to 0
           addi $t6, $zero, 4			#Use to check value of $v1
           addi $t9, $zero, 0x0000000F		#Use to access the 4 bits from current element
           addi $s1, $zero, 0			#Set shift amount to 0
           addi $s2, $zero, 32			#Set shift amount to 32
           
           #Set by user
           addi $t2, $zero, 0x5AFB6C1D 	        #Initialize upper 32 bits of vector a
           addi $t3, $zero, 0xAE5FC041		#Initialize lower 32 bits of vector a
           addi $t4, $zero, 0x52F3A415 		#Initialize upper 32 bits of vector b       
           addi $t5, $zero, 0xA657C849		#Initialize lower 32 bits of vector b
                           
	
loop:
	   and $t8, $t2, $t9			#Get bits for upper 32 bits of vector a
	   and $s0, $t4, $t9			#Get bits for upper 32 bits of vector b
			
	   slti $t7, $v1, 5			#If v1 <= 4 (if we're using the upper 32 bits)
	   bne $t7, $zero, upperReg		#Skip 
	
						#We're using lower 32 bits
	   and $t8, $t3, $t9			#Get bits for lower 32 bits of vector a
	   and $s0, $t5, $t9			#Get bits for lower 32 bits of vector b
	
upperReg:
	  
	
	   beq $v1, $zero, exit		        #if v1 == 0, we're done
	   
		
	   slti $t7, $v1, 5			#If v1 <= 4 (if we're using the upper 32 bits)
	   bne $t7, $zero, uppershift		#Skip 
	   					#We're using lower 32 bits  
	   srlv $t8, $t8, $s1			#Shift right bits from vector a to appropriate index
	   srlv $s0, $s0, $s1			#Shift right bits from vector b to appropriate index
uppershift:


	   slti $t7, $v1, 5			#If v1 > 4 (if we're using the lower 32 bits)
	   beq $t7, $zero, lowershift		#Skip 
	   					#We're using upper 32 bits  
	   sllv $t8, $t8, $s2			#Shift left bits from vector a to appropriate index
	   sllv $s0, $s0, $s2			#Shift left bits from vector b to appropriate index
lowershift:	   	   
	   	   	   
	   add $s7, $s7, $s0			#Save lower 32 bits in $s7
       	   add $s6, $s6, $t8			#Save upper 32 bits in $s6
	
	   addi $v1, $v1, -1			#Decrement 4 bit counter
	   sll $t9, $t9, 8			#Access other 4 bits
	   addi $s1, $s1, 4			#Increment shift amount by 4
	   addi $s2, $s2, -4			#Decrement shift amount by 4
	   
	   bne $v1, $t6, v1checked		#Check if we're switching to upper 32 bits (v1 = 4)
	   addi $t9, $zero, 0x0000000F		#Reset to access first byte of register
v1checked:
	   
	   bne $v1, $zero, loop			#Loop back up to truncate the next elements from vectors 
	   					#a and b and make them the new elements of vector d
			


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

        
                      
	
