#*************************** SIMD MIPS Baseline Instructions *****************************
#
# File name:        vec_perm.asm
# Version:          1.0
# Date:             April 1, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This baseline instruction performs a vector permute.
#		The "permute" instruction fills the result vector d with elements
#		from either vector a or vector b, depending upon the "element
#		specifier" in vector c. The vector elements can be specified in 
#		any order. The format is as follows:
#				vec_perm d, a, b, c
#		In this program, we use the following registers:
#				vec_perm $s0, $t0, $t2, $t4
#		where vector d is made up of registers $s0 and $s1, and vector
#		a is made up of registers $t0 and $t1. Vector b uses $t2 and
#		$t3, and vector c uses $t4, $t5. All of the vectors are 64 bits wide.
#
# Register usage:   $s0: Upper 32 bits of vector d
#		    $s1: Lower 32 bits of vector d
#		    $s2: Points to array of vector a
#		    $s3: Points to array of vector b
#		    $s4: Points to array of vector d
#		    $s5: Access nibble for vector selection
#		    $s6: Most significant half of element from vector c
#		    $s7: Access nibble for byte selection from vector
#		    $t0: Upper 32 bits of vector a
#		    $t1: Lower 32 bits of vector a
#		    $t2: Upper 32 bits of vector b
#		    $t3: Lower 32 bits of vector b
#		    $t4: Upper 32 bits of vector c
#		    $t5: Lower 32 bits of vector c
#		    $t6: Least significant half of element from vector c
#		    $t7: 1. Access elements in registers $t0, $t1, $t2, $t3
#			 2. Byte counter
#			 3. Holds element to move into vector d
#		    $v0: 1. Holds element to move into array of vector a or 
#			    array of vector b
#			 2. Index of vector d
#		    $v1: 1. Boolean that is set when byte count is less than 5
#		  	 2. Vector d array index
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
           	addi $t0, $zero, 0xA567013D	#Vector a		
     	   	addi $t1, $zero, 0xAB45393C
     	   	addi $t2, $zero, 0xEFC54D23	#Vector b		
     	   	addi $t3, $zero, 0x1277AACD			
      	   	addi $t4, $zero, 0x04171002	#Vector c		
     	   	addi $t5, $zero, 0x13050105
     	   	    	   
     	   	#Clear storage registers
     	  	addi $s0, $zero, 0		#Vector d
     	  	addi $s1, $zero, 0
     	  	
     	  	#Other
     	  	addi $s5, $zero, 0xF0000000	#To get nibble for vector selection
     	  	addi $s7, $zero, 0x0F000000	#To get nibble for byte selection in vector
     	  	
     	  	
     	  	
	   #Initialize array pointers (to put registers into an array for ease)

		la $s2, vectora	# Init $s2 to point to memory location with label "vectora"
	   	la $s3, vectorb	# Init $s3 to point to memory location with label "vectorb"
	   	la $s4, vectord	# Init $s4 to point to memory location with label "vectord"   	 
	
	   #Put register data from $t0 and $t1 into vector a array
	   #(Each byte is an element)
	   
	   	addi $t7, $zero, 0xFF000000	#Set to access leftmost element
	   					#in register $t0
     	  	addi $t9, $zero, 24		#Shift amount
     	   #Move $t0 into vector a array	
init1:	   	and $v0, $t0, $t7		#Get element
	   	srlv $v0, $v0, $t9		#Shift element all the way to the right
	   					#to make element moving easier
	   	sw $v0, 0($s2)			#Store element into vector a array
	   	addi $s2, $s2, 4		#Move to next index of array
	   	srl $t7, $t7, 8			#Access next element in register $t0
	   	addi $t9, $t9, -8 		#Decrement shift amount by 8
	   	bne $t9, -8, init1		#Loop back up to keep moving elements into array
	   	
	   	addi $t7, $zero, 0xFF000000	#Reinitialize to access leftmost element
	   					#in register $t1
     	  	addi $t9, $zero, 24		#Reinitialize shift amount
	   #Move $t1 into vector a array	
