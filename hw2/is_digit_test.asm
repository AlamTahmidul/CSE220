.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"
Character: .asciiz "9"

val_stack : .word 0
op_stack : .word 0

.text
.globl main
main:

  # add code to call and is_digit function
  lbu $t1, Character
  move $a0, $t1
  jal is_digit
  
  move $a0, $v0
  li $v0, 1
  syscall
  
end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
