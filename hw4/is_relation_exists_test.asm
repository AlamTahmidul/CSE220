# add test cases to data section
# Test your code with different Network layouts
# Don't assume that we will use the same layout in all our tests
.data
Name1: .asciiz "Jane Doe"
Name2: .asciiz "John Doe"
Name_prop: .asciiz "NAME"

Network:
  .word 5   #total_nodes (bytes 0 - 3)
  .word 10  #total_edges (bytes 4- 7)
  .word 11  #size_of_node (bytes 8 - 11)
  .word 12  #size_of_edge (bytes 12 - 15)
  .word 4   #curr_num_of_nodes (bytes 16 - 19)
  .word 2   #curr_num_of_edges (bytes 20 - 23)
  .asciiz "NAME" # Name property (bytes 24 - 28)
  .asciiz "FRIEND" # FRIEND property (bytes 29 - 35)
   # nodes (bytes 36 - 95)	
  .byte 'J' 'a' 'n' 'e' ' ' 'D' 'o' 'e' '\0' 0 0 'J' 'o' 'h' 'n' ' ' 'D' 'o' 'e' '\0' 0 0 'O' 't' 'h' 'e' 'r' ' ' 'D' 'o' 'e' '\0' 0 'C' 'a' 'c' 't' 'u' 's' '\0' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
   # set of edges (bytes 96 - 215)
  .word 1 2 0 268501052 268501064 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  # Jane Doe and John Doe are related

.text:
main:
	la $a0, Network
  move $a1, $a0
  addi $a1, $a1, 36 # Pointer to Jane Doe
  move $a2, $a0
  addi $a2, $a2, 48 # Pointer to John Doe
	jal is_relation_exists
	
	#write test code
	move $s0, $v0
  
  move $a0, $s0
  li $v0, 1
  syscall

	li $v0, 10
	syscall
	
.include "hw4.asm"