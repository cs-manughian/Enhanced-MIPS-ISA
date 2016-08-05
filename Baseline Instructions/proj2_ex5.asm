#*************************** SIMD MIPS Baseline Instructions *****************************
#
# File name:        vec_msums.asm
# Version:          1.0
# Date:             March 30, 2015  
# Programmer:       Nancy Torres
#
# Description:      This baseline instruction performs a vector multiply sum saturated 
#		    operation. Each element of vector d is the 16-bit sum of the 
#		    corresponding 16-bit element of vector c and the 16 bit products
#		    of the 8-bit elements from vectors a and b which overlap the positions
#		    of that element in vector c. It is formatted as follows:
#					vec_msums d, a, b, c
#		    We used two 32-bit registers to create each vector, for example
#					vec_msums $s6, $t2, $t4, $s2
#		    where vector a uses registers $t2 and $t3, vector b uses registers
#		    $t4 and $t5, and vector c uses registers $s2 and $s3 to perform the  
#		    vector multiply sum saturated. The result is stored in $s6 and $s7, where
#		    $s6 holds the upper 32 bits and $s7 holds the lower 32 bits.
#
# Register usage:   $s2: Upper 32 bits of vector c
#		    $s3: Lower 32 bits of vector c
#		    $s6: Upper 32 bits of vector d
#		    $s7: Lower 32 bits of vector d
#		    $t0: Holds the byte product 
#		    $t1: Sum of products of current elements from vectors a and b added to the
#			 current 16 bit element of vector d
#		    $t2: Upper 32 bits of vector a
#		    $t3: Lower 32 bits of vector a
#		    $t4: Upper 32 bits of vector b
#		    $t5: Lower 32 bits of vector b
#		    $t6: 8-bit element of vector a 
#		    $t7: 8-bit element of vector b
#		    $t8: 16 bit element of vector d
#		    $v0: Boolean that is set to false when overflow does not occur
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
           
           #Set by user
           addi $t2, $zero, 0x230CF14D 	        #Initialize upper 32 bits of vector a
           addi $t3, $zero, 0x5C7F191A		#Initialize lower 32 bits of vector a
           addi $t4, $zero, 0xA30C5BFD 		#Initialize upper 32 bits of vector b       
           addi $t5, $zero, 0xC5FFC9EE		#Initialize lower 32 bits of vector b
           addi $s2, $zero, 0x609E19F7		#Initialize upper 32 bits of vector c
           addi $s3, $zero, 0x45670766		#Initialize lower 32 bits of vector c
           
           
           #Calculate index 3 of vector d	
           andi $t6, $t3, 0x000000FF		#Get byte from index 7 in vector a
	   andi $t7, $t5, 0x000000FF		#Get byte from index 7 in vector b
	   mulo $t0, $t7, $t6			#Get product of elements from index 7
	   andi $t6, $t3, 0x0000FF00		#Get byte from index 6 in vector a
	   andi $t7, $t5, 0x0000FF00		#Get byte from index 6 in vector b
	   srl $t6, $t6, 8			#Shift element from vector a all the
	   					#way to the right to perform multiplication
	   srl $t7, $t7, 8			#Shift element from vector b all the
	   					#way to the right to perform multiplication
	   mulo $t1, $t7, $t6			#Multiply bytes
	   add $t1, $t1, $t0			#Add products
	   andi $t8, $s3, 0x0000FFFF		#Get 16 bits from index 3 in vector d
	   add $t1, $t1, $t8			#Add the 16 bits to the sum of products
	   andi $v0, $t1, 0x0000FFFF		#Get result without carry out
	   sub $v0, $t1, $v0 			#Subtract from result to check for 
	   					#overflow and put in $v0
	   beq $v0, $zero, noOverflow1		#If $v0 is 0 there is no overflow
	   addi $t1, $zero, 0x0000FFFF		#We overflowed, saturate 16 bit integer 