init2:	   	and $v0, $t1, $t7		#Get element
	   	srlv $v0, $v0, $t9		#Shift element all the way to the right
	   					#to make element moving easier
	   	sw $v0, 0($s2)			#Store element into vector a array
	   	addi $s2, $s2, 4		#Move to next index of array
	   	srl $t7, $t7, 8			#Access next element in register $t1
	   	addi $t9, $t9, -8 		#Decrement shift amount by 8
	   	bne $t9, -8, init2		#Loop back up to keep moving elements into array
	   	
	   	subi $s2, $s2, 32		#Reset to point to memory location 
	   					#with label "vectora"
	   	
	   	 
	   
	   #Put register data from $t2 and $t3 into vector b array
	   #(Each byte is an element)
	   
	   	addi $t7, $zero, 0xFF000000	#Reinitialize to access leftmost element
	   					#in register $t2
     	  	addi $t9, $zero, 24		#Reinitialize shift amount
     	  	#Move $t2 into vector b array		   	
init3:	   	and $v0, $t2, $t7		#Get element
	   	srlv $v0, $v0, $t9		#Shift element all the way to the right
	   					#to make element moving easier
	   	sw $v0, 0($s3)			#Store element into vector b array
	   	addi $s3, $s3, 4		#Move to next index of array
	   	srl $t7, $t7, 8			#Access next element in register $t2
	   	addi $t9, $t9, -8 		#Decrement shift amount by 8
	   	bne $t9, -8, init3		#Loop back up to keep moving elements into array
	   	
	   	addi $t7, $zero, 0xFF000000	#Reinitialize to access leftmost element
	   					#in register $t3
     	  	addi $t9, $zero, 24		#Reinitialize shift amount
	   	#Move $t3 into vector b array
init4:	   	and $v0, $t3, $t7		#Get element
	   	srlv $v0, $v0, $t9		#Shift element all the way to the right
	   					#to make element moving easier
	   	sw $v0, 0($s3)			#Store element into vector b array
	   	addi $s3, $s3, 4		#Move to next index of array
	   	srl $t7, $t7, 8			#Access next element in register $t3
	   	addi $t9, $t9, -8 		#Decrement shift amount by 8
	   	bne $t9, -8, init4		#Loop back up to keep moving elements into array
	   	
	   	subi $s3, $s3, 32		#Reset to point to memory location 
	   					#with label "vectorb"
	 
	   	#Reinitialize for different use
	   	addi $v0, $zero, 0		#Use to index vector d
     	  	addi $t6, $zero, 0		#To hold nibble for byte selection
     	  	addi $t7, $zero, 8		#Byte count
     	  	addi $t9, $zero, 24  	  	#Shift amount for correct place value
	   	
	   #Check which vector to get the element from
	    
