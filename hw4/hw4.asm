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
is_person_exists: # $s0 = *ntwrk, $s1 = *person
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
is_person_name_exists: # $s0 = *ntwrk, $s1 = *name, $s2 = copy of counter, $s3 = copy of address
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
add_person_property: # $s0-$s3
	# int add_person_property(Network* ntwrk, Node* person, char* prop_name, char* prop_val)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3

	### CONDITION 1 ###
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a0, $s2 # Copy the address of prop_name
	move $a1, $s0 
	addi $a1, $a1, 24 # Gets the address of the NAME property (arg2)
	jal str_equals

	lw $ra, 0($sp) # Restore return address
	addi $sp, $sp, 4

	beqz $v0, add_p_ret0 # Property name does not match (cond. 1)

	### CONDITION 2 ###
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	move $a0, $s0 # *ntwrk
	move $a1, $s1 # *person
	jal is_person_exists

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	beqz $v0, add_p_retn1 # Person does not exist in network (cond. 2)

	### CONDITION 3 ###
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	move $a0, $s3 # *prop_val
	jal str_len

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $t0, 8($s0) # Get the size_of_node
	bge $v0, $t0, add_p_retn2 # strlen(prop_val) >= Network.size_of_node (cond. 3)

	### CONDITION 4 ###
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $a0, $s0 # *ntwrk
	move $a1, $s3 # *name = *prop_val
	jal is_person_name_exists

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	bgtz $v0, add_p_retn3 # Person does not have an unique name (cond. 4)
	# move $a0, $v0
	# li $v0, 1
	# syscall
	# j end

	### OTHERWISE, VALID name and property insert ###
	# TODO: strcopy(prop_val, *person)
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)

	move $a0, $s3 # *src = *prop_val
	move $a1, $s1  # *dst = *person
	jal str_cpy

	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	li $v0, 1
	jr $ra
	add_p_ret0:
		li $v0, 0
		jr $ra
	add_p_retn1:
		li $v0, -1
		jr $ra
	add_p_retn2:
		li $v0, -2
		jr $ra
	add_p_retn3:
		li $v0, -3
		jr $ra

get_person: # $s0-s1
	# Node* get_person(Network* network, char* name)
	move $s0, $a0
	move $s1, $a1

	# Check if current > total
	lw $t0, 16($s0) # Nodes -> 0
	lw $t1, 0($s0)
	bgt	$t0, $t1, not_found_getPerson	# if $t0 > $t1 then err
	bltz $t0, not_found_getPerson # Or if current_num_of_nodes is an invalid input
	
	lw $t0, 20($s0) # Edges -> 4
	lw $t1, 4($s0)
	bgt	$t0, $t1, not_found_getPerson	# if $t0 > $t1 then err
	bltz $t0, not_found_getPerson

	### CODE BODY ###
	# Call part 6 and if $v0 = 1 (found) otherwise not found
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)

	move $a0, $s0
	move $a1, $s1
	jal is_person_name_exists

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	# Do stuff after
	beqz $v0, not_found_getPerson # If $v0 is 0 then the person does not exist
	move $t0, $v1
	j found_getPerson # Otherwise, person's address is in $v1
	found_getPerson:
		move $v0, $t0
		jr $ra
	not_found_getPerson:
		li $v0, 0
		jr $ra
is_relation_exists: # $s0-s2
	# int is_relation_exists(Network* ntwrk, Node* person1, Node* person2)
	move $s0, $a0 # *ntwrk
	move $s1, $a1 # *person1
	move $s2, $a2 # *person2

	# Check if current > total
	lw $t0, 16($s0) # Nodes -> 0
	lw $t1, 0($s0)
	bgt	$t0, $t1, not_found_relationExists	# if $t0 > $t1 then err
	bltz $t0, not_found_relationExists # Or if current_num_of_nodes is an invalid input
	
	lw $t0, 20($s0) # Edges -> 4
	lw $t1, 4($s0)
	bgt	$t0, $t1, not_found_relationExists	# if $t0 > $t1 then err
	bltz $t0, not_found_relationExists

	# 36 + total_nodes*size_of_node = start of edges
	lw $t0, 0($s0) # Get total_nodes
	lw $t1, 8($s0) # Get size_of_nodes
	mult	$t0, $t1			# $t0 * $t1 = Hi and Lo registers; total_nodes * size_of_node
	mflo	$t0					# copy Lo to $t0; $t0 holds product
	addi $t4, $t0, 36 # $t4 = 36 + (total_nodes * size_of_node)
	# Logic (Word Alignment): $t4 + (4 - $t4 % 4) = next multiple of 4
	li $t0, 4
	div		$t4, $t0			# $t4 / $t0
	mfhi	$t1					# $t1 = $t4 mod $t0
	beqz $t1, ignore_word_al # The beginning address is a multiple of 4
	li $t0, 4
	sub		$t5, $t0, $t1		# $t5 = $t0 - $t1; $t5 = 4 - ($t4 % 4)
	add $t4, $t4, $t5 # $t4 += $t5; $t4 = 36 + (total_nodes * size_of_node) + (4 - ($t4 % 4))
	ignore_word_al:
		add $t4, $s0, $t4 # $t4 = base_address + 36 + (total_nodes * size_of_node) + (4 - $t4 % 4); beginning of the edges array
	li $t3, 0 # Counter
	loop_relationExists:
		lw $t0, 20($s0) # Get current number of edges
		beq $t0, $t3, not_found_relationExists

		lw $t0, 0($t4)
		lw $t1, 4($t4)
		beqz $t0, not_found_relationExists # If there is an entry that is 0, then there are no more relationships?
		beqz $t1, not_found_relationExists # If there is an entry that is 0, then there are no more relationships?

		seq $t2, $t0, $s1 # if the first is *person1
		seq $t5, $t1, $s2 # if the second is *person2
		and $t2, $t2, $t5 # If *person1 and *person2 then 1 otherwise 0
		bnez $t2, found_relationExists # There is a relationship

		seq $t2, $t0, $s2 # if the first is *person2
		seq $t5, $t1, $s1 # if the second is *person1
		and $t2, $t2, $t5 # If *person2 and *person1 then 1 otherwise 0
		bnez $t2, found_relationExists # There is a relationship

		addi $t4, $t4, 12 # Go to the next Edge
		addi $t3, $t3, 1 # Increment counter
		j loop_relationExists
	found_relationExists:
		li $v0, 1
		jr $ra
	not_found_relationExists:
		li $v0, 0
		jr $ra
