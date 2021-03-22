############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
eval:
  # $a0 has the address of the input
  # arg1_addr holds the input
  # val_stack holds operands and op_stack holds operators
  
  la $s5, val_stack
  la $s6, op_stack
  li $s0, 0 # Top of val_stack
  li $s1, 0 # Top of op_stack
  li $s2, 0 # Integer to make
  push_to_stacks:
    lb $t1, 0($a0) # $t1 gets the character of the input
    beqz $t1, finish_pushing # Reached the end of the input

    addi $sp, $sp, -24
    sw $a0, 0($sp) # Save the input
    sw $ra, -4($sp) # Save the return address to main
    sw $t1, -8($sp) # Save the current character
    sw $s0, -12($sp) # Save top of val_stack
    sw $s1, -16($sp) # Save top of op_stack
    sw $s2, -20($sp) 
    move $a0, $t1 # $a0 will be the character
    jal is_digit # $v0 will tell us if it is a digit (1) or not (0)
    lw $a0, 0($sp) # Restore the input
    lw $ra, -4($sp) # Restore the return address to main
    lw $t1, -8($sp) # Restore character
    lw $s0, -12($sp) # top of val_stack
    lw $s1, -16($sp) # top of op_stack
    lw $s2, -20($sp)
    bgtz $v0, parse_number # Must be a number (v0 == 1 > 0)
    beqz $v0, parse_operands # Check if the character is an operator (v0 == 0)
    lw $a0, 0($sp) # Restore the input
    lw $ra, -4($sp) # Restore the return address to main
    lw $t1, -8($sp) # Restore character
    lw $s0, -12($sp) # top of val_stack
    lw $s1, -16($sp) # top of op_stack
    addi $sp, $sp, 24
    parse_number:
      li $t2, '0'
      sub $t1, $t1, $t2 # Subtract  from '0' to get the numerical value, $t1
      li $t0, 10
      mul $s2, $s2, $t0 # curr_sum *= 10
      add $s2, $s2, $t1 # curr_sum += digit ($t1)
      
      lb $t0, 1($a0) # Check if the next character is a digit
      sub $t1, $t0, $t2 # Get the digit and store in $t1
      li $t0, 9
      bge $t1, $t0, push_val_stack # if $t1 > 9 (not a digit) then push current integer
      ble $t1, $0, push_val_stack # not a digit; push current integer
      j continue_loop # Otherwise, go to the next character
      push_val_stack: 
        # $s0 (tp_value), $s5 (base_addr_value)
          addi $sp, $sp, -20
          sw $a0, 0($sp) # Save $a0
          sw $ra, -4($sp) # Save curr $ra
          sw $t1, -8($sp) # Save current character
          sw $s1, -12($sp) # Save top of op_stack
          # (PUSH INTO val STACK) $a0 = content, $a1 = tp (top of stack), $a2 = stack base_addr
          move $a0, $s2 # value in $a0
          move $a1, $s0 # Top of val_stack
          move $a2, $s5 # Base address of value stack
          jal stack_push # Returns the new top in $v0
          lw $a0, 0($sp) # Resore $a0
          lw $ra, -4($sp) # Restore curr $ra
          lw $t1, -8($sp) # Restore current character
          lw $s1, -12($sp) # top of op_stack
          move $s0, $v0 # New top of val_stack
          addi $sp, $sp, 20 # Close stack

        li $s2, 0 # reset integer maker
        j continue_loop # Get next character
    parse_operands:
      addi $sp, $sp, -20
      sw $a0, 0($sp) # Save the input
      sw $ra, -4($sp) # Save the return address to main
      sw $t1, -8($sp) # Save the current character
      sw $s0, -12($sp) # Save top of val_stack
      sw $s1, -16($sp) # Save top of op_stack
      move $a0, $t1
      jal valid_ops # $v0 will tell us if the character is an operator (1) or not (0)
      lw $a0, 0($sp) # Restore the input
      lw $ra, -4($sp) # Restore the return address to main
      lw $t1, -8($sp) # Restore character
      lw $s0, -12($sp) # top of val_stack
      lw $s1, -16($sp) # top of op_stack
      addi $sp, $sp, 20 # Close stack
      bgtz $v0, push_op_stack # Valid Operator
      
      addi $sp, $sp, -20
      sw $a0, 0($sp) # Save the input
      sw $ra, -4($sp) # Save the return address to main
      sw $t1, -8($sp) # Save the current character
      sw $s0, -12($sp) # Save top of val_stack
      sw $s1, -16($sp) # Save top of op_stack
      beqz $v0, parenthesis_check # Check if it is a parenthesis
      lw $a0, 0($sp) # Restore the input
      lw $ra, -4($sp) # Restore the return address to main
      lw $t1, -8($sp) # Restore character
      lw $s0, -12($sp) # top of val_stack
      lw $s1, -16($sp) # top of op_stack
      addi $sp, $sp, 20 # Close stack
      j push_op_stack # Must be a valid operand

      parenthesis_check: # If it is a parenthesis
      lw $a0, 0($sp) # Restore the input
      lw $ra, -4($sp) # Restore the return address to main
      lw $t1, -8($sp) # Restore character
      lw $s0, -12($sp) # top of val_stack
      lw $s1, -16($sp) # top of op_stack
      addi $sp, $sp, 20 # Close stack
        li $t6, '('
        li $t7, ')'
        beq $t1, $t6, push_op_stack # If char is an open parenthesis
        bne $t1, $t7, ill_formed_err # Char is not a closed parenthesis; invalid character and return error
        
        push_op_stack:
          # If valid op. check precedence
          addi $sp, $sp, -20
          sw $a0, 0($sp) # Save $a0
          sw $ra, -4($sp) # Save curr $ra
          sw $t1, -8($sp) # Save current character
          sw $s0, -12($sp) # Save top of val_stack
          sw $s1, -16($sp) # Save top of op_stack
          # $a0 = tp, $a1 = stack_base_addr
          jal is_stack_empty
          bgt $v0, $0, check_great_prec
          lw $a0, 0($sp) # Resore $a0
          lw $ra, -4($sp) # Restore curr $ra
          lw $t1, -8($sp) # Restore current character
          lw $s0, -12($sp) # top of val_stack
          lw $s1, -16($sp) # top of op_stack
          addi $sp, $sp, 20
          j just_push
          check_great_prec: # If there are other op with higher precedence
            #peek -> compare prec
            addi $sp, $sp, -20
            sw $a0, 0($sp) # Save $a0
            sw $ra, -4($sp) # Save curr $ra
            sw $t1, -8($sp) # Save current character
            sw $s0, -12($sp) # Save top of val_stack
            sw $s1, -16($sp) # Save top of op_stack
            jal stack_peek # $v0
            lw $a0, 0($sp) # Save $a0
            lw $ra, -4($sp) # Save curr $ra
            lw $t1, -8($sp) # Save current character
            lw $s0, -12($sp) # Save top of val_stack
            lw $s1, -16($sp) # Save top of op_stack
            move $a0, $v0 # Check precedence for peek
            jal op_precedence
            move $t2, $v0 # $t2 holds precedence for peek
            move $a0, $t1 # Check precedence for current operator
            jal op_precedence # v0 holds current op prec
            lw $a0, 0($sp) # Resore $a0
            lw $ra, -4($sp) # Restore curr $ra
            lw $t1, -8($sp) # Restore current character
            lw $s0, -12($sp) # top of val_stack
            lw $s1, -16($sp) # top of op_stack
            bge $t2, $v0, compute # If stack has a higher prec, pop 2 values and 1 oper
            j ignore_compute #otherwise, just push
            compute:
            # s0 =val_tp, s1 =op_tp
            # t1 holds curr op
            addi $sp, $sp, -20
            sw $a0, 0($sp) # Save $a0
            sw $ra, -4($sp) # Save curr $ra
            sw $t1, -8($sp) # Save current character
            sw $s0, -12($sp) # Save top of val_stack
            sw $s1, -16($sp) # Save top of op_stack
              move $a0, $s1 # Pop operator
              move $a1, $s6 # op_addr
              jal stack_pop
              move $s1, $v0 # change op_tp
              move $t2, $v1 # Popped operator ($t2)
            lw $a0, 0($sp) # Resore $a0
            lw $ra, -4($sp) # Restore curr $ra
            lw $t1, -8($sp) # Restore current character
            lw $s0, -12($sp) # top of val_stack
            sw $s1, -16($sp) # Store new op_tp
              move $a0, $s0 # Value_tp
              move $a1, $s5 # val_addr
              jal stack_pop
                move $s0, $v0 # change val_tp
              move $t3, $v1 # Popped value1 ($t3)
            lw $a0, 0($sp) # Resore $a0
            lw $ra, -4($sp) # Restore curr $ra
            lw $t1, -8($sp) # Restore current character
	    sw $s0, -12($sp) # store new val_tp
	    move $a0, $s0
	     jal is_stack_empty
	     bgtz $v0, ill_formed_err
            lw $a0, 0($sp) # Resore $a0
            lw $ra, -4($sp) # Restore curr $ra
            lw $t1, -8($sp) # Restore current character
            lw $s0, -12($sp) # top of val_stack
             move $a0, $s0
             move $a1, $s5
             jal stack_pop
             move $s0, $v0
             move $t4, $v1 # pop value2 ($t4)
             sw $s0, -12($sp) # Store new val_tp
             # apply bop
             move $a0, $t4 # operand2
             move $a1, $t2 # operator
             move $a2, $t3 # operand1
             jal apply_bop
             move $s2, $v0 # put value in
            lw $a0, 0($sp) # Resore $a0
            lw $ra, -4($sp) # Restore curr $ra
            lw $t1, -8($sp) # Restore current character
            lw $s0, -12($sp) # top of val_stack
            sw $s1, -16($sp) # Store new op_tp
            addi $sp, $sp, 20
             j push_val_stack # Move to value stack
            ignore_compute:
            lw $a0, 0($sp) # Resore $a0
            lw $ra, -4($sp) # Restore curr $ra
            lw $t1, -8($sp) # Restore current character
            lw $s0, -12($sp) # top of val_stack
            lw $s1, -16($sp) # top of op_stack
          addi $sp, $sp, 20
          just_push:
          addi $sp, $sp, -20
          sw $a0, 0($sp) # Save $a0
          sw $ra, -4($sp) # Save curr $ra
          sw $t1, -8($sp) # Save current character
          sw $s0, -12($sp) # Save top of val_stack
          sw $s1, -16($sp) # Save top of op_stack
          # (PUSH INTO OP STACK) $a0 = content, $a1 = tp (top of stack), $a2 = stack base_addr
          move $a0, $t1 # Operator in $a0
          move $a1, $s1 # Top of op_stack
          move $a2, $s6 # Base address of operator stack
          jal stack_push # Returns the new top
          lw $a0, 0($sp) # Resore $a0
          lw $ra, -4($sp) # Restore curr $ra
          lw $t1, -8($sp) # Restore current character
          lw $s0, -12($sp) # top of val_stack
          move $s1, $v0 # New top of op_stack
          addi $sp, $sp, 20 # Close stack
    continue_loop:
      addi $a0, $a0, 1 # Move to the next character
      j push_to_stacks
  finish_pushing:
    beqz $s0, ill_formed_err
    bge $s1, $s0, ill_formed_err
    move $a0, $s0
    move $a1, $s5
    jal stack_pop
    
    move $a0, $v1
    li $v0, 1
    syscall
    j end
  jr $ra
  
  ill_formed_err:
    la $a0, ParseError
    li $v0, 4
    syscall
    j end