noOverflow1:
	   add $s7, $s7, $t1			#Store in index 3 of vector d


	   #Calculate index 2 of vector d	
	   andi $t6, $t3, 0x00FF0000		#Get byte from index 5 in vector a
	   andi $t7, $t5, 0x00FF0000		#Get byte from index 5 in vector b
	   srl $t6, $t6, 16			#Shift element from vector a all the
	   					#way to the right to perform multiplication
	   srl $t7, $t7, 16			#Shift element from vector b all the
	   					#way to the right to perform multiplication
	   mulo $t0, $t7, $t6			#Multiply bytes
	   andi $t6, $t3, 0xFF000000		#Get byte from index 4 in vector a
	   andi $t7, $t5, 0xFF000000		#Get byte from index 4 in vector b
	   srl $t6, $t6, 24			#Shift element from vector a all the
	   					#way to the right to perform multiplication
	   srl $t7, $t7, 24			#Shift element from vector b all the
	   					#way to the right to perform multiplication
	   mulo $t1, $t7, $t6			#Multiply bytes
	   add $t1, $t1, $t0			#Add products
	   andi $t8, $s3, 0xFFFF0000		#Get 16 bits from index 2 in vector d
	   srl $t8, $s3, 16			#Shift element from vector d all the
	   					#way to the right to perform addition
	   add $t1, $t1, $t8			#Add the 16 bits to the sum of products
	   andi $v0, $t1, 0x0000FFFF		#Get result without carry out
	   sub $v0, $t1, $v0			#Subtract from result to check for 
	   					#overflow and put in $v0
	   sll $t1, $t1, 16 			#Shift result back to correct place 
	   beq $v0, $zero, noOverflow2		#If $v0 is 0 there is no overflow
	   addi $t1, $zero, 0xFFFF0000		#We overflowed, saturate 16 bit integer 
noOverflow2:
	   add $s7, $s7, $t1			#Store in index 2 of vector d


	   #Calculate index 1 of vector d	
           andi $t6, $t2, 0x000000FF		#Get byte from index 3 in vector a
	   andi $t7, $t4, 0x000000FF		#Get byte from index 3 in vector b
	   mulo $t0, $t7, $t6			#Get product of elements from index 3
	   andi $t6, $t2, 0x0000FF00		#Get byte from index 2 in vector a
	   andi $t7, $t4, 0x0000FF00		#Get byte from index 2 in vector b
	   srl $t6, $t6, 8			#Shift element from vector a all the
	   					#way to the right to perform multiplication
	   srl $t7, $t7, 8			#Shift element from vector b all the
	   					#way to the right to perform multiplication
	   mulo $t1, $t7, $t6			#Multiply bytes
	   add $t1, $t1, $t0			#Add products
	   andi $t8, $s2, 0x0000FFFF		#Get 16 bits from index 1 in vector d
	   add $t1, $t1, $t8			#Add the 16 bits to the sum of products
	   andi $v0, $t1, 0x0000FFFF		#Get result without carry out
	   sub $v0, $t1, $v0 			#Subtract from result to check for 
	   					#overflow and put in $v0
	   beq $v0, $zero, noOverflow3		#If $v0 is 0 there is no overflow
	   addi $t1, $zero, 0x0000FFFF		#We overflowed, saturate 16 bit integer 
noOverflow3:
	   add $s6, $s6, $t1			#Store in index 1 of vector d


	   #Calculate index 1 of vector d	
	   andi $t6, $t2, 0x00FF0000		#Get byte from index 1 in vector a
	   andi $t7, $t4, 0x00FF0000		#Get byte from index 1 in vector b
	   srl $t6, $t6, 16			#Shift element from vector a all the
	   					#way to the right to perform multiplication
	   srl $t7, $t7, 16			#Shift element from vector b all the
	   					#way to the right to perform multiplication
	   mulo $t0, $t7, $t6			#Multiply bytes
	   andi $t6, $t2, 0xFF000000		#Get byte from index 0 in vector a
	   andi $t7, $t4, 0xFF000000		#Get byte from index 0 in vector b
	   srl $t6, $t6, 24			#Shift element from vector a all the
	   					#way to the right to perform multiplication
	   srl $t7, $t7, 24			#Shift element from vector b all the
	   					#way to the right to perform multiplication
	   mulo $t1, $t7, $t6			#Multiply bytes
	   add $t1, $t1, $t0			#Add products
	   andi $t8, $s2, 0xFFFF0000		#Get 16 bits from index 0 in vector d
	   srl $t8, $s2, 16			#Shift element from vector d all the
	   					#way to the right to perform addition
	   add $t1, $t1, $t8			#Add the 16 bits to the sum of products
	   andi $v0, $t1, 0x0000FFFF		#Get result without carry out
	   sub $v0, $t1, $v0			#Subtract from result to check for 
	   					#overflow and put in $v0
	   sll $t1, $t1, 16 			#Shift result back to correct place 
	   beq $v0, $zero, noOverflow4		#If $v0 is 0 there is no overflow
	   addi $t1, $zero, 0xFFFF0000		#We overflowed, saturate 16 bit integer 
noOverflow4:
	   add $s6, $s6, $t1			#Store in index 0 of vector d
   
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

        
                      
	
