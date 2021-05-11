############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

create_term: # Uses $s0
	# Term* create_term(int coeff, int exp)
	addi $sp, $sp, -4
	sw $s0, 0($sp) # Preserve the value for $s0

	### PRECONDITIONS ###
	blez $a0, create_term_err
	blez $a1, create_term_err

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
	blez $a0, init_polynomial_err # Not a valid pointer
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
add_N_terms_to_polynomial: # Uses $s0-s3
	# int add_N_terms_to_polynomial(Polynomial* p, int[] terms, N)
	addi $sp, $sp, 20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)

	move $s0, $a0 # Copy *p
	move $s1, $a1 # Copy the addr. of terms array
	move $s2, $a2 # Copy N
	li $s3, 0 # Number of terms properly added
	loop_addNPoly:
		lw $t0, 0($s1) # Coefficient
		seq $t1, $t0, $0 # If Coefficient is 0
		lw $t0, 4($s1) # Exponent
		li $t3, -1
		seq $t2, $t0, $t3 # If exp is -1
		and $t0, $t1, $t2 # If coeff = 0 and exp = -1
		bltz $t0, end_loop_addNPoly # Exit the loop

		

		j loop_addNPoly
	end_loop_addNPoly:

		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		move $v0, $s3
		jr $ra
update_N_terms_in_polynomial:
	# int update_N_terms_in_polynomial(Polynomial* p, int[] terms, N)
	jr $ra
get_Nth_term:
	# (int,int) get_Nth_term(Polynomial* p, N)

	jr $ra
remove_Nth_term:
	# (int,int) remove_Nth_term(Polynomial* p, N)

	jr $ra
add_poly:
	# int add_poly(Polynomial* p, Polynomial* q, Polynomial* r)

	jr $ra
mult_poly:
	# int mult_poly(Polynomial* p, Polynomial* q, Polynomial* r)
	
	jr $ra
