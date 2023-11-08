.data     
  #Function 1 - Read txt.
  xtrain_txt:             .asciiz "xtrain.txt" 
  xtrain_array_chars:     .space 16384          # Array characters 
  
  xtest_txt:              .asciiz "xtest.txt" 
  xtest_array_chars:      .space 16384          # Array characters 
  
  ytrain_txt:             .asciiz "ytrain.txt" 
  ytrain_array_chars:     .space 16384          # Array characters 
  
  #Function 2 - Get User Input
  str_num:               .asciiz "Quantos numeros deseja inserir? (maximo 200)\n"
  user_input:            .word 0                # variable to user's input 	 	
  check_input_msg:       .asciiz "You entered: "

  #Function 3 - Convert to Float		
  newline_char:               .asciiz "/" 
  
  base_adress_of_float_array: .space 8
  partial_string:             .space 15
  
  xtrain_array_float:         .align 2
  	           .space 4096    # Array floats
  ytrain_array_float:         .align 2
  	           .space 4096     # Array floats
  xtest_array_float:          .align 2
  	           .space 4096     # Array floats  	             	               	     

  non_valid_float_value:      .float -999    # Indicates the end of the float array	
  float_constant:             .float 0.0     # Initialize a float constant
  float_ten:                  .float 10.0    # Declare a float constant
  float_hundred:              .float 100.0   # Declare a float constant
  float_thousand:             .float 1000.0  # Declare a float constant
     
  count_decimal_digits:       .word 0        # quantify how many digits AFTER the period ('.')  
  index_of_period:            .word 0   
 	
.text
.globl main

main:
  # 1) FUNCTION 1
  jal get_user_input
  
  # 2.1) Get chars of 'xtrain.txt'
  la $a0, xtrain_txt
  la $a3, xtrain_array_chars 
  jal read_txt                               
  # 2.2) Get chars of 'ytrain.txt'
  la $a0, ytrain_txt
  la $a3, ytrain_array_chars 
  jal read_txt  
  # 2.3) Get chars of 'xtest.txt'
  la $a0, xtest_txt
  la $a3, xtest_array_chars 
  jal read_txt                                   
  
  # 3.1) Create float array 'xtrain_array_chars'
  la $t1, xtrain_array_chars
  la $a2, xtrain_array_float 
  sw $a2, base_adress_of_float_array
  jal convert_partial_string_to_float  
  # 3.2) Create float array 'ytrain_array_chars'
  la $t1, ytrain_array_chars
  la $a2, ytrain_array_float
  sw $a2, base_adress_of_float_array
  jal convert_partial_string_to_float
  # 3.3) Create float array 'xtest_array_float'
  la $t1, xtest_array_chars
  la $a2, xtest_array_float
  sw $a2, base_adress_of_float_array
  jal convert_partial_string_to_float
 
  ############ TESTE ###########################		
  # Print 
  #li $v0, 4                 
  #la $a0, xtrain_array_chars        
  #syscall  
  ############ TESTE ###########################		
  # Print 
  #li $v0, 4                 
  #la $a0, ytrain_array_chars         
  #syscall  
  ############ TESTE ###########################		
  # Print 
  #li $v0, 4                 
  #la $a0, xtest_array_chars       
  #syscall     
        
    
  # Exit the program
  li $v0, 10                  
  syscall

########################### FUNCTIONS ##################################################

####### 1) FUNCTION - READ txt. ########################################################
read_txt: 
  li $v0, 13           # syscall 13 (open file)
  li $a1, 0            # Read-only mode
  li $a2, 0            # File permissions (ignored)
  syscall
  
  move $s0, $v0
 
  li $v0, 14           # syscall 14 (read file)
  move $a0, $s0        # file descriptor 
  move $a1, $a3
  li $a2, 16384
  syscall

  # Null-terminate the copied string  
  addi $t0, $a1, 16383 # 16384 - 1
  sb $zero, ($t0)      # Null-terminate at the end
  
  ############ TESTE ###########################		
  # Print 
  #li $v0, 4                 
  #move $a0, $a3             
  #syscall  
  
  ############ TESTE ##########################
  # Print     
  #li $t9, 4
  #lb $t8, xtest_array_chars($t9)  
     
  #li $v0, 11       # Print character (syscall code for printing a character)
  #move $a0, $t8    # Load the character to print into $a0
  #syscall
  #############################################                             
  
  # Close the file
  li $v0, 16          # syscall 16 (close file)
  syscall
   
  #clean registers
  move $t0, $zero 
  move $v0, $zero
  move $s0, $zero   
  move $a0, $zero  
  move $a1, $zero
  move $a3, $zero 		

  jr $ra		

