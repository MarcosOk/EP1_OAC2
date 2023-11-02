.data     
  #Function 1 - Read txt.
  xtrain_txt:   .asciiz "xtrain.txt" 
  xtrain_array: .space 18000 # Array characters 
  
  ytrain_txt:   .asciiz "ytrain.txt" 
  ytrain_array: .space 18000 # Array characters 
  
  #Function 2 - Get User Input
  str_num: .asciiz "Quantos numeros deseja inserir? (maximo 200)\n"
  user_input: .word 0   # variable to user's input 	 	
  check_input_msg: .asciiz "You entered: "

  #Function 3 - Convert to Float
  xtrain_array_float:   .align 2
  	     .space 6400    # Array floats  		
  partial_string:       .space 15

  float_constant:       .float 0.0     # Initialize a float constant
  float_ten:            .float 10.0    # Declare a float constant
  float_hundred:        .float 100.0   # Declare a float constant
  float_thousand:       .float 1000.0  # Declare a float constant
  
  xtrain_array:         .asciiz "123.12,88,58,11,54,24.8,0.267,22"
  
  count_decimal_digits: .word 0   # quantify how many digits AFTER the period ('.')  
  index_of_period:      .word 0   

.text
.globl main

main:
  jal get_user_input
  
  jal read_xtrain 
  
  jal read_ytrain     

  # Exit the program
  li $v0, 10        # syscall 10 (exit)
  syscall

########################### FUNCTIONS ##########################

####### 1) FUNCTION - READ FILES
####### 1.1) READ xtrain.txt 
read_xtrain: 
  li $v0, 13       # syscall 13 (open file)
  la $a0, xtrain_txt # Load the xtrain_txt
  li $a1, 0        # Read-only mode
  li $a2, 0        # File permissions (ignored)
  syscall
  
  move $s0, $v0
 
  li $v0, 14        # syscall 14 (read file)
  move $a0, $s0      # file descriptor 

  la $a1, xtrain_array   
  li $a2, 18000
  syscall

  # Null-terminate the copied string  
  addi $t0, $a1, 18000
  sb $zero, ($t0)       # Null-terminate at the end
  
  ############ TESTE ##################		
  # Print the copied content
  #li $v0, 4         # syscall 4 (print string)
  #la $a0, xtrain_array # Load the string to print
  #syscall
  
  # Close the file
  li $v0, 16        # syscall 16 (close file)
  syscall		

  jr $ra	
  
####### 1.2) READ ytrain.txt 
read_ytrain: 
  li $v0, 13       # syscall 13 (open file)
  la $a0, ytrain_txt 
  li $a1, 0        # Read-only mode
  li $a2, 0        # File permissions (ignored)
  syscall
  
  move $s0, $v0
 
  li $v0, 14        # syscall 14 (read file)
  move $a0, $s0      # file descriptor 

  la $a1, ytrain_array  
  li $a2, 18000
  syscall

  # Null-terminate the copied string  
  addi $t0, $a1, 18000
  sb $zero, ($t0)       # Null-terminate at the end
  
  ############ TESTE ##################		
  # Print the copied content
  #li $v0, 4         # syscall 4 (print string)
  #la $a0, ytrain_array  # Load the string to print
  #syscall
  
  # Close the file
  li $v0, 16        # syscall 16 (close file)
  syscall		

  jr $ra

####### 2) FUNCTION - GET USER INPUT

get_user_input:
  la $a0, str_num # print 'str_num'
  li $v0, 4
  syscall
    
  li $v0, 5  # read an integer from the user
  syscall  
  
  sw $v0, user_input # Store the result
  
  # Display a message to check the user's input
  la $a0, check_input_msg
  li $v0, 4  
  syscall 
  
  lw $a0, user_input  # Load the user's input from the variable
  li $v0, 1
  syscall
  
  jr $ra  

