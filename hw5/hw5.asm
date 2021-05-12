############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

create_term: # Uses $s0
	# Term* create_term(int coeff, int exp)
	addi $sp, $sp, -4
	sw $s0, 0($sp) # Preserve the value for $s0

	### PRECONDITIONS ###
	blez $a0, create_term_err # Coeff <= 0
	bltz $a1, create_term_err # Exp < 0

	move $s0, $a0
	li $a0, 12 # Allocate 12 bytes of memory
	li $v0, 9
	syscall # $v0 holds the address to allocated space

	sw $s0, 0($v0) # Store the coeff
	sw $a1, 4($v0) # Store the exp
	sw $0, 8($v0) # Set next link to 0

	lw $s0, 0($sp) # Restore $s0
	addi $sp, $sp, 4 # Deallocate
	jr $ra # Return $v0, the address to this term
	create_term_err:
		li $v0, -1
		lw $s0, 0($sp) # Restore $s0
		addi $sp, $sp, 4 # Deallocate
		jr $ra
init_polynomial: # Uses $s0-s2
	# int init_polynomial(Polynomial* p, int[2] pair)
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)

	# lw $a0, 0($a1)
	# li $v0, 1
	# syscall
	# move $a0, $s1
	# li $v0, 11
	# syscall

	### PRECONDITIONS ###
	bltz $a0, init_polynomial_err # Not a valid pointer
	lw $s0, 0($a1)
	lw $s1, 4($a1)
	move $s2, $a0

	move $a0, $s0
	move $a1, $s1
	jal create_term
	bltz $v0, init_polynomial_err # Invalid exponent/coeff
	# Otherwise, continue to main body

	### Main Body ###
	# $v0 contains the address to term
	sw $v0, 0($s2) # Make p->Head

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16

	li $v0, 1
	jr $ra
	init_polynomial_err:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16
		li $v0, -1
		jr $ra
add_N_terms_to_polynomial: # Uses $s0-s4
	# int add_N_terms_to_polynomial(Polynomial* p, int[] terms, N)
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	sw $s4, 20($sp)

	move $s0, $a0 # Copy *p
	move $s1, $a1 # Copy the addr. of terms array
	move $s2, $a2 # Copy N
	li $s3, 0 # Number of terms 'properly' added
	blez $s0, end_loop_addNPoly # The address cannot be less than or equal to 0
	blez $s1, end_loop_addNPoly # The address cannot be less than or equal to 0
	blez $s2, end_loop_addNPoly # Number of elements to be added cannot be less than or equal to 0
	loop_addNPoly:
		## Exit the Loop Condition ##
			blez $s2, end_loop_addNPoly # If there are no more terms left to iterate
			lw $t0, 0($s1) # Coefficient
			seq $t1, $t0, $0 # If Coefficient is 0
			lw $t0, 4($s1) # Exponent
			li $t3, -1
			seq $t2, $t0, $t3 # If exp is -1
			and $t0, $t1, $t2 # If coeff = 0 and exp = -1
			bgtz $t0, end_loop_addNPoly # Exit the loop
			## End ##

		## Conditions to Skip ##
			# If there is an invalid coeff or exp
			lw $t0, 0($s1) # Coefficient
			blez $t0, continue_loop_addNPoly
			lw $t0, 4($s1) # Exponent
			bltz $t0, continue_loop_addNPoly
			## End ##
		## Continue as Planned ##
			lw $t3, 0($s0) # Get the address to head_term
			bgtz $t3, addNPoly_initSkip
			# Initialize polynomial since head term is empty
			move $a0, $s0 # Pass in *p
			addi $sp, $sp, -8
			lw $t0, 0($s1)
			sw $t0, 0($sp) # Store pair[0] = coeff
			lw $t0, 4($s1)
			sw $t0, 4($sp) # Store pair[1] = exp
			move $a1, $sp # Pass in pair[2]
			jal init_polynomial # Return 1 if made a head_term
			bltz $v0, end_loop_addNPoly # Return 0; *p is not valid
			addi $sp, $sp, 8
			addNPoly_initSkip:
				lw $s4, 0($s0) # Get the head_address
				ll_addNPoly:
					lw $t0, 4($s1) # Exponent in terms[]
					lw $t1, 4($s4) # Exponent in linked list
					beq $t0, $t1, continue_loop_addNPoly # Skip duplicates

					blt $t1, $t0, addNPoly_between # 1. In between two linked list terms or 2. at header
					lw $t0, 8($s4) # addr. of next_term
					beqz $t0, addNPoly_LastElem # 3. Last element

					move $t9, $s4 # Copy the previous linked list address into $t9
					lw $s4, 8($s4) # Go to next_term
					j ll_addNPoly
				addNPoly_LastElem: # Add term to the last
					lw $t0, 0($s1) # Coefficient
					lw $t1, 4($s1) # Exponent
					move $a0, $t0 # Coeff
					move $a1, $t1 # Exponent
					jal create_term # $v0 contains address to term

					sw $v0, 8($s4)
					j addNPoly_increment_num_Terms
				addNPoly_between:
					# 1. Check if it's the header
						lw $t0, 0($s0)
						beq $s4, $t0, addNPoly_between_isHead
					# 2. Otherwise, normal inbetween
						lw $t0, 0($s1) # Coefficient
						lw $t1, 4($s1) # Exponent
						move $a0, $t0 # Coeff
						move $a1, $t1 # Exponent
						jal create_term # $v0 contains address to term


						# $v0 points to next, prev. points to $v0
						sw $s4, 8($v0)
						sw $v0, 8($t9)
					j addNPoly_increment_num_Terms
					addNPoly_between_isHead:
						# 1. $v0 points to current, 2. Head points to $v0
							lw $t0, 0($s1) # Coefficient
							lw $t1, 4($s1) # Exponent
							move $a0, $t0 # Coeff
							move $a1, $t1 # Exponent

							jal create_term # $v0 contains address to term

							sw $s4, 8($v0) # Current term is after $v0 ($v0 is the new header)
							sw $v0, 0($s0) # Make head to $v0
				addNPoly_increment_num_Terms:
					# After the term is created, add this after the element
					addi $s3, $s3, 1 # Increment the number of terms added
			## End ##
		## Continue the loop ##
			continue_loop_addNPoly:
				addi $s1, $s1, 8 # Go to the next pair
				addi $s2, $s2, -1 # Decrease the number of terms to add
				j loop_addNPoly # Jump back to the loop
				## End
	end_loop_addNPoly:
		move $v0, $s3 # Prepare for returning number of terms added
		# Restore $s registers and $ra
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		lw $s4, 20($sp)
		addi $sp, $sp, 24 # Deallocate
		jr $ra