is_digit:
  # $a0 is a digit`
  li $t0, '0'
  sge $v1, $a0, $t0 # $v1 = a0 >= 0
  li $t0, '9'
  sle $t1, $a0, $t0 # $t1 = a0 <= 9
  and $v0, $v1, $t1 # v0 = (a0 >= 0) && (a0 <= 9)
#  sle $v0, $a0, $t0
  
  jr $ra

stack_push:
  # $a0 = content, $a1 = tp (top of stack), $a2 = stack base_addr
  li $t0, 500 # No more than 500 elements
  bgtu $a1, $t0, stack_error # If the stack is full, return error
  
  move $t0, $a2 # Clone base address
  sub $t0, $t0, $a1 # Move to the top of the stack (top should be empty) this should be at the most bottom
  sw $a0, 0($t0) # Push the content
  
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
   addi $sp, $sp, -4
   sw $ra, 0($sp) # Store return address
   jal is_stack_empty # Check for empty stack
   lw $ra, 0($sp) # Restore return address
   addi $sp, $sp, 4
   bnez $v0, stack_error # If stack is empty, return error
   
   move $t0, $a1 # $t0 clones base_addr
   li $t2, 4
   subu $t1, $a0, $t2 # $t1 = tp - 4
   sub $t0, $t0, $t1 # $t0 = base_addr - (tp - 4) (Top is at the bottom)
   lw $v0, 0($t0) # Return the value that was at the top

  jr $ra

