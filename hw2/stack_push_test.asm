.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"
Eq: .asciiz "(3+2)"

val_stack : .word 0
op_stack : .word 0

.text
.globl main
main:

  # add code to call and test stack_push function
  la $t0, Eq
  lbu $t0, 0($t0)
  move $a0, $t0
  li $v0, 11
  syscall
end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
