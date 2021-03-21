.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"
Eq: .asciiz "(3+2)"
Num1: .word 3

val_stack : .word 2334567
op_stack : .word 0

.text
.globl main
main:

  # add code to call and test stack_push function
  # $a0 = content, $a1 = tp (top of stack), $a2 = stack base_addr

  lw $a0, Num1
  li $a1, 500
  la $a2, val_stack
  jal stack_push
  
  move $a0, $v0 # Print new Top after push
  li $v0, 1
  syscall # Top should be at index 4
  
  # $a0 = tp, $a1 = addr (POP)
  # $a0 from the previous should be at 4
  la $a1, val_stack
  jal stack_pop 
  
  move $a0, $v0 # Print new top after pop
  li $v0, 1
  syscall # Should be 0
  
  move $a0, $v1 # Print the value that was popped
  li $v0, 1
  syscall # Should be 3 that was popped
  
end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