stack_pop:
  # $a0 = tp, $a1 = addr
   addi $sp, $sp, -4
   sw $ra, 0($sp) # Store return address
   jal is_stack_empty # Check for empty stack
   lw $ra, 0($sp) # Restore return address
   addi $sp, $sp, 4
   bnez $v0, stack_error # If stack is empty, return error
  
  move $t0, $a1 # $t0 clones base_addr
  li $t2, 4
  subu $t1, $a0, $t2 # $t1 = tp - 4
  sub $t0, $t0, $t1 # $t0 = base_addr - (tp - 4) (Top is at the bottom)
  lw $v1, 0($t0) # Return the value that was at the top
  addiu $t1, $t1, 4 # Get the tp
  move $v0, $t1 # Return tp
  
  jr $ra

is_stack_empty:
  # $a0 is tp
  # if (tp < 0) then return 1
  sle $v0, $a0, $0
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

apply_bop: # TODO: Preconditions
  # Simple operations based on $a0 (op1), $a1 (operation), $a2 (operand2)
  addi $sp, $sp, -8 # Save arguments
  sw $a0, 0($sp) # Save argument is op1
  sw $ra, -4($sp) # Save ra for return function
  move $a0, $a1 # The argument to pass in
  jal valid_ops
  beqz $v0, op_error # If not a valid operator, return error
  lw $a0, 0($sp) # restore values
  lw $ra, -4($sp) # restore values
  addi $sp, $sp, 4
  
  li $t0, '+' # Addition
  add $v0, $a0, $a2
  beq $t0, $a1, solution_applyOp
  
  li $t0, '-' # Subtraction
  sub $v0, $a0, $a2
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
    
  bad_token_err:
    la $a0, BadToken
    li $v0, 4
    syscall
    j end