####### FUNCTION 3) CONVERT TO FLOAT #######################################################################################
convert_to_float:
  # Initialize variables
  li $t0, 0                                  # Loop counter for 'convert_to_float'
  li $t1, 0                                  # Index 'xtrain_array[]'  
  li $t2, 0                                  # Index 'partial_string[]'
  li $t3, 0                                  # Store each char
  li $t4, 0                                  # Store ASCII code
  li $t5, 0                                  # Store ASCII code  
  lw $a0, user_input                         # User input
  
  # 3.1) CREATE PARTIAL STRING              
  # Loop to create 'partial_string' array 	
  loop_get_chars_to_partial_string:          # Loop to create 'partial_string' array
     
   lb $t3, xtrain_array($t1)                 # Load a character from xtrain_array   
   
   # Checks I - end of number                  
   beq $t3, 0x2C, format_partial_string      # Check: comma (',') 
   beq $t3, 0x00, format_partial_string      # Check: null-terminator ('\0')
   beq $t3, 0xA, format_partial_string       # Check:  new-line  ('\n')
     
   # Checks II - not decimal
   li $t4, 48                                # ASCII code for '0'
   blt $t3, $t4, check_period                # check: if character is less than '0'   
   li $t5, 57                                # ASCII code for '9'
   bgt $t3, $t5, check_period                # Check: if character is greater than '9'
   
   # Checks III - period
   check_period:
    li $t4, 46                                # ASCII code for a period ('.')
    beq $t3, $t4, decimal_or_period 
  
   # At this point is a 'decimal' or 'period'
   decimal_or_period:
   sb $t3, partial_string($t2)               # Add character to partial_string
   addi $t1, $t1, 1                          # Increment 'xtrain_array[index]'
   addi $t2, $t2, 1                          # Increment 'partial_string[index]'
   j loop_get_chars_to_partial_string  
                        
   format_partial_string:
   # Null-terminate the partial_string   
   sb $zero, partial_string($t2)
   
   # decrement the index to point 
   # to the number before the 'null-terminate' 
   # added in the previous line               
   subi $t2, $t2, 1                                  
   
   addi $t1, $t1, 1                          # Increment index of 'xtrain_array[]' for next loop of convert_to_float                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
   
   # clean registers	     
   move $t3, $zero                           # Clean last char
   move $t4, $zero
   move $t5, $zero 
      
   j process_partial_string	

