# add test cases to data section
# Test your code with different Network layouts
# Don't assume that we will use the same layout in all our tests
.data
Name1: .asciiz "Jane Doe"
Name2: .asciiz "John Doe"
Frnd_prop: .asciiz "FRIEND"

Network:
### MULT4 NODES ###
  .word 5   #total_nodes (bytes 0 - 3)
  .word 10  #total_edges (bytes 4- 7)
  .word 11  #size_of_node (bytes 8 - 11)
  .word 12  #size_of_edge (bytes 12 - 15)
  .word 4   #curr_num_of_nodes (bytes 16 - 19)
  .word 1   #curr_num_of_edges (bytes 20 - 23)
  .asciiz "NAME" # Name property (bytes 24 - 28)
  .asciiz "FRIEND" # FRIEND property (bytes 29 - 35)
   # nodes (bytes 36 - 95)	
#   .byte 'J' 'a' 'n' 'e' ' ' 'D' 'o' 'e' '\0' 0 0 0 'J' 'o' 'h' 'n' ' ' 'D' 'o' 'e' '\0' 0 0 0 'O' 't' 'h' 'e' 'r' ' ' 'D' 'o' 'e' '\0' 0 0 'C' 'a' 'c' 't' 'u' 's' '\0' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  .byte 'J' 'a' 'n' 'e' ' ' 'D' 'o' 'e' '\0' 0 0 'J' 'o' 'h' 'n' ' ' 'D' 'o' 'e' '\0' 0 0 'O' 't' 'h' 'e' 'r' ' ' 'D' 'o' 'e' '\0' 0 'C' 'a' 'c' 't' 'u' 's' '\0' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
   # set of edges (bytes 96 - 215)
  .word 268501052 268501064 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

#   .word 5   #total_nodes (bytes 0 - 3)
#   .word 10  #total_edges (bytes 4- 7)
#   .word 11  #size_of_node (bytes 8 - 11)
#   .word 12  #size_of_edge (bytes 12 - 15)
#   .word 4   #curr_num_of_nodes (bytes 16 - 19)
#   .word 1   #curr_num_of_edges (bytes 20 - 23)
#   .asciiz "NAME" # Name property (bytes 24 - 28)
#   .asciiz "FRIEND" # FRIEND property (bytes 29 - 35)
#    # nodes (bytes 36 - 95)	
#   .byte 'J' 'a' 'n' 'e' ' ' 'D' 'o' 'e' '\0' 0 0 'J' 'o' 'h' 'n' ' ' 'D' 'o' 'e' '\0' 0 0 'O' 't' 'h' 'e' 'r' ' ' 'D' 'o' 'e' '\0' 0 'C' 'a' 'c' 't' 'u' 's' '\0' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#    # set of edges (bytes 96 - 215)
#   .word 268501052 268501064 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

.text:
main:
	# la $a0, Network
	# jal create_person
	# move $s0, $a0
	
	la $a0, Network
	# la $a1, Name1
	# la $a2, Name2

	lw $a1, 92($a0) # 96
	lw $a2, 96($a0) # 100
	la $a3, Frnd_prop
	addi $sp, $sp, -4
	li $s1, 69
	sw $s1, 0($sp)
	jal add_relation_property
	addi $sp, $sp, 4
	
	#write test code
	move $s0, $v0
	
	move $a0, $s0
	li $v0, 1
	syscall
	
	# li $a0, '\n'
	# li $v0, 11
	# syscall

	# la $a0, Network
	# addi $a0, $a0, 36
	# addi $a0, $a0, 56
	# lw $a0, 8($a0)
	# li $v0, 1
	# syscall

	li $v0, 10
	syscall
	
.include "hw4.asm"