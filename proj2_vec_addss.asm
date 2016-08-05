#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:        vec_addss.asm
# Version:          1.0
# Date:             April 13, 2015  
# Programmer:       Nancy Torres
#
# Description:      This enhanced instruction performs a vector add saturated signed. Each
#		    element of vector a is added to the corresponding element of vector b.
#		    The signed integer (no-wrap) is placed into the corresponding element of 
#  		    vector d. The format is as follows:
#				vec_addss d, a, b
#		    In this program, we use the following registers:
#				vec_addss $s0, $t0, $t2
#		    where vector d is made up of registers $s0 and $s1, vector a is made up
#		    of registers $t0 and $t1 and vector b uses $t2 and $t3. All of the 
#		    vectors are 64 bits wide.
#
# Register usage:   $s0: Upper 32 bits of vector d
#		    $s1: Lower 32 bits of vector d
#		    $s2: Points to array of vector a
#		    $s3: Points to array of vector b
#		    $s4: Points to array of sums from vector a and vector b
#		    $s5: Amount to shift elements to correct place in $s0 and $s1
#		    $s6: Holds 8-bit element from vector a
#		    $t0: Upper 32 bits of vector a
#		    $t1: Lower 32 bits of vector a
#		    $t2: Upper 32 bits of vector b
#		    $t4: Boolean that is false if we need to saturate to highest value
#			 and true if we need to saturate to lowest value
#		    $t3: Lower 32 bits of vector b
#		    $t5: 1. Boolean that is set to true if signs from elements of vector 
#		   	    a and vector b are different
#			 2. Boolean that is set to true if signs from elements of vector
#			    a, vector b, and their sum are different
#		    $t6: Holds 8-bit element from vector b
#		    $t7: 1. Access elements in registers $t0, $t1, $t2, $t3
#			 2. Byte counter
#			 3. Holds element to move into vector d
#		    $v0: 1. Holds element to move into array of vector a or 
#			    array of vector b
#			 2. Sum of elements from vectors a and b
#		    $v1: Boolean that is set to true when destination is changed to $s1
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
           	addi $t0, $zero, 0x8067013D	#Vector a		
     	   	addi $t1, $zero, 0xAB45803C
     	   	addi $t2, $zero, 0x013BB3DD	#Vector b		
     	   	addi $t3, $zero, 0xEE89FF33			

     	   	    	   
     	   	#Clear storage registers
     	  	addi $s0, $zero, 0		#Vector d
     	  	addi $s1, $zero, 0
     	  	
     	  	#Clear registers that hold element
     	  	addi $s6, $zero, 0		#To hold byte from vector a
     	  	addi $t6, $zero, 0		#To hold byte from vector b
     	  	
     	  	     	  	     	  	
	   #Initialize array pointers (to put registers into an array for ease)

		la $s2, vectora	# Init $s2 to point to memory location with label "vectora"
	   	la $s3, vectorb	# Init $s3 to point to memory location with label "vectorb"
	   	la $s4, vectorsums # Init $s4 to point to memory location with label "vectorsums"
	   	 	 
	
	   #Put register data from $t0 and $t1 into vector a array
	   #(Each byte is an element)
	   
	   	addi $t7, $zero, 0xFF000000	#Set to access leftmost element
	   					#in register $t0
     	  	add $t9, $zero, $zero		#Shift amount
     	   #Move $t0 into vector a array	
init1:	   	and $v0, $t0, $t7		#Get element
	   	sllv $v0, $v0, $t9		#Shift element all the way to the left
	   					#to make calculations easier
	   	sw $v0, 0($s2)			#Store element into vector a array
	   	addi $s2, $s2, 4		#Move to next index of array
	   	srl $t7, $t7, 8			#Access next element in register $t0
	   	addi $t9, $t9, 8 		#Increment shift amount by 8
	   	bne $t9, 32, init1		#Loop back up to keep moving elements into array
	   	
	   	addi $t7, $zero, 0xFF000000	#Reinitialize to access leftmost element
	   					#in register $t1
     	  	add $t9, $zero, $zero		#Reinitialize shift amount
	   #Move $t1 into vector a array	