####### 2) FUNCTION - GET USER INPUT ##################################################
get_user_input:
  la $a0, str_num       # print 'str_num'
  li $v0, 4
  syscall
    
  li $v0, 5             # read an integer from the user
  syscall  
  
  sw $v0, user_input    # Store the result
  
  # Display a message to check the user's input
  la $a0, check_input_msg
  li $v0, 4  
  syscall 
  
  lw $a0, user_input    # Load the user's input from the variable
  li $v0, 1
  syscall
  
  # clean registers
  move $v0, $zero
  move $a0, $zero  
  
  jr $ra 
  
####### FUNCTION 3) CONVERT STRING TO FLOAT ##################################
convert_partial_string_to_float:
  # Initialize variables
  lw $t0, user_input                         # loop counter (user input) - the quantity of float numbers the user wants
  
  fill_train_array_float_loop:
  li $t2, 0                                  # Index 'partial_string[]'
  li $t3, 0                                  # Store each char
  li $t4, 0                                  # Store ASCII code
  li $t5, 0                                  # Store ASCII code  
  
#### 3.1) CREATE PARTIAL STRING #############################################             
  # Loop to create 'partial_string' array 	
  loop_get_chars_to_partial_string:          # Loop to create 'partial_string' array   
   lb $t3, ($t1)                             # Load a character from train_array   
      
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
   addi $t1, $t1, 1                          # Increment 'train_array_chars[index]'
   addi $t2, $t2, 1                          # Increment 'partial_string[index]'
   j loop_get_chars_to_partial_string  
                        
   format_partial_string:
   # Null-terminate the last value position of 'partial_string[]'   
   sb $zero, partial_string($t2)
   
   # decrement the index to point 
   # to the number before the 'null-terminate' 
   # added in the previous line               
   subi $t2, $t2, 1                                  
   
   addi $t1, $t1, 1                          # Increment index of 'train_array_chars[]' for next loop of 'convert_partial_string_to_float'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
   
   # clean registers	     
   move $t3, $zero                           # Clean last char
   move $t4, $zero
   move $t5, $zero 
      
  j process_partial_string	

