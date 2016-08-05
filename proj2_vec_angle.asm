#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:        vec_angle.asm
# Version:          1.0
# Date:             April 22, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This enhanced instruction finds the angle between two vectors in
#		    radians. The format is as follows:
#				vec_angle d, a, b
#
#		    In this program, we use the following registers:
#				vec_angle $f0, $t0, $t1
#
#		    where d is the resulting angle, a is the address of vector a, and 
#		    b is the address of vector b. Vector a has eight 8-bit elements,
#		    and vector b has eight 8-bit elements. 
#
#		    To find the angle, theta, we have the formula:
#
#				cos(theta) = a dot b / magnitude(a)*magnitude(b)
#				   (theta) = inverse_cos( 
#						a dot b / magnitude(a)*magnitude(b) )
# 
# Register usage: 
#		    $t0: Base address of vector a
#		    $t1: Base address of vector b
#		    $t2: Use to store values in vectors
#		    $t3: Loop count
#		    $f0: Resulting angle
#		    $f1: Magntiude of vector a
#		    $f2: Magntiude of vector b
#		    $f3: Magntiude of vector b * magntiude of vector a
#		    $f4: Result of vec_msums 
#		    $f5: dot product / magnitude a * magntiude b 
#		    $f6: pi/2
#		    $f7: x^3
#		    $f8: For inverse cosine operations
#		    $f9: For inverse cosine operations
# Notes:     
#
#******************************************************************************************

           #**********************************************************
           #             M A I N     C O D E S E G M E N T  
           #**********************************************************

           .text                       		# main (must be global)
           .globl main

main:      # Initializations

	   	# Set by user
	   	la $t0, vectora			# Base address of vector a
	   	la $t1, vectorb 		# Base address of vector b
	   	
	   	# Clear registers
	   	addi $t3, $zero, 0
	   	addi $t2, $zero, 0
	   	
	   	# Put values into a and b for testing
	   	# Vector a:
	   	addi $t3, $t3, 0x8		# Stop at 8 elements
	 initA:
		addi $t2, $t2, 0x1		# Create value to store in a
		sb   $t2, 0($t0)		# Store 0x1*i in a[i]
		addi $t0, $t0, 1		# Increment pointer
		bne  $t2, $t3, initA		# Loop until we have 8 elements 0x1-0x8
		
	   	# Vector b:	   	
	   	addi $t3, $zero, 0		# Reset registers
	   	addi $t2, $zero, 0x2		# Make this one start at 0x2
	   	addi $t3, $t3, 0xA		# Stop at 8 elements
	 initB:
		addi $t2, $t2, 0x1		# Create value to store in a
		sb   $t2, 0($t1)		# Store 2+0x1*i in b[i]
		addi $t1, $t1, 1		# Increment pointer
		bne  $t2, $t3, initB		# Loop until we have 8 elements 0x1-0x8
			
									
	   # Formula: theta = inverse_cos( a dot b / mag(a)*mag(b) )

	   # Do a vector multiply and add to get the dot product of a and b
	   # (Use vec_msums instruction)
	   # Calculated using vec_msums
		l.s 	$f4, dot		# Get vec_msums result ( 0x114 = 276d )
						# Put dot product in an fp register
		
	   # Find the magnitude of a and the magnitude of b
	   # (Use vectormag instruction)
		l.s   $f1, magA			# Put vectormag result for vector a in $f1		
						# Magntiude_a = 14.28286
	   
		l.s   $f2, magB			# Put vectormag result for vector b in $f2		
						# Magntiude_b = 19.49359
	
	
	   # Multiply the magnitudes together
		mul.s $f3, $f1, $f2		# Magnitude b * Magnitude a

	   # Divide the dot product by the magnitude
		div.s $f5, $f4, $f3		# Rounded answer should be
						# dot_product / magA*magB = 0.9896
		
	   # Calculate the inverse cosine of the result using Taylor series

	   # Approximate:
	   # theta = inverse_cos( x ) = pi/2 - [ x + x^3/6 + 3x^5/40 + ... ], |x| < 1
	   #
	   #	Here, x = dot_product / magA*magB = 0.9896
	   #
	   	l.s   $f6, piDiv2		# Get pi/2
	   		
	   # First calculate x + x^3/6 + 3x^5/40, x = $f5 = 0.9896 < 1
	   # Answer should be 1.22
	   
	    	# Cube x
	    	mul.s $f7, $f5, $f5		# x*x
	    	mul.s $f7, $f7, $f5		# x*x*x 
	    	
	    	# Divide by 6
	    	l.s   $f8, six			# Put 6 into $f8
	    	div.s $f8, $f7, $f8		# $f8 = x^3/6
	    	
	    	# Calculate x^5
	    	mul.s $f7, $f7, $f5		# $f7 = x^3 * x = x^4
	    	mul.s $f7, $f7, $f5		# $f7 = x^4 * x = x^5
	    	
	    	# Multiply by 3
	    	l.s   $f9, three
	    	mul.s $f7, $f7, $f9		# $f7 = 3*x^5
	    	
	    	#Divide by 40
	    	l.s   $f9, fourty
	    	div.s $f7, $f7, $f9		# $f7 = 3*x^5/40
	    	
	    	#Sum x + x^3/6 + 3x^5/40 
	    	add.s $f8, $f8, $f7		# $f8 = $f7 + $f8 = x^3/6 + 3*x^5/40
	    	add.s $f5, $f8, $f5		# $f5 = $f8 + $f5 = x + x^3/6 + 3x^5/40 

	   # Now subtract the sum from pi/2
	   # Answer should be pi/2 = 1.22 = 1.6 - 1.22 = 0.38
		sub.s $f0, $f6, $f5		# $f0 =  pi/2 - [ x + x^3/6 + 3x^5/40 + ... ]

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

vectora:   	.space 8		 #Vector A holds 8 bytes	   
vectorb:   	.space 8		 #Vector B holds 8 bytes
magA: 		.float 14.3		 #Magnitude of vector a using vectormag
magB:		.float 19.5              #Magnitude of vector b using vectormag  
dot:		.float 276		 #Calculated dot product of vectors	
piDiv2:		.float 1.6		 # pi/2 = 3.14/2 = 1.57 = 1.6	
six:		.float 6		 #For inv_cos operations
fourty:		.float 40		 #For inv_cos operations
three:		.float 3		 #For inv_cos operations