update_N_terms_in_polynomial:
	# int update_N_terms_in_polynomial(Polynomial* p, int[] terms, N)
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)

	li $s3, 0 # Number of terms updated
	lw $s0, 0($a0) # Copy addr. to head_term
	move $t6, $s0
	blez $s0, error_updateNPoly # Address at 0 or neg is an error
	move $s1, $a1 # Copy terms[]
	blez $s1, error_updateNPoly # Address at 0 or negative is an error
	move $s2, $a2 # Copy N
	blez $s2, error_updateNPoly # 0 or less terms for N is an error

	li $a0, 200
	li $v0, 9
	syscall # Allocate memory for Terms visited
	move $t3, $v0 # Create a copy of the address (check for visited terms)
	loop_updateNPoly:
		## Check Exit Conditions ##
			blez $s2, exit_loop_updateNPoly # N < arr.length
			lw $t0, 0($s1) # Coeff
			seq $t1, $t0, $0 # coeff == 0
			lw $t2, 4($s1) # Exp
			li $t0, -1
			seq $t2, $t0, $t2 # exp == -1
			and $t0, $t1, $t2 # coeff == 0 && exp == -1
			bgtz $t0, exit_loop_updateNPoly # Exit on pair
			## End ##
		## Iterate over the linked list ##
			## Check for invalid terms[] ##
				lw $t0, 0($s1) # Coeff in terms[]
				blez $t0, continue_loop_updateNPoly # Invalid coeff (skip)
				lw $t0, 4($s1) # exp in terms[]
				bltz $t0, continue_loop_updateNPoly # Invalid exp (skip)
				## End ##
			lw $t4, 4($s1) # Get the exponent in terms[]

			move $s0, $t6 # Go to head_term
			move $t3, $v0 # Reset the heap counter to beginning
			ll_updateNPoly: # Linked List traversal
				lw $t5, 4($s0) # Get the exponent in linked list

				beq $t4, $t5, ll_visit_update # If the exponents match, check if the term has been updated already
				j continue_llTrav # otherwise, go to the next pointer in linked list
				ll_visit_update:

					lw $t0, 0($t3) # Get the exp stored in heap
					beqz $t0, increment_update # If the exp has not been visited then increment counter
					beq $t0, $t5, exit_llVisit # If the exp has been visited, don't increment counter (change coeff again)

					addi $t3, $t3, 4 # Go to the next saved slot
					j ll_visit_update # Iterate over visited exp
				increment_update:
					addi $s3, $s3, 1 # Increment number of terms updated

					beqz $t5, zero_exponent_update # Exponent is 0
					sw $t5, 0($t3) # Save the exp in heap; exp > 0
					j exit_llVisit
					zero_exponent_update:
						li $t0, -1
						sw $t0, 0($t3) # Store -1 as 0
						j exit_llVisit # Change coefficient
				continue_llTrav:
					lw $t0, 8($s0) # Get next pointer in linked_list
					beqz $t0, continue_loop_updateNPoly # Term has not been found (exp. does not exist); go to next pair of terms
					lw $s0, 8($s0) # Go to next pointer
					j ll_updateNPoly # Go to next ptr
				exit_llVisit: # Update the coeff in $s0
					lw $t0, 0($s1) # Get the coefficient in terms[]
					sw $t0, 0($s0) # Update the coeff in linked list
					j continue_loop_updateNPoly
			## End ##
		## Continue the loop ##
			continue_loop_updateNPoly:
				addi $s1, $s1, 8 # Go to the next term pair
				addi $s2, $s2, -1 # Decrement the number of counters
				j loop_updateNPoly
			## End ##
	exit_loop_updateNPoly:
		move $v0, $s3
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 20
		jr $ra
	error_updateNPoly:
		move $v0, $s3
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 20
		jr $ra
