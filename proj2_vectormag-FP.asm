#*************************** SIMD MIPS Enhanced Instructions *****************************
#
# File name:        proj2_vectormag.asm
# Version:          1.0
# Date:             April 10, 2015  
# Programmer:       Cosi Manughian-Peter
#
# Description:      This is an enhanced MIPS instruction that calculates the magnitude
#         of a vector. The magnitude of a vector is the square root of the sum of its
#         squared elements: sqrt( x^2 + y^2 + z^2 + ...). The format for the instruction
#         is as follows:
#
#                        vectormag d, a, b
#
#         where a contains the base address to the vector, b contains the number of
#         elements in the vector (number of dimensions), and d contains the magnitude
#         of the vector (a scalar). The vector a can have an arbitrary 1-8 elements, which means that
#         the vector can be 1-8 words wide or 8-256 bits wide. 
#
#         In this example, we use:
#
#                        vectormag $f4, $s1, $s2
#
# Register usage:  
#         $s1: Holds base address of vectora
#         $s2: Number of elements in the vector (number of dimensions)
#         $t0: Use to compare number of elements with number of loops
#         $f1: Use to get vectora[i]
#         $f2: Temp used to save a vector element
#         $f3: Saves sum of squared elements
#	  $f4: Destination register
#
# Notes:     
#
#******************************************************************************************

           #**********************************************************
           #             M A I N     C O D E S E G M E N T  
           #**********************************************************

           .text                        # main (must be global)
           .globl main

main:       #Initializations
                                           #User will load vector address
            la	 $s1, vectora		   #Get address of vector and store in $s1
                   				
            addi $t4, $zero, 2	   	   #Put values into vector a for testing
            sw   $t4, 0($s1)	
            addi $t4, $zero, 5	   	   #Value 2
            sw   $t4, 4($s1)		
            addi $t4, $zero, 7	   	   #Value 3
            sw   $t4, 8($s1) 

	    addi   $s2, $zero, 3	   #User will set number of elements
            add    $t0, $s2, $zero         #Use number of elements as counter for loop
    	    sub.s  $f3, $f3, $f3	   #Clear $f3 (Can't use $0 for FP add) 
    	    
            #Calculations     
contSqrSum:
            lwc1    $f1, 0($s1)            #Load vectora[i] into $f2
            cvt.s.w $f1, $f1		   #Convert from word to single precision
            mul.s   $f2, $f1, $f1          #Square the element and store it in f2               

            
            add.s  $f3, $f3, $f2           #Add the square to the total sum of squared elements
            addi   $s1, $s1, 4             #Increment vectora index
            addi   $t0, $t0, -1            #Decrement counter
            bne    $t0, $zero, contSqrSum  #Continue until we reached the end of the vector

            sqrt.s $f4, $f3                #Take the square root of the sum of squared elements
                        		   #sqrt( x^2 + y^2 + z^2 + ... )  

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

vectora:   .space 32        #Vector A holds 8 words                
                      
    




