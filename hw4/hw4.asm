############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

str_len:
	# int str_len(char* str)
	move $t4, $a0
	li $t0, 0
	loop_strlen:
		lb $t1, 0($t4)
		beqz $t1, exit_loop_strlen
		addi $t0, $t0, 1 # increase counter
		addi $t4, $t4, 1 # Get next character
		j loop_strlen
	exit_loop_strlen:
		move $v0, $t0
		jr $ra
str_equals:
	# int str_equals(char* str1, char* str2)
	move $t4, $a0
	move $t5, $a1
	loop_strEq:
		lbu $t0, 0($t4)
		lbu $t1, 0($t5)
		beqz $t0, exit_loop_strEq
		beqz $t0, exit_loop_strEq
		
		bne	$t0, $t1, notEq_strEq	# if $t0 != $t1 then notEq_strEq

		addi $t4, $t4, 1
		addi $t5, $t5, 1
		j loop_strEq
	exit_loop_strEq:
		# DO stuff here
		lbu $t0, 0($t4) # If the first string has more characters than the second string
		bnez $t0, notEq_strEq
		lbu $t0, 0($t5) # If the second string has more characters than the first string
		bnez $t0, notEq_strEq

		# Otherwise, they are equal
		li $v0, 1
		jr $ra
	notEq_strEq:
		li $v0, 0
		jr $ra
str_cpy: # $s0 = *dest
	# int str_cpy(char* src, char* dest)
	move $s0, $a0

	move $t4, $a0 # Copy the string
	move $t5, $a1
	loop_str_copy:
		lbu $t0, 0($t4)
		beqz $t0, exit_loop_str_copy
		sb	$t0, 0($t5)	# Copy character to the destination character

		addi $t5, $t5, 1 # Go to the next empty space
		addi $t4, $t4, 1 # Go to the next character
		j loop_str_copy
	exit_loop_str_copy:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		move $a0, $s0
		jal str_len
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4

		# $v0 should have the length of the string
		jr $ra
create_person: # $s0 = *network
	# Node* create_person(Network* ntwrk)
	move $s0, $a0

	# Check if current > total
	lw $t0, 16($s0) # Nodes -> 0
	lw $t1, 0($s0)
	bge		$t0, $t1, cp_full_nodes	# if $t0 > $t1 then err
	bltz $t0, cp_full_nodes
	
	lw $t0, 20($s0) # Edges -> 4
	lw $t1, 4($s0)
	bgt	$t0, $t1, cp_full_nodes	# if $t0 > $t1 then err
	bltz $t0, cp_full_nodes

	# index location of newly added node = 36 + (cur_num_of_nodes * size_of_node)
	lw $t0, 16($s0) 	# $t0 has the current number of nodes
	lw $t1, 8($s0) # Gets the size_of_node
	mult	$t0, $t1			# $t0 * $t1 = Hi and Lo registers; cur_num_of_nodes * size_of_node
	mflo	$t0					# copy Lo to $t0; $t0 holds the product
	addi $t0, $t0, 36 # Go to the empty node

	add $v0, $s0, $t0 # Return the sum of address + location of empty node
	
	lw $t0, 16($s0) # Get curr_num_of_nodes 
	addi $t0, $t0, 1 # Increase num. of current nodes by 1 
	sw $t0, 16($s0) # Update the network

	jr $ra
	cp_full_nodes:
		li $v0, -1 # Nodes are full
		jr $ra
is_person_exists: # $s0 = *ntwrk, $s1 = person
	# int is_person_exists(Network* ntwrk, Node* person)
	move $s0, $a0
	move $s1, $a1 # Person

	# Check if current > total
	lw $t0, 16($s0) # Nodes -> 0
	lw $t1, 0($s0)
	bgt		$t0, $t1, not_found_is_person	# if $t0 > $t1 then not_found_is_person
	bltz $t0, not_found_is_person # Or if current_num_of_nodes is an invalid input
	
	lw $t0, 20($s0) # Edges -> 4
	lw $t1, 4($s0)
	bgt	$t0, $t1, not_found_is_person	# if $t0 > $t1 then not_found_is_person
	bltz $t0, not_found_is_person

	li $t4, 0 # Counter
	loop_is_person:
		# Get the maximum number of iterations based on current number of nodes
		lw $t1, 16($s0) # Current Number of nodes
		bge $t4, $t1, not_found_is_person

		lw $t0, 8($s0) # Size of node
		# 36 + (i*size) = location of node
		mult	$t4, $t0			# $t4 * $t0 = Hi and Lo registers; index * size of node
		mflo	$t0					# copy Lo to $t0; $t0 holds the product
		
		add $t0, $s0, $t0 # Addr += location
		addi $t0, $t0, 36 # Go to the node
		beq $t0, $s1, exit_loop_is_person # If the addresses are the same, then return 1
		
		addi $t4, $t4, 1 # Increase counter
		j loop_is_person
	exit_loop_is_person:
		# Return 1 (if found) or return 0
		li $v0, 1
		jr $ra
	not_found_is_person:
		li $v0, 0
		jr $ra
is_person_name_exists: # $s0 = *ntwrk, $s1 = name, $s2 = copy of counter, $s3 = copy of address
	# int is_person_name_exists(Network* ntwrk, char* name)
	move $s0, $a0
	move $s1, $a1

	# Check if current > total
	lw $t0, 16($s0) # Nodes -> 0
	lw $t1, 0($s0)
	bgt	$t0, $t1, exit_loop_is_person_name	# if $t0 > $t1 then exit_loop_is_person_name
	bltz $t0, exit_loop_is_person_name # Or if current_num_of_nodes is an invalid input
	
	lw $t0, 20($s0) # Edges -> 4
	lw $t1, 4($s0)
	bgt	$t0, $t1, exit_loop_is_person_name	# if $t0 > $t1 then exit_loop_is_person_name
	bltz $t0, exit_loop_is_person_name

	li $t4, 0 # Counter
	loop_is_person_name:
		lw $t0, 16($s0) # Get current number of nodes
		beq $t4, $t0, exit_loop_is_person_name

		# 36 + index*size_of_node
		lw $t0, 8($s0) # Size of ndoe
		mult	$t0, $t4			# $t0 * $t4 = Hi and Lo registers
		mflo	$t0					# copy Lo to $t0; product of index*size_of_node
		add $t3, $s0, $t0 # Addr + location of node
		addi $t3, $t3, 36 # offset by 36 to get the node

		move $s2, $t4 # save a copy of $t4
		move $s3, $t3 # Save a copy of the address	
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		move $a0, $t3
		move $a1, $s1
		jal str_equals

		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		move $t4, $s2 # Restore $t4

		bgtz $v0, is_person_name_found

		addi $t4, $t4, 1 # Increase counter
		j loop_is_person_name
	exit_loop_is_person_name:
		# Return 0 because name not found
		li $v0, 0
		jr $ra
	is_person_name_found:
		li $v0, 1
		move $v1, $s3
		jr $ra
add_person_property:
	
	jr $ra
get_person:
	jr $ra
is_relation_exists:
	jr $ra
add_relation:
	jr $ra
add_relation_property:
	jr $ra
is_friend_of_friend:
	jr $ra
end:
	li $v0, 10
	syscall
