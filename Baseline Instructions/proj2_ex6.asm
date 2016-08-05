#*************************** SIMD MIPS Baseline Instructions *****************************
#
# File name:        vec_splat.asm
# Version:          1.0
# Date:             April 1, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This baseline instruction performs a vector splat.
#		The "splat" instruction is used to copy any element from
#		one vector into all of the elements of another vector. Each
#		element of the result vector d is component b of vector a.
#		The format is as follows:
#				vec_splat d, a, b
#		In this program, we use the following registers:
#				vec_splat $s0, $t0, $t2
#		where $t2 holds the byte number (0-7) of the byte to be 
#		copied into vector d.
#
# Register usage:   $s0: Upper 32 bits of vector d
#		    $s1: Lower 32 bits of vector d
#		    $t0: Upper 32 bits of vector a
#		    $t1: Lower 32 bits of vector a
#		    $t2: Byte number (0-7)
#		    $t3: Temporary
#		    $t4: Holds base address for jump table
#		    $t5: Holds indexed address for jump table
#		    $t6: Temporary
#		    $t7: Loop counter
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
           	addi $t0, $zero, 0x230C124D			
     	   	addi $t1, $zero, 0x057F192A	
     	   	addi $t2, $zero, 5	
     	   
     	   	#Clear storage registers
     	  	addi $s0, $zero, 0	
     	  	addi $s1, $zero, 0	
		
		#Other - loop counter
		addi $t7, $zero, 3

	   #Check if byte number is in range (0-7)
	   
	   	sltiu $t3, $t2, 8		#if $t2 < 0 || $t2 >= 8, out of range
	   	beq   $t3, $zero, exit	
	   
	   #Go to case statement in Jump Table based on byte number
	   
		sll $t3, $t2, 2   		#Multiply byte number by 4 and save in $t3
		la  $t4, JumpTable    		#$t4 gets base addr of jump addr table
		add $t5, $t3, $t4     		#Save JumpTable[byte] addr into $t5
		lw $t5, 0($t5)   		#Load JumpTable[byte] into $t5
		jr $t5   			#Jump to case address	 
			
 	   #Jump table based on byte we are splatting 
		#Byte Number:
		
		#Bytes 0-3 use register $t0.	  
		B0:	srl $t6, $t0, 24	#Isolate byte in lowest position	
			j splat			
		B1:	sll $t6, $t0, 8
			srl $t6, $t6, 24
			j splat	
		B2:	sll $t6, $t0, 16
			srl $t6, $t6, 24
			j splat
		B3:	sll $t6, $t0, 24
			srl $t6, $t6, 24
			j splat	
			
		#Bytes 4-7 use register $t1	 
		B4:	srl $t6, $t1, 24	#Isolate byte in lowest position
			j splat
		B5:	sll $t6, $t1, 8
			srl $t6, $t6, 24
			j splat
		B6:	sll $t6, $t1, 16
			srl $t6, $t6, 24
			j splat
		B7:	sll $t6, $t1, 24
			srl $t6, $t6, 24
			j splat
			
	   #Perform splat in $s0 and $s1. $t6 has isolated byte.
splat:
		add $s0, $s0, $t6		#Shifted to lowest byte. Add to $s0 and $s1
		add $s1, $s1, $t6			
	
cont:	
		sll $t6, $t6, 8			#Shift to 2/3/4 byte and add to $s0 and $s1
		add $s0, $s0, $t6	
		add $s1, $s1, $t6
		addi $t7, $t7, -1		#Decrement counter			
		bne $t7, $zero, cont		#Do this three times	

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
JumpTable:
	   .word B0, B1, B2, B3, B4, B5, B6, B7
	   .text
	   


        
                      
	
