#*************************** SIMD MIPS Baseline Instructions *****************************
#
# File name:        vec_mergel.asm
# Version:          1.0
# Date:             April 1, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This baseline instruction performs a vector merge low.
#		The even elements of the result vector d are obtained left-
#		to-right from the low elements of vector a. The odd elements
#		of the result are obtained left-to-right from the low elements
#		of vector b. The format is as follows:
#				vec_mergel d, a, b
#		In this program, we use the following registers:
#				vec_mergel $s0, $t0, $t2
#		where vector d is made up of registers $s0 and $s1, and vector
#		a is made up of registers $t0 and $t1. Vector b uses $t2 and
#		$t3. All of the vectors are 64 bits wide.
#
# Register usage:   $s0: Upper 32 bits of vector d
#		    $s1: Lower 32 bits of vector d
#		    $t0: Upper 32 bits of vector a
#		    $t1: Lower 32 bits of vector a
#		    $t2: Upper 32 bits of vector b
#		    $t3: Lower 32 bits of vector b
#		    $t4: Used for byte selection
#		    $t5: Holds byte 4 of vector a or b
#		    $t6: Holds byte 5 of vector a or b
#		    $t7: Holds byte 6 of vector a or b
#		    $t8: Holds byte 7 of vector a or b
#
# Notes:     
#
#******************************************************************************************

           #**********************************************************
           #             M A I N     C O D E S E G M E N T  
           #**********************************************************

           .text                       		# main (must be global)
           .globl main

main:      #Initializations

	   	#Set by user
           	addi $t0, $zero, 0x5AF0A501			
     	   	addi $t1, $zero, 0xAB0155C3
     	   	addi $t2, $zero, 0xA50F5A23			
     	   	addi $t3, $zero, 0xCD23AA3C			
     	   
     	   	#Clear storage registers
     	  	addi $s0, $zero, 0	
     	  	addi $s1, $zero, 0	
     	  	
     	  	#Other -- for byte selection
     	  	addi $t4, $zero, 0xFF000000
		
	   #Put each low element (byte) of vector a into a register
	   	
	   	and $t5, $t1, $t4	#Get byte 4 and put into $t5
	   				#Shifted into leftmost position
	   				
	   	srl $t4, $t4, 8		#Next byte
	   	and $t6, $t1, $t4	#Get byte 5 and put into $t6
	   	srl $t6, $t6, 8		#Shift into byte 2 position
	   	
	   	srl $t4, $t4, 8		#Next byte
	   	and $t7, $t1, $t4	#Get byte 6 and put into $t7
	   	sll $t7, $t7, 16	#Shift into byte 4 position
	   		   	
	   	srl $t4, $t4, 8		#Next byte
	   	and $t8, $t1, $t4	#Get byte 7 and put into $t8	
	   	sll $t8, $t8, 8		#Shift into byte 6 position
	  
	   #Add bytes from vector a to vector d ($s0 and $s1)
	   	
	   	#Bytes 4 and 5 go into $s0
	   	add $s0, $s0, $t5	
	   	add $s0, $s0, $t6		   	
	   	
	   	#Bytes 6 and 7 go into $s1
	   	add $s1, $s1, $t7
	   	add $s1, $s1, $t8

	   #Put each low element (byte) of vector b into a register
	   
	   	sll $t4, $t4, 24	#Reset byte selection to leftmost byte	
	   	and $t5, $t3, $t4	#Get byte 4 and put into $t5
	   	srl $t5, $t5, 8		#Shift into byte 1 position
	   				
	   	srl $t4, $t4, 8		#Next byte
	   	and $t6, $t3, $t4	#Get byte 5 and put into $t6
	   	srl $t6, $t6, 16	#Shift into byte 3 position
	   	
	   	srl $t4, $t4, 8		#Next byte
	   	and $t7, $t3, $t4	#Get byte 6 and put into $t7
	   	sll $t7, $t7, 8		#Shift into byte 5 position
	   		   	
	   	srl $t4, $t4, 8		#Next byte
	   	and $t8, $t3, $t4	#Get byte 7 and put into $t8	
					#In byte 7 position
	   	
	   #Add bytes from vector b to vector d ($s0 and $s1)
	   
	   	#Bytes 4 and 5 go into $s0
	   	add $s0, $s0, $t5	
	   	add $s0, $s0, $t6		   	
	   	
	   	#Bytes 6 and 7 go into $s1
	   	add $s1, $s1, $t7
	   	add $s1, $s1, $t8
	   	
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



        
                      
	