####### 3.2) CONVERT 'partial_string' TO FLOAT  ############################
  process_partial_string:    
   # Initialize variables    
   li $t3, 0
   li $t5, 0
   li $t6, 0  
   li $t7, 0                                      # Index for 'adjust_format_float'
   li $t8, 0
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
     
   
#### 3.2.1) Create decimal part of float #####################################	
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
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
###### 3.2.2) Create integer part of float #############################################                                                                       
   integer_part_create_float_NO_decimals:        # $t2 + 1 = total number of integer digits
   add $t6, $t2, $zero                           # $t2 = last valid index position of 'partial_string' points to the first integer      
   j integer_part_create_float                   
           
   integer_part_create_float_WITH_decimals:   
   la $t8, index_of_period                       # get index of the period 
   lw $t6, 0($t8)              
   
   subi $t6, $t6, 1                              # index of first integer = (index of the period - 1)
      
   # Get first integer
   integer_part_create_float:
   blt $t6, $zero, exit_convert_partial_string_to_float         # Check if index is valid ( index >= 0)     
   
   lb $t5, partial_string($t6)	           # Total_Number_of_Interger_Digits = index from last digit in string_array
   sub $t5, $t5, 48                              # Convert decimal digit in ASCII to integer    
   mtc1 $t5, $f1     	           # Move integer to float register
   cvt.s.w $f1, $f1                              # Convert to float                                                                                                        
                            	
   add.s $f0, $f0, $f1                           # add to final result    
   
   subi $t6, $t6, 1	           # Adjust index for next integer
      
   blt $t6, $zero, exit_convert_partial_string_to_float         # Check if index is valid ( index >= 0)
    
   # Get second integer - Multiple by 10  
   lb $t5, partial_string($t6)	          # Total_Number_of_Interger_Digits = index from last digit in string_array
   sub $t5, $t5, 48                             # Convert decimal digit in ASCII to integer    
   mtc1 $t5, $f1     	          # Move integer to float register
   cvt.s.w $f1, $f1                             # Convert to float                                                                                                          
   
   l.s $f2, float_ten                              	
   mul.s $f1, $f1, $f2                  
   add.s $f0, $f0, $f1
   
   subi $t6, $t6, 1	                      # Adjust index for next integer
   blt $t6, $zero, exit_convert_partial_string_to_float     # Check if index is valid ( index >= 0) 
      
   # Get third integer - Multiple by 100   
   lb $t5, partial_string($t6)	          # Total_Number_of_Interger_Digits = index from last digit in string_array
   sub $t5, $t5, 48                             # Convert decimal digit in ASCII to integer    
   mtc1 $t5, $f1     	          # Move integer to float register
   cvt.s.w $f1, $f1                             # Convert to float                                                                                                          
   
   l.s $f2, float_hundred                              	
   mul.s $f1, $f1, $f2                  
   add.s $f0, $f0, $f1
   
   subi $t6, $t6, 1	                      # Adjust index for next integer
   blt $t6, $zero, exit_convert_partial_string_to_float     # Check if index is valid ( index >= 0) 
     
   exit_convert_partial_string_to_float:                             
   # Clear the partial_string array (set each element to null-terminator)
   la $t2, partial_string              # Load the base address of partial_string                      
         
   clear_loop:
       sb $zero, 0($t2)                # Store the null-terminator at the current element
       addi $t2, $t2, 1                # Move to the next element
        
       lb  $t4, 0($t2) 
       bnez $t4, clear_loop            # Continue looping until reach null-terminator at the end                                       
               
##### 3.3) FILL THE FLOAT ARRAY ######################################################
   lw $t2, user_input 
   bne $t0, $t2, store_float_in_train_array_float
   li $t9, 0    
                                                                              
   store_float_in_train_array_float:                   
    s.s $f0, base_adress_of_float_array($t9)                                              
    
    ############ TESTE ####################
    # Print     
    #l.s $f16, base_adress_of_float_array($t9)  
    #li $v0, 2
    #mov.s $f12, $f16
    #syscall    
    #######################################      
                    
    l.s $f0, float_constant                       # clean $f0 for the next float    
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    #adjust index of 'train_array_float'
    addi $t9,$t9, 4                               # increment index of 'train_array_float'  
                 
    # decrement the loop counter
    subi $t0, $t0, 1                     
    beqz $t0, end_function                        
    j fill_train_array_float_loop                                                                                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
   end_function:   
    # Include non-valid float in the last valid position of 'train_array_float'  
    addi $t9, $t9, 4                              # increment index of 'train_array_float'  
    l.s $f0, non_valid_float_value 
    s.s $f0, base_adress_of_float_array($t9)         
   
    #clean registers
    l.s $f0, float_constant
    l.s $f1, float_constant
    l.s $f2, float_constant
    
    move $a0, $zero
    move $a1, $zero
    move $a2, $zero
    move $a3, $zero
    
    move $t0, $zero
    move $t1, $zero   
    move $t2, $zero                            
    move $t3, $zero                                  
    move $t4, $zero                                  
    move $t5, $zero                                  
    move $t6, $zero
    move $t7, $zero
    move $t8, $zero  
    move $t9, $zero                                   
      
    jr $ra