get_Nth_term:
	# (int,int) get_Nth_term(Polynomial* p, N)
	addi $sp, $sp, -4
	sw $s0, 0($sp)

	### Preconditions ###
		lw $t0, 0($a0)
		blez $t0, err_getN
		move $t0, $a1 
		blez $t0, err_getN
		### End ###

	### Main Body ###
		li $t3, 1 # Highest Order
		lw $s0, 0($a0) # $s0 has a valid pointer
		loop_getN:
			beq $a1, $t3, exit_loop_getN # Found the nth highest order
			
			lw $s0, 8($s0) # Get the next pointer
			beqz $s0, err_getN # If the pointer is 0, then there is no coeff/exp pair in linked list
			addi $t3, $t3, 1
			j loop_getN
		exit_loop_getN:
			# $s0 contains the pointer to nth higest order
			lw $v0, 4($s0) # Exponent
			lw $v1, 0($s0) # Coefficient
			lw $s0, 0($sp)
			addi $sp, $sp, 4
			jr $ra
		### End ###
	err_getN:
		li $v0, -1 # Exp not found
		li $v1, 0 # Coeff not found
		lw $s0, 0($sp)
		addi $sp, $sp, 4
		jr $ra
remove_Nth_term:
	# (int,int) remove_Nth_term(Polynomial* p, N)
	addi $sp, $sp, -4
	sw $s0, 0($sp)

	### Preconditions ###
		blez $a0, err_rem # Invalid Pointer
		blez $a1, err_rem # Invalid Number
		### End ###

	### MAIN BODY ###
		lw $s0, 0($a0) # Valid Pointer
		move $t4, $s0 # Previous = addr. of head_term
		li $t5, 1 # Starting at the highest nth term
		loop_rem:
			beq $t5, $a1, exit_loop_rem # Found nth highest
			
			move $t4, $s0 # previous ptr
			lw $s0, 8($s0) # Get next pointer
			beqz $s0, err_rem # nth highest exponent not found
			addi $t5, $t5, 1 # Increment counter
			j loop_rem
		exit_loop_rem:
			# prev.next = current.next; $t4 = previous, $s0 = current
			lw $t0, 8($s0) # current.next
			sw $t0, 8($t4) # previous.next = current.next
			lw $v0, 4($s0) # Prepare to return exp
			lw $v1, 0($s0) # Prepare to return coeff

			li $t0, 1
			beq $t0, $t5, change_head_rem # Previous points to the head_term
			j ignore_change_head
			change_head_rem:
				lw $t0, 8($s0) # current.next
				sw $t0, 0($a0) # Update the head
			ignore_change_head:
				lw $s0, 0($sp)
				addi $sp, $sp, 4
				jr $ra
		### END ###
	err_rem:
		li $v0, -1 # Exponent not found
		li $v1, 0 # Coeff not found
		lw $s0, 0($sp)
		addi $sp, $sp, 4
		jr $ra
add_poly:
	# int add_poly(Polynomial* p, Polynomial* q, Polynomial* r)

	### PRECONDITIONS ###
	

	jr $ra
mult_poly:
	# int mult_poly(Polynomial* p, Polynomial* q, Polynomial* r)
	
	jr $ra
sort_linked_list:
	# void sort(Polynomial *p)