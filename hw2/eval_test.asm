.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"
Test1: .asciiz "(3+5)"

val_stack : .word 1234
op_stack : .word 5678

.text
.globl main
main:

  # add code to call and test eval function
  la $a0, Test1
  jal eval
end:
	# Terminates the program
	li $v0, 10
	syscall

.include "hw2-funcs.asm"