loop:	   	slti $v1, $t7, 5	# If byte count < 5 
		bne $v1, $zero, ltf	# go to ltf (less than five)
		beq $v1, $zero, gtf	# else go to gtf (greater than five)
		
	ltf:				#Use $t5 of vector c since byte count < 5
		and $s6, $s5, $t5	#Get vector bits (0 or 1)
					#$s5 specifies the (left) nibble to access
					#$t5 is the right-most 32 bits of vector c
		
		
		and $t6, $s7, $t5	#Get byte selection
					#$s7 specifies the (right) nibble to access
					#$t5 is the right-most 32 bits of vector c	
		j cont
		
	gtf:				#Use $t4 of vector c since byte count < 5
		and $s6, $s5, $t4	#Get vector bits (0 or 1)
					#$s5 specifies the (left) nibble to access
					#$t4 is the left-most 32 bits of vector c
		
		
		and $t6, $s7, $t4	#Get byte selection
					#$s7 specifies the (right) nibble to access
					#$t4 is the left-most 32 bits of vector c	
	cont:
		srl $s5, $s5, 8		#Shift for next nibble for vector selection
		srl $s7, $s7, 8		#Shift for next nibble for byte selection
		
		
		xor $v1, $t7, 4 		#if count != 3 (We're not on byte 3)
		bne $v1, $zero, skipReset 	#go to skipReset
		
		addi $s5, $zero, 0xF0000000	#else we're on byte 3, so reset the
		addi $s7, $zero, 0x0F000000	# vector and byte selection masking registers
		addi $t9, $zero, 24		#Reset shift amount
		and $s6, $s5, $t5	#Get vector bits (0 or 1)
					#$s5 specifies the (left) nibble to access
					#$t5 is the right-most 32 bits of vector c
		
		
		and $t6, $s7, $t5	#Get byte selection
					#$s7 specifies the (right) nibble to access
					#$t5 is the right-most 32 bits of vector c
		srl $s5, $s5, 8		#Shift for next nibble for vector selection
		srl $s7, $s7, 8		#Shift for next nibble for byte selection				
		
     	skipReset:  	
     		beq $s6, $zero, useVectorA	#if low nibble for vector selection == 0
     						# 0: use vector a
     		bne $s6, $zero, useVectorB	# 1: use vector b
     	
     	#Get element from vector a	
     	useVectorA:
     	
		
		srlv $t6, $t6, $t9	#Shift to correct place value
		sll $t6, $t6, 2		#t6 is used to hold nibble for byte selection
     	  				#Multiply it by 4 to use as index for vectora array
     	  	add $t8, $t6, $s2	#Add offset to base address of vector a. Put in $t8.
     	  	lw $t8, 0($t8)		#Load vector a element and store in $t8
     	  	add $t6, $s4, $v0	#Add vector d index, $v0, to vector d base addr, $s4
     	  	sw $t8, 0($t6)		#Store the vector a element into indexed vector d
     	  	addi $v0, $v0, 4	#Increment vector d index
     		
     		j skipVectorB
     	
     	#Get element from vector b	
     	useVectorB:
 
		srlv $t6, $t6, $t9	#Shift to correct place value
     	     	sll $t6, $t6, 2		#t6 is used to hold nibble for byte selection
     	  				#Multiply it by 4 to use as index for vectorb array
     	  	add $t8, $t6, $s3	#Add offset to base address of vector b. Put in $t8.
     	  	lw $t8, 0($t8)		#Load vector b element and store in $t8
     	  	add $t6, $s4, $v0	#Add vector d index, $v0, to vector d base addr, $s4
     	  	sw $t8, 0($t6)		#Store the vector b element into indexed vector d
     	  	addi $v0, $v0, 4	#Increment vector d index
     	
     	skipVectorB:	
     	
		addi $t7, $t7, -1	#Decrement counter
		addi $t9, $t9, -8	#Decrement shift amount
		bne $t7, $zero, loop	#Keep looping
	  	
	#Put vectord array elements into destination ($s0 and $s1)
		
		#Put the first four elements into $s0
		addi $t9, $zero, 4		#$t9 is the counter
		addi  $v1, $s4, 0		#$s4 has base addr of vector d
		addi $t6, $zero, 24		#Reinitialize to use as shift amount
		
	first4Loop:
		lw $t7, 0($v1)			#Load vector d array element into $t7			
		sllv $t7, $t7, $t6		#Shift element to proper place
		add $s0, $s0, $t7		#Put into destination
		addi $v1, $v1, 4		#Increment index
		addi $t9, $t9, -1		#Decrement counter
		addi $t6, $t6, -8		#Decrement shift amount
		bne $t9, $zero, first4Loop	#Keep looping
		
		#Put the last four elements into $s1
	 	addi $t9, $zero, 4		#$t9 is the counter - reset it
						#Use same $v1
		addi $t6, $zero, 24		#Reinitialize shift amount			
	second4Loop:
		lw $t7, 0($v1)			#Load vector d array element into $t7			
		sllv $t7, $t7, $t6		#Shift element to proper place
		add $s1, $s1, $t7		#Put into destination
		addi $v1, $v1, 4		#Increment index
		addi $t9, $t9, -1		#Decrement counter
		addi $t6, $t6, -8		#Decrement counter
		bne $t9, $zero, second4Loop	#Keep looping
	 	 	
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

vectora:   .space 32			 # Vector A holds 8 words	   
vectorb:   .space 32			 # Vector B holds 8 words
vectord:   .space 32			 # Vector D holds 8 words


        
                      
	