add_relation: # $s0-s2
	# int add_relation(Network* ntwrk, Node* person1, Node* person2)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2

	### CONDITION 1 ###
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)

	move $a0, $s0
	move $a1, $s1
	jal is_person_exists

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	beqz $v0, ret_addRelation0  # *person1 does not exist

	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)

	move $a0, $s0
	move $a1, $s2
	jal is_person_exists

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	beqz $v0, ret_addRelation0  # *person2 does not exist

	### CONDITION 2 ###
	lw $t0, 20($s0) # Get current number of edges
	lw $t1, 4($s0) # Get total number of edges
	bge $t0, $t1, ret_addRelation1 # if curr_num_of_edges >= total_edges then err
	bltz $t0, ret_addRelation1 # If negative number of edges

	### CONDITION 3 ###
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)

	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists # returns 1 if they are already related

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	bnez $v0, ret_addRelation2 # *person1 and *person2 are already related
	
	### CONDITION 4 ###
	beq $s1, $s2, ret_addRelation3 # *person1 == *person2 (itself)

	### ON SUCCESS ###
	lw $t0, 0($s0) # Get total_nodes
	lw $t1, 8($s0) # Get size_of_node
	mult	$t0, $t1			# $t0 * $t1 = Hi and Lo registers; total_nodes * size_of_node
	mflo	$t0					# copy Lo to $t0; $t0 holds the product
	addi $t3, $t0, 36 # $t3 = 36 + (total_nodes * size_of_node)
	# Logic (Word Alignment): $t3 + (4 - $t3 % 4)
	li $t0, 4
	div		$t3, $t0			# $t3 / $t0
	mfhi	$t1					# $t1 = $t3 mod 4
	beqz $t1, ignore_word_al_addRel
	li $t0, 4
	sub $t0, $t0, $t1 # $t0 = 4 - ($t3 % 4)
	add $t3, $t3, $t0 # $t3 += (4 - $t3 % 4)
	ignore_word_al_addRel:
		add $t3, $s0, $t3 # $t3 = base addr. + 36 + (total_nodes * size_of_node)
		# Logic: $t3 + 12(curr_edge) = location to allocate for new edge
		li $t0, 12
		lw $t1, 20($s0) # Get curr_edge
		mult	$t0, $t1			# $t0 * $t1 = Hi and Lo registers; 12 * curr_edge
		mflo	$t0					# copy Lo to $t0; $t0 holds product
		add $t3, $t3, $t0 # $t3 + 12*curr_edge = location of empty edge

		sw $s1, 0($t3) # Put *person1 in the first slot
		sw $s2, 4($t3) # Put *person2 in the second slot)

		lw $t0, 20($s0) # Get curr_num_of_edges
		addi $t0, $t0, 1 # Increment curr_edges by 1
		sw $t0, 20($s0) # Update

		li $v0, 1
		jr $ra
	ret_addRelation0:
		li $v0, 0
		jr $ra
	ret_addRelation1:
		li $v0, -1
		jr $ra
	ret_addRelation2:
		li $v0, -2
		jr $ra
	ret_addRelation3:
		li $v0, -3
		jr $ra
add_relation_property: # $s0-s4 TODO: CHECK WORD-ALIGNMENT WITH EDGES
	# int add_relation_property(Network* ntwrk, Node* person1, Node* person2, char* prop_name, int prop_value)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	lw $s4, 0($sp)

	

	jr $ra
is_friend_of_friend:
	jr $ra
end:
	li $v0, 10
	syscall
