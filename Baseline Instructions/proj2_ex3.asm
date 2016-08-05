#*************************** SIMD MIPS Baseline Instructions *****************************
#
# File name:        vector_mule.asm
# Version:          1.0
# Date:             March 31, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This baseline instruction performs an vector multiply
#		even integer operation. Each element of vector d is the   
#		full-length (16-bit) product of the corresponding high
#		(i.e. even) half-width elements of vector a and vector b.
#		The format is as follows:
#			  	vec_mule d, a, b
#		In this program, we use the following registers:
#		 		vec_mule $s0, $t0, $t2
#		where vector d is $s0 and $s1, vector a is $t0 and $t1,
#		and vector b is $t2 and $t3.
# Register usage:   $s0: Upper 32 bits of vector d
#		    $s1: Lower 32 bits of vector d
#		    $t0: Upper 32 bits of vector a
#		    $t1: Lower 32 bits of vector a
#		    $t2: Upper 32 bits of vector b
#		    $t3: Lower 32 bits of vector b
#		    $t4: Pointer to memory location with label "vectora"
#		    $t5: Pointer to memory location with label "vectorb"
#		    $t6: Used for temporary arithmetic operations
#		    $t7: Used for temporary arithmetic operations
#		    $t8: Used for temporary arithmetic operations
#		    $v0: Vector byte counter
#		    $s2: Used for vector byte multiplication
#		    $s3: Used for vector byte multiplication
# Notes:     
#
#******************************************************************************************

           #**********************************************************
           #             M A I N     C O D E S E G M E N T  
           #**********************************************************

           .text                        # main (must be global)
           .globl main

main:      #Initializations

	   	#Set by user
           	addi $t0, $zero, 0xAEE95AE0			
     	   	addi $t1, $zero, 0xF080CC66	
     	   	addi $t2, $zero, 0x33146170	
     	   	addi $t3, $zero, 0x609888AB	
     	   
     	   	#Clear storage registers
     	  	 addi $s0, $zero, 0	
     	  	 addi $s1, $zero, 0	
     	  	 
     	        #Vector byte counter
     	        addi $v0, $zero, 4
     	   
     	   #Initialize array pointers (to put registers into an array for ease)

		 la $t4, vectora	# Init $t4 to point to memory location with label "vectora"
	   	 la $t5, vectorb	# Init $t5 to point to memory location with label "vectorb"	   	 
	   
	   #Move even bytes from $t0 and $t1 into vector a 
	   
	   	#$t1
	   	sll $t6, $t1, 16		 	
	   	srl $t6, $t6, 24	
	   	sw  $t6, 0($t4)		#Store even byte (#6) of $t1 as a word into vector a
	   	add $t6, $zero, $t1	#Reset $t6 to be original $t1		 	
	   	srl $t6, $t6, 24	   	
	   	sw  $t6, 4($t4)		#Store the other even (#4) byte of $t1 as a word into vector a
	   	
		#$t0
		sll $t6, $t0, 16		 	
	   	srl $t6, $t6, 24	
	   	sw  $t6, 8($t4)		#Store even byte (#2) of $t0 as a word into vector a	
	   	add $t6, $zero, $t0	#Reset $t6 to be original $t0		 	
	   	srl $t6, $t6, 24	   	
	   	sw  $t6, 12($t4)	#Store the other even (#0) byte of $t0 as a word into vector a
	   	
	   #Move even bytes from $t2 and $t3 into vector b 
	   
	   	#$t3
	   	sll $t6, $t3, 16		 	
	   	srl $t6, $t6, 24	
	   	sw  $t6, 0($t5)		#Store even byte (#6) of $t3 as a word into vector a
	   	add $t6, $zero, $t3	#Reset $t6 to be original $t3		 	
	   	srl $t6, $t6, 24	   	
	   	sw  $t6, 4($t5)		#Store the other even (#4) byte of $t3 as a word into vector a
	   	
		#$t2
		sll $t6, $t2, 16		 	
	   	srl $t6, $t6, 24	
	   	sw  $t6, 8($t5)		#Store even byte (#2) of $t2 as a word into vector a	
	   	add $t6, $zero, $t2	#Reset $t6 to be original $t2		 	
	   	srl $t6, $t6, 24	   	
	   	sw  $t6, 12($t5)	#Store the other even (#0) byte of $t2 as a word into vector a
	   	
	   #Multiply even bytes and store in vector d ($s0 and $s1)
	   
cont:	   				#Load vectora[i] and vectorb[i]
	   	lw   $s2, 0($t4)	#Load vectora[i] into $s2
	   	lw   $s3, 0($t5)	#Load vectorb[i] into $s2
	   	mult $s2, $s3		#$LO = $s2*$s3 = vectora[i] * vectorb[i]
	   	mflo $t6		#$t6 = $LO = vectora[i] * vectorb[i]
	   

		sll $t6, $t6, 16  	#if count = 3 or 1
	   				#Make higher 16 bits
	   	andi $t8, $v0, 1	#if count = 4 or 2 (if count&1 == 0, it's even)
	   	bne  $t8, $zero, odd
	   	srl $t6, $t6, 16	#Make lower 16 bits   	
odd:	   	
					#Continuing...	   	
	   	slti $t7, $v0, 3	#if count <= 2 ($v0 < 3)	
	   	bne  $t7, $zero, s0	#true go to s0 (upper 32 bits)
	   	
#s1
	   	add $s1, $s1, $t6	#else count > 2, add (store) to $s1 (lower 32 bits)
	   	addi $t4, $t4, 4	#Increment pointer i for vector a
	    	addi $t5, $t5, 4	#Increment pointer i for vector b
	   	addi $v0, $v0, -1	#Decrement counter	   	
	   	bne  $v0, $zero, cont	#If not done, keep looping
	   	
s0:	   	add $s0, $s0, $t6	#add (store) to $s0
	   	addi $t4, $t4, 4	#Increment pointer i for vector a
	    	addi $t5, $t5, 4	#Increment pointer i for vector b
	   	addi $v0, $v0, -1	#Decrement counter	   	
		bne  $v0, $zero, cont	#If not done, keep looping

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
                                         
vectora:   .space 16			 # Vector A holds 4 words
vectorb:   .space 16			 # Vector B holds 4 words
	   


        
                      
	
