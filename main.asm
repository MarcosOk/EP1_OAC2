.data     
  #Function 1
  xtrain_txt:   .asciiz "xtrain.txt" 
  xtrain_array: .space 18000 # Array characters 
  
  ytrain_txt:   .asciiz "ytrain.txt" 
  ytrain_array: .space 18000 # Array characters 

.text
.globl main

main:

  jal read_xtrain 
  jal read_ytrain     

  # Exit the program
  li $v0, 10        # syscall 10 (exit)
  syscall

########################### FUNCTIONS ##########################

####### 1) READ xtrain.txt 
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
  
####### 2) READ ytrain.txt 
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
