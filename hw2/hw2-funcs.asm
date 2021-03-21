############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
eval:
  # $a0 has the input
  # arg1_addr holds the input
  # val_stack holds operands and op_stack holds operators
  
  lb $t1, 0($a0) # $t1 gets the character

  jr $ra

is_digit:
  # $a0 is a digit`
  li $t0, '0'
  sge $v0, $a0, $t0
  li $t0, '9'
  sle $v0, $a0, $t0
  
  jr $ra

stack_push:
  # $a0 = content, $a1 = tp (top of stack), $a2 = stack base_addr
  li $t0, 2000 # No more than 500 elements
  bgeu $a1, $t0, stack_error # If the stack is full, return error
  
  
  
  li $v0, 4 # Increment top by 4 to the next space
  addu $v0, $v0, $a1
  jr $ra
  
  stack_error:
    la $a0, BadToken
    li $v0, 4
    syscall
    j end

stack_peek:
  # $a0 = tp, $a1 = stack_base_addr
  
  jr $ra

stack_pop:
  # $a0 = tp, $a1 = addr
  jal is_stack_empty # Check for empty stack
  bnez $v0, stack_error # If stack is empty, return error
        
  jr $ra

is_stack_empty:
  # $a0 is tp
  li $t0, -4
  sle $v0, $a0, $t0
  jr $ra

valid_ops:
  # $a0 is the operator
    li $t0, '+'
    seq $v0, $t0, $a0 # $v0 = '+' == $a0

    li $t0, '-'
    seq $t1, $t0, $a0 # $t1 = '-' == $a0
    or $v0, $v0, $t1 # $v0 = $v0 or $t1
    
    li $t0, '*'
    seq $t1, $t0, $a0 # $t1 = '*' == $a0
    or $v0, $v0, $t1 # $v0 = $v0 or $t1
    
    li $t0, '/'
    seq $t1, $t0, $a0 # $t1 = '/' == $a0
    or $v0, $v0, $t1 # $v0 = $v0 or $t1
    
  return_isOp:
  jr $ra

op_precedence:
  # MD-AS == 3-2 ; $a0 is the operand
  li $v0, 0 # Clear any old contents
  
  li $t2, 3
  li $t0, '*' # Level 3
    beq $t0, $a0, set_prec
  li $t0, '/' # Level 3
    beq $t0, $a0, set_prec

  li $t2, 2
  li $t0, '+' # Level 2
    beq $t0, $a0, set_prec
  li $t0, '-' # Level 2
    beq $t0, $a0, set_prec
  
  fail_op_prec:
    la $a0, BadToken
    li $v0, 4
    syscall
    j end
  
  set_prec:
    move $v0, $t2
  
  jr $ra

apply_bop: # TODO
  # Simple operations based on $a0 (op1), $a1 (operation), $a2 (operand2)
  addiu $sp, $sp, -8 # Save arguments
  sw $a0, 0($sp) # Save argument is op1
  sw $ra, -4($sp) # Save ra for return function
  move $a0, $a1 # The argument to pass in
  jal valid_ops
  beqz $v0, op_error # If not a valid operator, return error
  lw $a0, 0($sp) # restore values
  lw $ra, -4($sp) # restore values
  addi $sp, $sp, 4
  
  li $t0, '+' # Addition
  add $s0, $a0, $a2
  beq $t0, $a1, solution_applyOp
  
  li $t0, '-' # Subtraction
  sub $s0, $a0, $a2
  beq $t0, $a1, solution_applyOp
  
  li $t0, '*' # Multiplication
  mult $a0, $a2 
  mflo $v0
  beq $t0, $a1, solution_applyOp
  
  li $t0, '/' # Division
  li $t1, 0
  seq $t2, $a2, $0 # If the second operand is a 0
  seq $t3, $a1, $t0 # If the operator is a division
  and $t2, $t2, $t3 # If Dividing by 0
  li $t3, 1
  beq $t3, $t2, op_error # Divide by 0 error
  div $a0, $a2 # Otherwise divide normally
  mflo $v0 # Get the lower 32 bits
  mfhi $t0
  bltz $t0, floor_div_neg
  
  solution_applyOp:
    jr $ra

  floor_div_neg:
    addiu $v0, $v0, -1
    j solution_applyOp

  op_error:
    la $a0, ApplyOpError
    li $v0, 4
    syscall
    j end