init2:	   	and $v0, $t1, $t7		#Get element
	   	sllv $v0, $v0, $t9		#Shift element all the way to the left
	   					#to make calculations easier
	   	sw $v0, 0($s2)			#Store element into vector a array
	   	addi $s2, $s2, 4		#Move to next index of array
	   	srl $t7, $t7, 8			#Access next element in register $t1
	   	addi $t9, $t9, 8 		#Increment shift amount by 8
	   	bne $t9, 32, init2		#Loop back up to keep moving elements into array
	   	
	   	subi $s2, $s2, 32		#Reset to point to memory location 
	   					#with label "vectora"
	   	
	   	 
	   
	   #Put register data from $t2 and $t3 into vector b array
	   #(Each byte is an element)
	   
	   	addi $t7, $zero, 0xFF000000	#Reinitialize to access leftmost element
	   					#in register $t2
     	  	add $t9, $zero, $zero		#Reinitialize shift amount
     	  	#Move $t2 into vector b array		   	
init3:	   	and $v0, $t2, $t7		#Get element
	   	sllv $v0, $v0, $t9		#Shift element all the way to the left
	   					#to make calculations easier
	   	sw $v0, 0($s3)			#Store element into vector b array
	   	addi $s3, $s3, 4		#Move to next index of array
	   	srl $t7, $t7, 8			#Access next element in register $t2
	   	addi $t9, $t9, 8 		#Increment shift amount by 8
	   	bne $t9, 32, init3		#Loop back up to keep moving elements into array
	   	
	   	addi $t7, $zero, 0xFF000000	#Reinitialize to access leftmost element
	   					#in register $t3
     	  	add $t9, $zero, $zero		#Reinitialize shift amount
	   	#Move $t3 into vector b array
init4:	   	and $v0, $t3, $t7		#Get element
	   	sllv $v0, $v0, $t9		#Shift element all the way to the left
	   					#to make calculations easier
	   	sw $v0, 0($s3)			#Store element into vector b array
	   	addi $s3, $s3, 4		#Move to next index of array
	   	srl $t7, $t7, 8			#Access next element in register $t3
	   	addi $t9, $t9, 8 		#Increment shift amount by 8
	   	bne $t9, 32, init4		#Loop back up to keep moving elements into array
	   	
	   	subi $s3, $s3, 32		#Reset to point to memory location 
	   					#with label "vectorb"
	 	
	   	#Reinitialize for different use
	   	addi $v0, $zero, 0		#Use to index vector sums
     	  	addi $t7, $zero, 8		#Byte count
     	  	addi $t9, $zero, 24  	  	#Shift amount for correct place value
	   	
	   #Check which vector to get the element from
	    
loop:	   	lw $s6, 0($s2)			#Load vector a array element into $s6
		lw $t6, 0($s3)			#Load vector b array element into $t6
		addu $v0, $s6, $t6		#Add elements from vectors a and b
		sw $v0, 0($s4)			#Store sum into vector sums array
		addi $s2, $s2, 4		#Go to the next element of array a
		addi $s3, $s3, 4		#Go to the next element of array b
		addi $s4, $s4, 4		#Go to the next element of array sums	
		addi $t7, $t7, -1		#Decrement counter
		bne $t7, $zero, loop		# Keep looping if counter not equal to 0
		subi $s2, $s2, 32		#Reset to point to memory location 
	   					#with label "vectora"
		subi $s3, $s3, 32		#Reset to point to memory location 
	   					#with label "vectorb"
		subi $s4, $s4, 32		#Reset to point to memory location 
	   					#with label "vectorsums"
	
		
	#Put vectorsums array elements into destination ($s0 and $s1)
		
		#Put the first four elements into $s0
		addi $t9, $zero, 4		#$t9 is the counter
		addi $s5, $zero, 0		#Initialize to use as shift amount
		addi $v1, $zero, 0		#Destination register is $s0
						#Set boolean to false
		
	first4Loop:
		lw $t7, 0($s4)			#Load vector sums array element into $t7
		lw $s6, 0($s2)			#Load vector a array element into $s6
		lw $t6, 0($s3)			#Load vector b array element into $t6
		xor $t5, $s6, $t6		#Check if signs differ
		slt $t5, $t5, $zero		#Set $t5 to 1 if signs differ
		bne $t5, $zero, cont1		#No overflow if signs of $s6 and $t6
						#are not equal
		xor $t5, $t7, $s6		#Here the signs are equal, so check if
						#the sign of sum is equal too
		slt $t4, $s6, $zero		#set to true if we might need to saturate to highest 
						#value or false if we might need to saturate to lowest value				
						#$t5 is negative if sum sign is different
		slt $t5, $t5, $zero		#$t5 is set to 1 if sum sign is different
		bne $t5, $zero, overflow 	#Go to overflow if all 3 signs not equal
