.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"
Comma: .asciiz ","

val_stack : .word 0
op_stack : .word 0

.text
.globl main
main:

  # add code to call and test stack_empty function
  li $t0, 10
  move $a0, $t0
  jal is_stack_empty
  move $a0, $v0
  li $v0, 1
  syscall
end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
