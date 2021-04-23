# add test cases to data section
# Test your code with different Network layouts
# Don't assume that we will use the same layout in all our tests
.data
# Name1: .asciiz "Cacophonix"
Name1: .asciiz "John Doe"
Name2: .asciiz "Cacphonix"
Name_prop: .asciiz "NAME"

Network:
  .word 5   #total_nodes (bytes 0 - 3)
  .word 10  #total_edges (bytes 4- 7)
  .word 12  #size_of_node (bytes 8 - 11)
  .word 12  #size_of_edge (bytes 12 - 15)
  .word 5   #curr_num_of_nodes (bytes 16 - 19)
  .word 0   #curr_num_of_edges (bytes 20 - 23)
  .asciiz "NAME" # Name property (bytes 24 - 28)
  .asciiz "FRIEND" # FRIEND property (bytes 29 - 35)
   # nodes (bytes 36 - 95)	
  .byte 'J' 'a' 'n' 'e' ' ' 'D' 'o' 'e' '\0' 0 0 0 'J' 'o' 'h' 'n' ' ' 'D' 'o' 'e' '\0' 0 0 0 'O' 't' 'h' 'e' 'r' ' ' 'D' 'o' 'e' '\0' 0 0 'C' 'a' 'c' 't' 'u' 's' '\0' 0 0 0 0 0 'S' 't' 'a' 'r' 't' '\0' 0 0 0 0 0 0	
   # set of edges (bytes 96 - 215)
  .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

.text:
main:
	# la $a0, Network
	# jal create_person
	# move $s0, $v0
	
	# la $a0, Network
	# move $a1, $s0
	# la $a2, Name_prop
	# la $a3, Name1
	# jal add_person_property
	
	# la $a0, Network
	# la $a1, Name2
	# jal is_person_name_exists 
	
	# la $a0, Network
	# addi $a0, $a0, 36
	# li $v0, 4
	# syscall
	
	la $a0, Network
	la $a1, Name1
	jal is_person_name_exists

	#write test code
	move $s0, $v0
	move $s1, $v1

	move $a0, $s0
	li $v0, 1
	syscall

	li $a0, '\n'
	li $v0, 11
	syscall

	move $a0, $s1
	li $v0, 1
	syscall

	li $a0, '\n'
	li $v0, 11
	syscall

	la $a0, Network
	li $v0, 1
	syscall

	li $v0, 10
	syscall
	
.include "hw4.asm"