#### 4 Função calculate_distance #####################################
calculate_distance:
    # Argumentos:
    # $a0: Endereco do vetor de teste (xtest)
    # $a1: Endereco do vetor de treinamento (xtrain)
    # $a2: Numero de elementos nos vetores
    # $f0: Endereco onde a distancia sera armazenada

    # Limpar registradores
    move $t0, $zero
    li.s $f0, 0.0

    calculate_distance_loop:
    # Verifica se atingi o final dos vetores
    beq $t0, $a2, calculate_distance_done

    # Calcula a diferenca entre os elementos dos vetores
    lwc1 $f2, 0($a0)  # Carrega xtest[$t0]
    lwc1 $f3, 0($a1)  # Carrega xtrain[$t0]
    sub.s $f2, $f2, $f3
    mul.s $f2, $f2, $f2  # Eleva ao quadrado

    add.s $f0, $f0, $f2  # Acumula a soma das diferencas
    addi $a0, $a0, 4  # Avanca para o proximo elemento em xtest
    addi $a1, $a1, 4  # Avanca para o proximo elemento em xtrain
    addi $t0, $t0, 1  # Avanca o indice
    j calculate_distance_loop

    calculate_distance_done:
    sqrt.s $f0, $f0  # Calcula a raiz quadrada da soma

    # Limpa registradores ao final da função
    move $t0, $zero
    li.s $f2, 0.0
    li.s $f3, 0.0

    jr $ra  # Retorna

#### 5 Função knn #################################
knn:
    # Argumentos:
    # $a0: Endereco do vetor xtrain
    # $a1: Endereco do vetor ytrain
    # $a2: Tamanho dos vetores de treinamento
    # $a3: Índice para acessar o vetor xtest
    # $a4: Endereco da linha de xtest que sera lida
    # $t0: Endereco onde a classe prevista sera armazenada

    # Limpa registradores
    li.s $f12, 1.0  # Valor padrao para a classe prevista
    li $t1, 0  # Inicializa o contador de vizinhos proximos da classe 0
    li $t2, 0  # Inicializa o contador de vizinhos proximos da classe 1

    # Calcule o endereco da linha de xtest que sera lido
    mul $t3, $a3, $a4  # Calcule o deslocamento
    add $t5, $t3, $a0  # Adicione ao endereco base

    knn_loop:
    # Verifique se atingimos o final dos vetores de treinamento
    beq $t1, $a2, knn_done

    # Calcula a distancia entre xtest e xtrain
    move $a0, $t5  # Endereco da linha de xtest
    move $a1, $a1  # Endereco de ytrain
    move $a2, $a3  # indice para acessar xtest
    jal calculate_distance

    # Com base na distancia, determina a classe
    c.lt.s $f0, $f12  # Compare com o valor padrão da classe prevista
    bc1f, not_class_0
    b class_0

    not_class_0:
    # Se nao for da classe 0, verifique se e da classe 1
    c.eq.s $f0, $f12  # Compara com o valor padrao da classe prevista
    bc1t, class_1

    # Caso contrario, continua para o proximo elemento de treinamento
    addi $a0, $a0, 4  # Avanca para o proximo elemento em xtrain
    addi $a1, $a1, 4  # Avanca para o proximo elemento em ytrain
    j knn_loop

    class_0:
    addi $t1, $t1, 1  # Incrementa o contador da classe 0
    j knn_next_iteration

    class_1:
    addi $t2, $t2, 1  # Incrementa o contador da classe 1

    knn_next_iteration:
    addi $a0, $a0, 4  # Avanca para o proximo elemento em xtrain
    addi $a1, $a1, 4  # Avanca para o proximo elemento em ytrain
    j knn_loop

    knn_done:
    # Determina a classe prevista com base nos contadores
    bge $t1, $t2, class_1
    class_0:
    li.s $f12, 0.0  # Classe 0
    j knn_end

    class_1:
    li.s $f12, 1.0  # Classe 1

    # Limpa registradores ao final da funcao
    move $t1, $zero
    move $t2, $zero

    jr $ra  # Retorna


######################################################################