cont1:			
		srlv $t7, $t7, $s5		#Shift element to proper place
		add $s0, $s0, $t7		#Put into destination
		addi $s2, $s2, 4		#Increment index
		addi $s3, $s3, 4		#Increment index
		addi $s4, $s4, 4		#Increment index
		addi $t9, $t9, -1		#Decrement counter
		addi $s5, $s5, 8		#Increment shift amount
		bne $t9, $zero, first4Loop	#Keep looping
		
		#Put the last four elements into $s1
	 	addi $t9, $zero, 4		#$t9 is the counter - reset it
		addi $s5, $zero, 0		#Reinitialize shift amount
		addi $v1, $v1, 1		#Destination register is now $s1
						#Set boolean to true
					
	second4Loop:
		lw $t7, 0($s4)			#Load vector sums array element into $t7
		lw $s6, 0($s2)			#Load vector a array element into $s6
		lw $t6, 0($s3)			#Load vector b array element into $t6
		xor $t5, $s6, $t6		#Check if signs differ
		slt $t5, $t5, $zero		#Set $t5 to 1 if signs differ
		bne $t5, $zero, cont2		#No overflow if signs of $s6 and $t6
						#are not equal
		xor $t5, $t7, $s6		#Here the signs are equal, so check if
						#the sign of sum is equal too
		slt $t4, $s6, $zero		#set to true if we might need to saturate to highest 
						#value or false if we might need to saturate to lowest value				
						#$t5 is negative if sum sign is different
		slt $t5, $t5, $zero		#$t5 is set to 1 if sum sign is different
		bne $t5, $zero, overflow 	#Go to overflow if all 3 signs not equal
cont2:					
		srlv $t7, $t7, $s5		#Shift element to proper place
		add $s1, $s1, $t7		#Put into destination
		addi $s2, $s2, 4		#Increment index
		addi $s3, $s3, 4		#Increment index
		addi $s4, $s4, 4		#Increment index
		addi $t9, $t9, -1		#Decrement counter
		addi $s5, $s5, 8		#Increment shift amount
		bne $t9, $zero, second4Loop	#Keep looping
	 	 
	 	j exit		
	 	 	
overflow:	beq $t4, $zero, sathighest
		add $t7, $zero,0x80000000	#We overflowed so saturate 1 byte integer (lowest)
sathighest:	bne $t4, $zero, satlowest
		add $t7, $zero,0x7F000000	#We overflowed so saturate 1 byte integer (highest)
satlowest:		
		bne $v1, $zero, skip		#If boolean set to true (If the destination 
						#register is $s1) skip and jump to cont2
		j cont1				#Boolean is false here so jump to cont1
	skip: 	j cont2 		 	#jump to cont2	 	
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
                                         #   constants, etc. in this area

vectora:   	.space 32		 # Vector A holds 8 words	   
vectorb:   	.space 32		 # Vector B holds 8 words
vectorsums:	.space 32		 # Vector Sums holds 8 words


        
                      
	
