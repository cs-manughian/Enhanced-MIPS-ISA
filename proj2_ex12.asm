#*************************** SIMD MIPS Baseline Instructions *****************************
#
# File name:        vec_cmpltu.asm
# Version:          1.0
# Date:             March 30, 2015  
# Programmer:       Nancy Torres
#
# Description:      This baseline instruction performs a vector compare less-than unsigned 
#		    operation. Each element of vector d is TRUE (all bits = 1) if the 
#		    corresponding element of vector a is less than the corresponding element 
#		    of vector b and FALSE (all bits = 0) if otherwise. 
#		    It is formatted as follows:
#					vec_cmpltu d, a, b
#		    We used two 32-bit registers to create each vector, for example
#					vec_cmpltu $s6, $t2, $t4
#		    where vector a uses registers $t2 and $t3 and vector b uses registers
#		    $t4 and $t5. Each element is compared and the result is stored in $s6 
#		    and $s7, where $s6 holds the upper 32 bits and $s7 holds the lower 32 bits.
#
# Register usage:   $s0: 8-bit element of vector b 
#		    $s6: Upper 32 bits of vector d
#		    $s7: Lower 32 bits of vector d
#		    $t0: Boolean that is set to TRUE when the current element from vector a 
#			 is less than the current element from vector b
#		    $t1: Result from comparing current elements of vectors a and b
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
           addi $v1, $zero, 8			#Initialize register to count bytes from 
           								#indexes 7 to 0
           addi $t6, $zero, 4			#Use to check value of $v1
           addi $t9, $zero, 0x000000FF  #Use to access bytes
  
           #Set by user
           addi $t2, $zero, 0x5AFB6C1D 	#Initialize upper 32 bits of vector a
           addi $t3, $zero, 0xA65FC040  #Initialize lower 32 bits of vector a
           addi $t4, $zero, 0x52FBA415 	#Initialize upper 32 bits of vector b       
           addi $t5, $zero, 0xAE5FC841	#Initialize lower 32 bits of vector b

	
loop:
		   and $t8, $t2, $t9			#Get byte for upper 32 bits of vector a
		   and $s0, $t4, $t9			#Get byte for upper 32 bits of vector b
		  
				
		   slti $t7, $v1, 5			    #If v1 <= 4 (if we're using the upper 32 bits)
		   bne $t7, $zero, upperReg		#Skip 
		
							#We're using lower 32 bits
		   and $t8, $t3, $t9			#Get byte for lower 32 bits of vector a
		   and $s0, $t5, $t9			#Get byte for lower 32 bits of vector b

	
upperReg:
		   slt $t0, $t8, $s0			#Check if current element from vector a is 
		   								#greater than current element from vector b
		   beq $t0, $zero, notLessThan	#If element from vector a is greater than 
		   								#element from vector b skip
		   add $t1, $zero, $t9			#element from vector a is less than element
		   								#from vector b, set element from vector d 
		   								#to FF

notLessThan:
		   slt $t0, $t8, $s0			#Check if current element from vector a is 
		   								#less than current element from vector b
		   bne $t0, $zero, LessThan		#If element from vector a is less than
		   								#element from vector b skip 
		   add $t1, $zero, $zero		#element from vector a is greater than element
		   								#from vector b, set element from vector d 
		   								#to 00
	   					
LessThan:	  	  
	       					
		   beq $v1, $zero, exit		    #if v1 == 0, we're done

	       add $s7, $s7, $t1			#Save lower 32 bits in $s7
		
		   slti $t7, $v1, 5				#if $v1 <= 4 (we are using upper 32 bits)
		   beq $t7, $zero, storeLowerReg	
		   sub $s7, $s7, $t1			#Undo the add because we're using $s6 now
		   add $s6, $s6, $t1			#Save upper 32 bits in $s6
	
storeLowerReg:
		   addi $v1, $v1, -1			#Decrement byte counter
		   sll $t9, $t9, 8			    #Access next byte

		   bne $v1, $t6, v1checked		#Check if we're switching to upper 32 bits (v1 = 4)
		   addi $t9, $zero, 0x000000FF	#Reset to access first byte of register
	   
v1checked:
	   
	   	   bne $v1, $zero, loop			#Loop back up to do another byte comparison
			
	 			

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

        
                      
	