# 3.2) CONVERT 'partial_string' TO FLOAT  ######################################################### 
  
  process_partial_string:    
   # Initialize variables    
   li $t3, 0
   li $t5, 0
   li $t6, 0  
   li $t7, 0                                     # Index for 'adjust_format_float'
   li $t8, 0
   li $t9, 46                                    # ASCII code for period ('.') 
   l.s $f2, float_constant 
   add.s $f0, $f0, $f2
        
   add $t6, $t6, $t2                              # Copy index of partial_string[] from $t2   
   
   #check if it has a decimal part - iterate until it finds a period '.'
   check_decimal_part:                                                  
    lb $t8, partial_string($t6)
   
    li $t4, 46                                                  # ASCII code for a period ('.')
    beq $t8, $t4, decimal_part_create_float                     # If true has a decimal part  
   
    subi $t6, $t6, 1                                            # Decrement index      
    blt $t6, $zero integer_part_create_float_NO_decimals        # Avoid invalid index number 
    j check_decimal_part     
     
   
   # 3.2.1) Create decimal part of float	
   # check how many decimal digits   

   decimal_part_create_float:    
   sub $t8, $t2, $t6                              # Total_Decimal_Digits = (index of last number - index of the period) 
   la $a0, index_of_period                        # save the index position of the period 
   sw $t6, 0($a0)
      
   la $a0, count_decimal_digits                   # save the count in the variable      
   sw $t8, 0($a0)    
   
   # Divide by 10  
   addi $t6, $t6, 1                               # index for the first decimal digit
      
   lb $t3, partial_string($t6)                    # get first decimal digit    
   sub $t3, $t3, 48                               # convert decimal digit in ASCII to integer    
   mtc1 $t3, $f1     	            # Move integer to float register
   cvt.s.w $f1, $f1                               # Convert to float   
       
   l.s $f2, float_ten                            	
   div.s $f1, $f1, $f2                
   add.s $f0, $f0, $f1                            # Sum with the final register -$f0 will store the final float   
         
   # Check if there is more decimal digits to convert
   subi $t8, $t8, 1
   beqz $t8, integer_part_create_float_WITH_decimals
         
               
   # Divide by 100   
   addi $t6, $t6, 1                               # index for the second decimal digit
   lb $t5, partial_string($t6)                     
   sub $t5, $t5, 48                               # Convert decimal digit in ASCII to integer    
   mtc1 $t5, $f1     	            # Move integer to float register
   cvt.s.w $f1, $f1                               # Convert to float                                                                                                          
   
   l.s $f2, float_hundred                               	
   div.s $f1, $f1, $f2                  
   add.s $f0, $f0, $f1
   
   # Check if there is more decimal digits to convert
   subi $t8, $t8, 1
   beqz $t8, integer_part_create_float_WITH_decimals
   
   
   # Divide by 1000  
   addi $t6, $t6, 1                               # index for the third decimal digit
   lb $t5, partial_string($t6)                     
   sub $t5, $t5, 48                               # Convert decimal digit in ASCII to integer    
   mtc1 $t5, $f1     	            # Move integer to float register
   cvt.s.w $f1, $f1                               # Convert to float                                                                                                          
   
   l.s $f2, float_thousand                              	
   div.s $f1, $f1, $f2                  
   add.s $f0, $f0, $f1                                                                                                                                                                                                                                                                                              
  
   j integer_part_create_float_WITH_decimals  
   
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
   # 3.2.2) Create integer part of float                                                                        
   integer_part_create_float_NO_decimals:        # $t2 + 1 = total number of integer digits
   add $t6, $t2, $zero                           # $t2 = last valid index position of 'partial_string' points to the first integer      
   j integer_part_create_float                   
           
   integer_part_create_float_WITH_decimals:    
   la $t9, index_of_period                       # get index of the period  
   lw $t6, 0($t9)              
   
   subi $t6, $t6, 1                              # index of first integer = (index of the period - 1)
      
   # Get first integer
   integer_part_create_float:
   blt $t6, $zero, exit_convert_to_float         # Check if index is valid ( index >= 0)     
   
   lb $t5, partial_string($t6)	           # Total_Number_of_Interger_Digits = index from last digit in string_array
   sub $t5, $t5, 48                              # Convert decimal digit in ASCII to integer    
   mtc1 $t5, $f1     	           # Move integer to float register
   cvt.s.w $f1, $f1                              # Convert to float                                                                                                        
                            	
   add.s $f0, $f0, $f1                           # add to final result    
   
   subi $t6, $t6, 1	           # Adjust index for next integer
      
   blt $t6, $zero, exit_convert_to_float          # Check if index is valid ( index >= 0)
    
   # Get second integer - Multiple by 10  
   lb $t5, partial_string($t6)	          # Total_Number_of_Interger_Digits = index from last digit in string_array
   sub $t5, $t5, 48                             # Convert decimal digit in ASCII to integer    
   mtc1 $t5, $f1     	          # Move integer to float register
   cvt.s.w $f1, $f1                             # Convert to float                                                                                                          
   
   l.s $f2, float_ten                              	
   mul.s $f1, $f1, $f2                  
   add.s $f0, $f0, $f1
   
   subi $t6, $t6, 1	          # Adjust index for next integer
   blt $t6, $zero, exit_convert_to_float     # Check if index is valid ( index >= 0) 
   
   
   # Get third integer - Multiple by 100   
   lb $t5, partial_string($t6)	          # Total_Number_of_Interger_Digits = index from last digit in string_array
   sub $t5, $t5, 48                             # Convert decimal digit in ASCII to integer    
   mtc1 $t5, $f1     	          # Move integer to float register
   cvt.s.w $f1, $f1                             # Convert to float                                                                                                          
   
   l.s $f2, float_hundred                              	
   mul.s $f1, $f1, $f2                  
   add.s $f0, $f0, $f1
   
   subi $t6, $t6, 1	           # Adjust index for next integer
   blt $t6, $zero, exit_convert_to_float     # Check if index is valid ( index >= 0) 
   
   exit_convert_to_float:   
   ############ TESTE ##################                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ############ TESTE ##################
   # Print the floating-point number in $f2
   #mov.s $f12, $f0                               # Load the float value from $f2 to $f12
   #li $v0, 2                                     # Set $v0 to 2 for printing a float
   #syscall                                       # Execute the print operation 
   
      #clean
   move $t2, $zero                            
   move $t3, $zero                                  
   move $t4, $zero                                  
   move $t5, $zero                                  
   move $t6, $zero
   move $t7, $zero
   move $t8, $zero  
   move $t9, $zero                                   
   
   jr $ra		
