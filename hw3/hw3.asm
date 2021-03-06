# Tahmidul Alam
# tmalam
# 112784865

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text
load_game: # Uses $s0 = *state, $s1 = filename, $s2 = file descriptor, $s3 = address of $sp, $s4 = stone count, $s5 = constructed number
	# int, int load_game(GameState* state, string filename) $a0, $a1
	move $s0, $a0 # $s0 has *state
	move $s1, $a1 # $s1 has filename
	
	move $t5, $s0 # $t5 stores a copy of *state
	addi $t5, $t5, 8 # Start at the beginning of the pockets (0)
	
	# lbu $t0, 0($t5)
	# move $a0, $t0
	# li $v0, 1
	# syscall

	# li $v0, 10
	# syscall

	# move $t0, $sp 
	# addi $sp, $sp, -4
	# sw $t0, 0($sp)
	# Open File
	move $a0, $a1 # $a0 = filename adress
	li $a1, 0  # $a1 = flag (Read-only)
	li $a2, 0 # Ignore mode
	li $v0, 13 # Open file
	syscall
	blez $v0, file_dne # $v0, $v1 = -1 (File does not exist)
	move $s2, $v0 # $s2 has file descriptor

	li $s4, 0 # Total num. of stones
	li $s5, 0 # Construct actual number for byte
	li $t6, 0 # Index from the right for bot_mancala
	li $t2, 1 # $t2 holds row #: 1 = 1st row, ..., 5 = 5th row
	load_game_loop:
		li $t0, 6
		beq $t2, $t0, end_loop_game
		addi $sp, $sp, -4 # allocate sp to hold 1 character
		move $s3, $sp # $s3 has Address of "buffer" ($sp)
		li $v0, 14 # Read file
		move $a0, $s2 # File descriptor
		move $a1, $s3 # File Buffer
		li $a2, 1 # Read 1 character at a time
		syscall # Put the character in the stack pointer
		beqz $v0, end_loop_game

		lw $t3, 0($sp) # $t3 Holds digit in ascii
		addi $sp, $sp, 4 # Deallocate sp before doing anything else

		li $t0, '\r'
		beq $t3, $t0, cont_load_game_loop # If \r, then ignore
		li $t0, '\n'
		beq $t3, $t0, branch_row # Perform appropriate computation if \n

		li $t4, '0'
		sub $t4, $t3, $t4 # $t4 = digit_in_ascii - '0' = value

		li $t0, 1
		beq $t2, $t0, build_pockets_lg # Row 1
		li $t0, 2
		beq $t2, $t0, build_pockets_lg # Row 2
		li $t0, 3
		beq $t2, $t0, build_pockets_lg # Row 3
		li $t0, 4
		beq $t2, $t0, top_update_lg # Row 4
		li $t0, 5
		beq $t2, $t0, bot_update_lg # Row 5
		j cont_load_game_loop

		build_pockets_lg:
			li $t0, 10
			mul $s5, $s5, $t0 # $s5 *= 10
			add $s5, $s5, $t4 # $s5 += $t4
			
			# move $a0, $s5
			# li $v0, 1
			# syscall
			j cont_load_game_loop
		bot_update_lg:
		top_update_lg:
			sb $t3, 0($t5) # Store into top mancala
			
			li $t0, 2
			div $t6, $t0 # $t6 / $t0
			mfhi $t0 # $t0 = $t6 mod $t0
			bgtz $t0, mult_10_lg # If 1, then reset $s5
			
			li $t0, 10
			add $s5, $s5, $t4 # $s5 += value
			j cont_top_update_lg

			mult_10_lg:
				mul $s5, $s5, $t0 # $s5 *= 10
				add $s5, $s5, $t4 # $s5 += value
				add $s4, $s4, $s5 # stone_count += $s5
				li $s5, 0
				
				# move $a0, $s4
				# li $v0, 1
				# syscall
			cont_top_update_lg:
				addi $t5, $t5, 1 # Go to the next character
				addi $t6, $t6, 1 # Increase character counter
		cont_load_game_loop:
			j load_game_loop
		
		branch_row: # $t3 holds digit as ascii, $t2 holds row number
			li $t0, 1
			beq $t2, $t0, row_1_lg # 1st row (first row)
			li $t0, 2
			beq $t2, $t0, row_2_lg # 2nd row
			li $t0, 3
			beq $t2, $t0, row_3_lg # 3rd row
			addi $t2, $t2, 1
			# li $t6, 0 # Reset counter for bit-location
			j cont_load_game_loop

		row_1_lg: # First row; change stones top mancala 
			sb $s5, 1($s0) # Update byte #1 in $s0 with $s5

			move $t7, $s0
			addi $t7, $t7, 6
			
			li $t0, 10
			div		$s5, $t0			# $s5 / $t0
			mflo	$t0					# $t0 = floor($s5 / $t0) 
			mfhi	$t1					# $t1 = $s5 mod $t0
			addi $t0, $t0, '0' # ASCII representation for first digit
			addi $t1, $t1, '0' # ASCII representation for second digit

			# li $v0, 1
			# syscall
			# lbu $a0, 1($t7)
			# li $v0, 1
			# syscall
			# j end

			sb $t0, 0($t7)
			sb $t1, 1($t7)

			addi $t2, $t2, 1 # Increase row counter by 1
			li $s5, 0 # Reset variable
			j cont_load_game_loop # Go to the next row
		row_2_lg: # 2nd row; change stones bot mancala (update byte #0 with $s5)
			sb $s5, 0($s0) # Update byte #0 in $s0 with $s5

			move $t7, $s0
			lbu $t0, 2($s0) # Get num. of pockets
			sll $t0, $t0, 2 # Multiply the num. of pockets by 4
			addi $t7, $t7, 8 # Move t7 to the game_board (and skip the first 2 characters)
			add $t7, $t7, $t0 # Move to the last 2 characters

			li $t0, 10
			div		$s5, $t0			# $s5 / $t0
			mflo	$t0					# $t0 = floor($s5 / $t0) 
			mfhi	$t1					# $t1 = $s5 mod $t0
			addi $t0, $t0, '0'
			addi $t1, $t1, '0'

			sb $t0, 0($t7)
			sb $t1, 1($t7)

			addi $t2, $t2, 1 # Increase row counter by 1
			li $s5, 0 # Reset variable
			j cont_load_game_loop # Go to the next row
		row_3_lg: # Change pockets (if valid)
			sb $s5, 2($s0) # Update byte #2 in $s0 with $s5
			sb $s5, 3($s0) # Update byte #3 in $s0 with $s5
			addi $t2, $t2, 1 # Increase row counter by 1
			li $s5, 0 # Reset variable
			j cont_load_game_loop # Go to the next row

	end_loop_game:
		lbu $t0, 0($s0)
		add $s4, $s4, $t0
		lbu $t0, 1($s0)
		add $s4, $s4, $t0
		li $t0, 99 
		sge $t0, $s4, $t0 # If number of stones is more than 99 then 1
		bgtz $t0, ex_stones_lg # If more than 99
		li $t0, 1 # Otherwise, $v0 is 1 (abide by rules)
		move $v0, $t0
		check_v1_lg:
			lbu $t0, 2($s0) # Load bot_pockets
			li $t1, 98
			add $t0, $t0, $t0 # Multiply by 2 to get the total number of pockets
			bgt $t0, $t1, ex_pockets_lg # pockets > 98 then extra pockets
			move $v1, $t0 # Normal num. of pockets
		return_lg:
			# lw $sp, 0($sp)
			# addi $sp, $sp, 4
			jr $ra
		ex_stones_lg:
			move $v0, $0
			j check_v1_lg
		ex_pockets_lg:
			move $v1, $0
			j return_lg
		
	file_dne:
		li $t0, -1
		move $v0, $t0
		move $v1, $t0
		lw $sp, 0($sp)
		addi $sp, $sp, 4
		jr $ra
get_pocket: # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3 = Num. of pockets, $s4 = Position
	# int get_pocket(GameState* state, byte player, byte distance)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2

	lbu $t0, 2($s0) # Load num. of pockets
	move $s3, $t0 # $s3 = num. of pockets
	sgeu $t1, $s2, $0 # if distance >= 0
	sltu $t2, $s2, $t0 # if distance < pockets
	and $t1, $t1, $t2 # if distance >= 0 && distance < pockets then $t1 = 1
	beqz $t1, get_pocket_err # invalid distance; error
	# Otherwise, distance is valid
	move $t3, $s0
	addi $t3, $t3, 8

	li $t0, 'B'
	beq		$t0, $s1, bot_player_get_pocket	# if $t0 == $s1 then bot_player_get_pocket
	li $t0, 'T'
	beq		$t0, $s1, top_player_get_pocket	# if $t0 == $s1 then top_player_get_pocket
	j get_pocket_err # Otherwise, player is invalid

	bot_player_get_pocket:
		# Position: 4*pockets - 2*distance - 2
		sll $s3, $s3, 2 # 4*pockets
		sll $s2, $s2, 1 # 2*distance
		sub		$t0, $s3, $s2		# $t0 = $s3 - $s2
		li $t1, 2
		sub		$t0, $t0, $t1		# $t0 = $t0 - $t1
		move $s4, $t0 # Position

		j ret_get_pocket
	top_player_get_pocket:
		sll $s2, $s2, 1 # Multiply distance by 2
		move $s4, $s2

		j ret_get_pocket
	ret_get_pocket:
		add $t3, $t3, $s4 # Starting from the first pocket find the relative position
		
		li $t0, '0'
		lbu $t1, 0($t3) # First bit is the first digit in ascii
		sub		$t1, $t1, $t0		# $t1 = $t1 - $t0; get the actual value of digit
		
		li $t0, 10
		mul $t1, $t1, $t0 # Multiply first digit by 10
		
		li $t0, '0'
		lbu $t2, 1($t3) # Second bit is the second digit in ascii
		sub $t2, $t2, $t0 # Get the actual value of second digit

		add $t0, $t1, $t2 # Form the number of stones in the specified pocket
		move $v0, $t0
		jr $ra
	get_pocket_err:
		li $v0, -1
		jr $ra
set_pocket: # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3 = size, $s4 = pockets, $s5 = position
	# int set_pocket(GameState* state, byte player, byte distance, int size)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3

	sge $t0, $s3, $0  # size >= 0
	li $t1, 99
	sle $t1, $s3, $t1 # size < 99
	and $t1, $t0, $t1 # if size >= 0 && size < 99 then $t1 = 1
	beqz $t1, set_pocket_err_beyond_below

	lb $t0, 2($s0) # Get num. of pockets in $t0
	move $s4, $t0
	sge $t1, $s2, $0 # if distance >= 0
	slt $t2, $s2, $t0  # if distance < num_pockets
	and $t1, $t1, $t2 # if distance >= 0 && distance < num_pockets
	beqz $t1, set_pocket_err_invalid # Otherwise, invalid pocket

	li $t1, 'B'
	beq $s1, $t1, bot_player_set_pocket
	li $t1, 'T'
	beq $s1, $t1, top_player_set_pocket
	j set_pocket_err_invalid # Otherwise, invalid player

	top_player_set_pocket:
		sll $s2, $s2, 1 # Multiply distance by 2
		move $s5, $s2

		j ret_set_pocket
	bot_player_set_pocket:
		# Position: 4*pockets - 2*distance - 2
		sll $s4, $s4, 2 # 4*pockets
		sll $s2, $s2, 1 # 2*distance
		sub		$t0, $s4, $s2		# $t0 = $s4 - $s2
		li $t1, 2
		sub		$t0, $t0, $t1		# $t0 = $t0 - $t1
		move $s5, $t0 # Position

		j ret_set_pocket
	ret_set_pocket:
		move $t0, $s0
		addi $t0, $t0, 8
		add $t0, $t0, $s5
		
		li $t1, 10
		div		$s3, $t1			# $s3 / $t1
		mflo	$t2					# $t2 = floor($s3 / $t1) 
		mfhi	$t3					# $t3 = $s3 mod $t1 
		li $t1, '0'
		add $t2, $t2, $t1 # Convert first digit to ascii
		add $t3, $t3, $t1 # Convert second digit to ascii

		sb $t2, 0($t0)
		sb $t3, 1($t0)

		move $v0, $s3
		jr $ra
	set_pocket_err_invalid:
		li $v0, -1
		jr $ra
	set_pocket_err_beyond_below:
		li $v0, -2
		jr $ra
collect_stones: # Uses $s0 = *state, $s1 = player, $s2 = stones
	# int collect_stones(GameState* state, byte player, int stones)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $t6, $s2
	li $t0, 'B'
	beq		$t0, $s1, bot_player_cs	# if $t0 == $s1 then valid_player_cs
	li $t0, 'T'
	beq		$t0, $s1, top_player_cs	# if $t0 == $s1 then valid_player_cs
	j cs_err_player
	bot_player_cs:
		blez $s2, cs_err_stoneCount

		lb $t1, 2($s0)  # Load number of pockets
		sll $t1, $t1, 2 # Multiply by 4
		move $t0, $s0
		addi $t0, $t0, 8 # 9
		add $t0, $t0, $t1
		
		li $t1, 10
		lb $t2, 0($t0)
		addi $t2, $t2, -48 # Get the actual value
		mul $t2, $t2, $t1  # Multiply the first digit by 10
		lb $t1, 1($t0)
		addi $t1, $t1, -48 # Get the actual value
		add $t2, $t2, $t1 # $t2 + $t1 = new value
		add $s2, $s2, $t2
		
		sb $s2, 0($s0)

		li $t1, 10
		div		$s2, $t1			# $s2 / $t1
		mflo	$t2					# $t2 = floor($s2 / $t1) ; first_digit
		mfhi	$t3					# $t3 = $s2 mod $t1 ; second_digit
		addi $t2, $t2, '0' # First digit ASCII
		addi $t3, $t3, '0' # Second digit ASCII

		sb $t2, 0($t0) # Update bot mancala (1st digit)
		sb $t3, 1($t0) # Update bot mancala (2nd digit)
		j return_cs
	top_player_cs:
		blez $s2, cs_err_stoneCount
		
		move $t0, $s0
		addi $t0, $t0, 6

		li $t1, 10
		lb $t2, 0($t0)
		addi $t2, $t2, -48 # Get the actual value
		mul $t2, $t2, $t1  # Multiply the first digit by 10
		lb $t1, 1($t0)
		addi $t1, $t1, -48
		add $t2, $t2, $t1 # $t2 + $t1 = new value
		add $s2, $s2, $t2
		
		sb $s2, 1($s0)


		li $t1, 10
		div		$s2, $t1			# $s2 / $t1
		mflo	$t2					# $t2 = floor($s2 / $t1) 
		mfhi	$t3					# $t3 = $s2 mod $t1 
		addi $t2, $t2, '0' # First digit ASCII
		addi $t3, $t3, '0' # Second digit ASCII

		sb $t2, 0($t0) # Update top mancala (1st digit)
		sb $t3, 1($t0) # Update top mancala (2nd digit)

		j return_cs
	return_cs:
		move $v0, $t6
		jr $ra
	cs_err_player:
		li $v0, -1
		jr $ra
	cs_err_stoneCount:
		li $v0, -2
		jr $ra
verify_move: # Uses $s0 = *state, $s1 = origin_pocket, $s2 = distance
	# int verify_move(GameState* state, byte origin_pocket, byte distance)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2

	lbu $t0, 2($s0) # Load num. of pockets
	sge $t1, $s1, $0 # if origin_pocket >= 0
	slt $t2, $s1, $t0 # if origin_pocket < num. of pockets
	and $t1, $t1, $t2 # if origin_pocket >= 0 && origin_pocket < num. of pockets
	beqz $t1, vm_err_invalid_origin
	# Otherwise, valid origin_pocket
	li $t0, 99
	beq		$t0, $s2, vm_other_turn	# if $t0 == $s2 then vm_other_turn
	addi $sp, $sp, -8
	sb $s1, 0($sp)
	sb $s2, -4($sp)
	sw $ra, -8($sp)
	move $a0, $s0
	lb $a1, 5($s0)
	move $a2, $s1
	jal get_pocket # *state, player, distance

	move $t0, $v0 # $t0 holds number of stones in the origin_pocket
	lb $s1, 0($sp)
	lb $s2, -4($sp)
	lw $ra, -8($sp)
	addi $sp, $sp, 8

	beqz $t0, vm_err_noStones # origin_pocket has 0 stones
	beqz $s2, vm_err_dist_neStones # distance = 0 then error
	bne		$s2, $t0, vm_err_dist_neStones	# if $s2 != $t0 then vm_err_dist_neStones
	li $v0, 1
	j return_verify_move
	vm_other_turn:
		# 1. Change to other player
		# 2. Increase moves_executed by 1
		lb $t0, 5($s0) # Get current player
		li $t1, 'B'
		beq $t0, $t1, change_to_T
		li $t1, 'T'
		beq $t0, $t1, change_to_B
		change_to_T:
			li $t1, 'T'
			sb $t1, 5($s0)
			j con_vm_other_turn
		change_to_B:
			li $t1, 'B'
			sb $t1, 5($s0)
			j con_vm_other_turn
		con_vm_other_turn:
			lb $t1, 4($s0) # Get moves executed
			addi $t1, $t1, 1 # increment by 1
			sb $t1, 4($s0) # Update moves_executed
			li $v0, 2
			j return_verify_move
	return_verify_move:
		jr  $ra
	vm_err_invalid_origin:
		li $v0, -1
		jr $ra
	vm_err_dist_neStones:
		li $v0, -2
		jr $ra
	vm_err_noStones:
		li $v0, 0
		jr $ra
execute_move: # Uses $s0 = *state, $s1 = origin_pocket, $s2 = currentPlayer, $s3 = num of stones, $s4 = current iteration, $s5 = Number of stones added to player's mancala, $s6 = player
	# int, int execute_move(GameState* state, byte origin_pocket)
	move $s0, $a0
	move $s1, $a1  

	lb $s2, 5($s0) # Get the current player
	li $t1, 'B'
	beq $s2, $t1, move_player_em # Bottom player moves
	li $t1, 'T'
	beq $s2, $t1, move_player_em # Top player moves

	move_player_em:
		# Implement how the bottom player moves
		# Increment mancala of bottom player if current player is bottom
		# 	Otherwise, skip it

		addi $sp, $sp, -24
		sw $s0, 0($sp)
		sb $s1, 4($sp)
		sb $s2, 8($sp)
		sb $s3, 12($sp)
		sb $s4, 16($sp)
		sw $ra, 20($sp)

		move $a0, $s0
		move $a1, $s2
		move $a2, $s1
		jal get_pocket # Get num of stones in the pocket for the player; Uses $s0 = *state, $s1 = player, $s2 = distance, $s3, $s4
		
		lw $s0, 0($sp)
		lb $s1, 4($sp)
		lb $s2, 8($sp)
		lb $s3, 12($sp)
		lb $s4, 16($sp)
		lw $ra, 20($sp)
		addi $sp, $sp, 24
		move $s3, $v0 # Store the number of stones to iterate through

		# Set the number of stones in the current pocket to 0 (Basically, pick up all the stones)
		addi $sp, $sp, -28
		sw $s0, 0($sp)
		sb $s1, 4($sp)
		sb $s2, 8($sp)
		sb $s3, 12($sp)
		sb $s4, 16($sp)
		sb $s5, 20($sp)
		sw $ra, 24($sp)

		move $a0, $s0 # *state
		move $a1, $s2 # player
		move $a2, $s1 # distance
		move $a3, $0 # size
		jal set_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3 = size, $s4, $s5

		lw $s0, 0($sp)
		lb $s1, 4($sp)
		lb $s2, 8($sp)
		lb $s3, 12($sp)
		lb $s4, 16($sp)
		lb $s5, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
		
		move $s6, $s2 # get a copy of the current player
		li $s4, 0 # Total number of stones added
		li $s5, 0 # Number of stones added to current player's mancala
		# addi $s1, $s1, -1 # Go to the next pocket
		
		loop_player_em:
		# 									move $a0, $s4
		# li $v0, 1
		# syscall
			beq $s4, $s3, exit_loop_em # Filled all the stones
			addi $s1, $s1, -1 # Go to the next pocket (Counter-clockwise)
			bltz $s1, iterate_like_T # If index is negative, then check mancala
			j after_iterate_like_T

			after_iterate_like_T:
				addi $sp, $sp, -24
				sw $s0, 0($sp)
				sb $s1, 4($sp)
				sb $s2, 8($sp)
				sb $s3, 12($sp)
				sb $s4, 16($sp)
				sw $ra, 20($sp)

				move $a0, $s0 # *state
				move $a1, $s6 # player
				move $a2, $s1 # distance
				jal get_pocket # Get num of stones in the pocket; Uses $s0 = *state, $s1 = player, $s2 = distance, $s3, $s4

				lw $s0, 0($sp)
				lb $s1, 4($sp)
				lb $s2, 8($sp)
				lb $s3, 12($sp)
				lb $s4, 16($sp)
				lw $ra, 20($sp)
				addi $sp, $sp, 24

				move $t0, $v0
				addi $t0, $t0, 1 # Increase stone by 1
				
				addi $sp, $sp, -28
				sw $s0, 0($sp)
				sb $s1, 4($sp)
				sb $s2, 8($sp)
				sb $s3, 12($sp)
				sb $s4, 16($sp)
				sb $s5, 20($sp)
				sw $ra, 24($sp)

				move $a0, $s0 # *state
				move $a1, $s6 # player
				move $a2, $s1 # distance
				move $a3, $t0 # size
				jal set_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3 = size, $s4, $s5

				lw $s0, 0($sp)
				lb $s1, 4($sp)
				lb $s2, 8($sp)
				lb $s3, 12($sp)
				lb $s4, 16($sp)
				lb $s5, 20($sp)
				lw $ra, 24($sp)
				addi $sp, $sp, 28
				
				# beq $s4, $s3, exit_loop_em # Filled all the stones
				addi $s4, $s4, 1 # Increment total number of stones added
				# addi $s1, $s1, -1 # Go to the next pocket (Counter-clockwise)
				
				j loop_player_em # Same procedure: Get the pocket and increment the pocket by 1
			
			iterate_like_T:
				beq $s6, $s2, add_to_mancala_em # If the relative player ($s6) matches the argument player ($s2) then add 1 to mancala
				j change_index # Otherwise, change the index (ignore mancala)

				change_index:
					li $t0, 'T'
					beq $t0, $s6, change_to_B_em
					li $t0, 'B'
					beq $t0, $s6, change_to_T_em
					change_to_B_em:
						li $s6, 'B'
						j continue_change_em
					change_to_T_em:
						li $s6, 'T'
						j continue_change_em
					continue_change_em:
						lb $s1, 2($s0) # Get the number of pockets
						addi $s1, $s1, -1 # num_of_pockets - 1 = last index
						j loop_player_em

				add_to_mancala_em: # Add stone to player's mancala
					addi $sp, $sp, -16
					sw $s0, 0($sp)
					sb $s1, 4($sp)
					sb $s2, 8($sp)
					sw $ra, 12($sp)

					move $a0, $s0
					move $a1, $s6
					li $a2, 1
					jal collect_stones # Uses $s0 = *state, $s1 = player, $s2 = stones

					lw $s0, 0($sp)
					lb $s1, 4($sp)
					lb $s2, 8($sp)
					lw $ra, 12($sp)
					addi $sp, $sp, 16
					
					addi $s5, $s5, 1 # The output (number of stones added to mancala)
					addi $s4, $s4, 1 # Increment total number of stones added
					j change_index
			
	exit_loop_em:
		# Increment moves executed by 1
		lb $t0, 4($s0)
		addi $t0, $t0, 1
		sb $t0, 4($s0)
		j after_change_turnTo

		after_change_turnTo:
			lb $t0, 2($s0)
			addi $t0, $t0, -1
			seq $t1, $s1, $t0 # current_index == last index of the pockets
			sne $t2, $s6, $s2 # If 1 then not equal
			and $t1, $t1, $t2 # if last deposit was in the Mancala
			bgtz $t1, last_dep_mancala
			beq $s6, $s2, check_empty_bef_dep
			move $v0, $s5
			li $v1, 0 # Deposit was somewhere else
			
			# Changes turn
			lb $t0, 5($s0)
			li $t1, 'B'
			beq $t0, $t1, change_turnTo_T_em
			li $t1, 'T'
			beq $t0, $t1, change_turnTo_B_em
			change_turnTo_B_em:
				li $t0, 'B'
				sb $t0, 5($s0)
				j ret_em_def
			change_turnTo_T_em:
				li $t0, 'T'
				sb $t0, 5($s0)
				j ret_em_def
			ret_em_def:
				jr $ra
			last_dep_mancala:
				lb $t0, 4($s0)
				addi $t0, $t0, 1
				sb $t0, 4($s0)
				move $v0, $s5
				li $v1, 2
				jr $ra
			check_empty_bef_dep:
				addi $sp, $sp, -24
				sw $s0, 0($sp)
				sb $s1, 4($sp)
				sb $s2, 8($sp)
				sb $s3, 12($sp)
				sb $s4, 16($sp)
				sw $ra, 20($sp)

				move $a0, $s0
				move $a1, $s6
				move $a2, $s1
				jal get_pocket # Get num of stones in the pocket; Uses $s0 = *state, $s1 = player, $s2 = distance, $s3, $s4
				move $t0, $v0 # Get the number of stones

				lw $s0, 0($sp)
				lb $s1, 4($sp)
				lb $s2, 8($sp)
				lb $s3, 12($sp)
				lb $s4, 16($sp)
				lw $ra, 20($sp)
				addi $sp, $sp, 24

				li $t1, 1
				beq $t0, $t1, original_empty # If the number of stones is 1, then the slot was originally empty
				li $v1, 0

				# Changes turn
				lb $t0, 5($s0)
				li $t1, 'B'
				beq $t0, $t1, change_turnTo_T_2em
				li $t1, 'T'
				beq $t0, $t1, change_turnTo_B_2em
				change_turnTo_B_2em:
					li $t0, 'B'
					sb $t0, 5($s0)
					j ret_check_empty_bef_dep
				change_turnTo_T_2em:
					li $t0, 'T'
					sb $t0, 5($s0)
					j ret_check_empty_bef_dep
				
				original_empty:
					# Changes turn
					move $t8, $s1
					li $v1, 1
					lb $t0, 5($s0)
					li $t1, 'B'
					beq $t0, $t1, change_turnTo_T_3em
					li $t1, 'T'
					beq $t0, $t1, change_turnTo_B_3em
					change_turnTo_B_3em:
						li $t0, 'B'
						sb $t0, 5($s0)
						j ret_check_empty_bef_dep
					change_turnTo_T_3em:
						li $t0, 'T'
						sb $t0, 5($s0)
						j ret_check_empty_bef_dep

				ret_check_empty_bef_dep:
					move $v0, $s5
					jr $ra
steal: # Uses $s0 = *state, $s1 = destination_pocket, $s2 = player, $s3 = number of stones
	# int steal(GameState* state, byte destination_pocket)
	move $s0, $a0
	move $s1, $a1
	li $s3, 0

	lb $t1, 5($s0)
	li $t0, 'B'
	beq $t0, $t1, changeToT_steal
	li $t0, 'T'
	beq $t0, $t1, changeToB_steal
	changeToB_steal:
		li $s2, 'B'
		j after_swap_steal
	changeToT_steal:
		li $s2, 'T'
		j after_swap_steal
	after_swap_steal:
	# Get the number of stones in the destination_pocket
		addi $sp, $sp, -20
		sw $s0, 0($sp)
		sb $s1, 4($sp)
		sb $s2, 8($sp)
		sb $s3, 12($sp)
		sw $ra, 16($sp)

		move $a0, $s0 # *state
		move $a1, $s2 # player
		move $a2, $s1 # distnace
		jal get_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3, $s4

		lw $s0, 0($sp)
		lb $s1, 4($sp)
		lb $s2, 8($sp)
		lb $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20

		add $s3, $s3, $v0
	# Set the number of stones in the destination_pocket to 0
		addi $sp, $sp, -20
		sw $s0, 0($sp)
		sb $s1, 4($sp)
		sb $s2, 8($sp)
		sb $s3, 12($sp)
		sw $ra, 16($sp)

		move $a0, $s0
		move $a1, $s2
		move $a2, $s1
		li $a3, 0
		jal set_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3 = size, $s4, $s5
	
		lw $s0, 0($sp)
		lb $s1, 4($sp)
		lb $s2, 8($sp)
		lb $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20

	# Get the number of stones in the opposite of the destination_pocket (n - i - 1)
		addi $sp, $sp, -20
		sw $s0, 0($sp)
		sb $s1, 4($sp)
		sb $s2, 8($sp)
		sb $s3, 12($sp)
		sw $ra, 16($sp)

		lb $t0, 2($s0) # n
		addi $t0, $t0, -1 # n - 1
		sub		$t0, $t0, $s1		# $t0 = $t0 - $s1; n - i - 1 =  n - 1 - i
		
		move $a0, $s0
		lb $a1, 5($s0)
		move $a2, $t0
		jal get_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3, $s4

		lw $s0, 0($sp)
		lb $s1, 4($sp)
		lb $s2, 8($sp)
		lb $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20

		add $s3, $s3, $v0 # Increment the total number of stones
	# Set the number of stones in the opposite of the destination_pocket to 0
		addi $sp, $sp, -20
		sw $s0, 0($sp)
		sb $s1, 4($sp)
		sb $s2, 8($sp)
		sb $s3, 12($sp)
		sw $ra, 16($sp)
	
		lb $t0, 2($s0) # n
		addi $t0, $t0, -1 # n - 1
		sub		$t0, $t0, $s1		# $t0 = $t0 - $s1; n - i - 1 =  n - 1 - i

		move $a0, $s0
		lb $a1, 5($s0)
		move $a2, $t0
		li $a3, 0
		jal set_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3 = size, $s4, $s5

		lw $s0, 0($sp)
		lb $s1, 4($sp)
		lb $s2, 8($sp)
		lb $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20
	
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sb $s1, -4($sp)
	sb $s2, -8($sp)
	sw $ra, -12($sp)

	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	jal collect_stones # Uses $s0 = *state, $s1 = player, $s2 = stones

	lw $s0, 0($sp)
	lb $s1, -4($sp)
	lb $s2, -8($sp)
	lw $ra, -12($sp)
	addi $sp, $sp, 16

	# $v0 = number of stones added to player's mancala
	move $v0, $s3
	lb $t0, 4($s0)
	addi $t0, $t0, 1
	sb $t0, 4($s0)
	jr $ra
check_row: # Uses $s0 = *state, $s1 = iterations, $s2 = max iterations, $s3 = from the top to the bottom/total_stones, $s4 = flags for (non-)empty, $s5 = player with empty mancala, $s6 = Exit
	# int check_row(GameState* state)
	move $s0, $a0

	li $s1, 0 # Keeps track of how many iterations done
	lb $s2, 2($s0) # Max. Number of iteration to go through
	sll $s2, $s2, 1 # Multiply by 2

	addi $s3, $s0, 8 # Go to the first pocket in the top mancala
	li $s4, 0 # If 1 then top row is empty, if 3 then top and bot are empty, if 4 then only bot row is empty otherwise, both rows are not empty
	li $s5, 'T' # The player with the empty mancala
	li $s6, -1 # Exit command (i.e. both rows checked) when 1

	loop_check_row:
		# bgtz $s6, exit_loop_cr # Exit; Looked through both rows
		beq $s1, $s2, check_other_row_cw

		lb $t0, 0($s3)
		li $t1, '0'
		bne $t0, $t1, row_not_empty_cr1 # Non-empty row found
		
		# Empty so far. Get next char
		addi $s3, $s3, 1
		addi $s1, $s1, 1
		j loop_check_row

		check_other_row_cw:
			addi $s4, $s4, 1 # Top/Bot is empty
			li $t0, 'T'
			beq $t0, $s5, check_bot_cr # Check bot_player's pockets
			addi $s4, $s4, 2 # Bot row is empty
			j exit_loop_cr # Exit
		row_not_empty_cr1:
			li $t0, 'T'
			beq $t0, $s5, check_bot_cr # Check bot_player's pockets
			j exit_loop_cr # Otherwise, exit
			check_bot_cr:
				li $s5, 'B'
				li $s1, 0 # reset index to 0
				addi $s3, $s0, 8
				add $s3, $s3, $s2 # Go to the bot_row
			c_row_not_empty_cr1:
				addi $s6, $s6, 1
				j loop_check_row
	exit_loop_cr:
		# cases: 0 = non-empty, 1 = top-empty, 3 = bot-empty, 4 = both-empty
		li $v0, 0
		beqz $s4, none_empty_cr
		li $t0, 4
		beq $s4, $t0, both_empty_cr
		li $t0, 1
		beq $s4, $t0, only_top_empty_cr
		li $t0, 3
		beq $s4, $t0, only_bot_empty_cr
		j end		
		only_top_empty_cr:
			# Move all stones from bot_pockets to bot_mancala
			li $s1, 0
			lb $s2, 2($s0)
			li $s3, 0
			loop_only_top_cr:
				beq $s1, $s2, exit_loop_only_top_cr

				addi $sp, $sp, -20
				sw $s0, 0($sp)
				sb $s1, 4($sp)
				sb $s2, 8($sp)
				sb $s3, 12($sp)
				sw $ra, 16($sp)

				move $a0, $s0
				li $a1, 'B'
				move $a2, $s1
				jal get_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3, $s4

				lw $s0, 0($sp)
				lb $s1, 4($sp)
				lb $s2, 8($sp)
				lb $s3, 12($sp)
				lw $ra, 16($sp)
				addi $sp, $sp, 20

				add $s3, $s3, $v0 # Collect the total number of stones to add to mancala

				# move $a0, $s3
				# li $v0, 1
				# syscall

				# li $v0, 0
				bnez $v0, set_p_only_top
				j cont_loop_only_top

				set_p_only_top:
					addi $sp, $sp, -20
					sw $s0, 0($sp)
					sb $s1, 4($sp)
					sb $s2, 8($sp)
					sb $s3, 12($sp)
					sw $ra, 16($sp)

					move $a0, $s0
					li $a1, 'B'
					move $a2, $s1
					move $a3, $0
					jal set_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3 = size, $s4, $s5

					lw $s0, 0($sp)
					lb $s1, 4($sp)
					lb $s2, 8($sp)
					lb $s3, 12($sp)
					lw $ra, 16($sp)
					addi $sp, $sp, 20

				cont_loop_only_top:
					addi $s1, $s1, 1 # Go to the next index
					j loop_only_top_cr

			exit_loop_only_top_cr:
				addi $sp, $sp, -16
				sw $s0, 0($sp)
				sb $s1, 4($sp)
				sb $s2, 8($sp)
				# sb $s3, -12($sp)
				sw $ra, 12($sp)

				move $a0, $s0
				li $a1, 'B'
				move $a2, $s3
				jal collect_stones # Uses $s0 = *state, $s1 = player, $s2 = stones

				lw $s0, 0($sp)
				lb $s1, -4($sp)
				lb $s2, -8($sp)
				# lb $s3, -12($sp)
				lw $ra, -12($sp)
				addi $sp, $sp, 16

				li $v0, 1
				j none_empty_cr
		only_bot_empty_cr:
			# Move all stones from top_pockets to top_mancala
			li $s1, 0
			lb $s2, 2($s0)
			li $s3, 0
			loop_only_bot_cr:
				beq $s1, $s2, exit_loop_only_bot_cr

				addi $sp, $sp, -20
				sw $s0, 0($sp)
				sb $s1, 4($sp)
				sb $s2, 8($sp)
				sb $s3, 12($sp)
				sw $ra, 16($sp)

				move $a0, $s0
				li $a1, 'T'
				move $a2, $s1
				jal get_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3, $s4

				lw $s0, 0($sp)
				lb $s1, 4($sp)
				lb $s2, 8($sp)
				lb $s3, 12($sp)
				lw $ra, 16($sp)
				addi $sp, $sp, 20

				add $s3, $s3, $v0 # Collect the total number of stones to add to mancala

				# move $a0, $s1
				# li $v0, 1
				# syscall

				bnez $v0, set_p_only_bot
				j cont_loop_only_bot

				set_p_only_bot:
					addi $sp, $sp, -20
					sw $s0, 0($sp)
					sb $s1, 4($sp)
					sb $s2, 8($sp)
					sb $s3, 12($sp)
					sw $ra, 16($sp)

					move $a0, $s0
					li $a1, 'T'
					move $a2, $s1
					move $a3, $0
					jal set_pocket # Uses $s0 = *state, $s1 = player, $s2 = distance, $s3 = size, $s4, $s5

					lw $s0, 0($sp)
					lb $s1, 4($sp)
					lb $s2, 8($sp)
					lb $s3, 12($sp)
					lw $ra, 16($sp)
					addi $sp, $sp, 20

				cont_loop_only_bot:
					addi $s1, $s1, 1 # Go to the next index
					j loop_only_bot_cr

			exit_loop_only_bot_cr:
				addi $sp, $sp, -16
				sw $s0, 0($sp)
				sb $s1, -4($sp)
				sb $s2, -8($sp)
				# sb $s3, -12($sp)
				sw $ra, -12($sp)

				move $a0, $s0
				li $a1, 'T'
				move $a2, $s3
				jal collect_stones # Uses $s0 = *state, $s1 = player, $s2 = stones

				lw $s0, 0($sp)
				lb $s1, -4($sp)
				lb $s2, -8($sp)
				# lb $s3, -12($sp)
				lw $ra, -12($sp)
				addi $sp, $sp, 16
				
				li $v0, 1
				j none_empty_cr
	both_empty_cr:
		li $v0, 1
		j none_empty_cr
	none_empty_cr:
		lb $t0, 0($s0) # Player 1's mancala
		lb $t1, 1($s0) # Player 2's mancala
		bgt $t0, $t1, gt_cr # bot_player > top_player
		blt $t0, $t1, lt_cr # top > bot
		li $v1, 0 # top == bot
		jr $ra
		gt_cr:
			li $v1, 1
			jr $ra
		lt_cr:
			li $v1, 2
			jr $ra
load_moves: # Uses $s0 = moves, $s1 = filename, $s2 = file descriptor, $s3 = input buffer, $s4 = columns, $s5 = rows, $s6 = total number of moves, $s7 = copy of moves[] address
	# int load_moves(byte[] moves, string filename)
	move $s0, $a0 # Address of moves[]
	move $s1, $a1
	move $s7, $s0 # Copy of addr of moves[]

	move $a0, $s1 # $a0 = filename address
	li $a1, 0  # $a1 = flag (Read-only)
	li $a2, 0 # Ignore mode
	li $v0, 13 # Open file
	syscall
	blez $v0, file_not_found_lm # $v0, $v1 = -1 (File does not exist)
	move $s2, $v0 # $s2 has file descriptor

	li $t9, 0 # FLAG TO SKIP AFTER FIRST DIGIT (if 1 then skip)
	li $s3, 0 # Number of moves added
	li $t4, 0 # Make the number
	li $t5, 0 # Layout_counter (rows)
	li $t6, 0 # Row Counter
	li $t7, 0 # Column Counter
	li $s4, 0 # Total Rows
	li $s5, 0 # Total Columns
	loop_lm:
		li $t1, 1
		ble $t5, $t1, ignore_lm	# if $t5 <= $t1 then ignore_lm
			# 						move $a0, $s4
			# li $v0, 1
			# syscall
			# j end
		beq $t6, $s4, exit_loop_lm
		beq $t7, $s5, next_row_loop_lm
		ignore_lm:

		addi $sp, $sp, -4 # allocate sp to hold 1 character
		li $v0, 14 # Read file
		move $a0, $s2 # File descriptor
		move $a1, $sp # File Buffer
		li $a2, 1 # Read 1 character at a time
		syscall # Put the character in the stack pointer
		
		lw $t0, 0($sp) # $t0 holds the digit in ascii
		beqz $v0, exit_loop_em
		# move $a0, $t0
		# li $v0, 1
		# syscall
		addi $sp, $sp, 4 # Deallocate before doing anything else
		bnez $t9, flag_toggle_lm
		j ignore_flag_lm
		flag_toggle_lm: # Skip the next digit
			li $t9, 0
			j loop_lm
		ignore_flag_lm:
		li $t1, '\r'
		beq $t1, $t0, loop_lm # Ignore '\r'
		li $t1, '\n'  # \n = Go to next row
		beq $t1, $t0, next_row_inFile_lm

		beqz $t5, get_columns_lm # First row in file
		li $t1, 1
		beq $t5, $t1, get_rows_lm # Second row in file
		
		# This is the 3rd row
		# if column_counter % 2 == 0 -> First-digit otherwise second-digit
		li $t1, 2
		div		$t7, $t1			# $t7 / $t1
		mfhi	$t2					# $t3 = $t0 mod $t1
		beqz $t2, first_digit_lm
		# Otherwise, Second digit
		li $t1, '0'
		sge $t1, $t0, $t1 # if digit >= '0'
		li $t2, '9'
		sle $t2, $t0, $t2 # if digit <= '9'
		and $t1, $t1, $t2 # if digit >= '0' and digit <= '9'
		beqz $t1, set_invalid2_lm # Invalid move
		
		# Assume valid digit
		li $t1, 10
		mul $t4, $t4, $t1
		li $t1, '0'
		sub $t0, $t0, $t1 # Get the real value
		add $t4, $t4, $t0
		# $t4 has the properly formatted number
		sb $t4, 0($s7) # Store in the moves array
			# move $a0, $s7
			# li $v0, 1
			# syscall
			# li $a0, '\n'
			# li $v0, 11
			# syscall
		addi $s7, $s7, -1 # Go to the next spot in the array
		addi $s3, $s3, 1 # Increment number of moves added
		j continue_loop_lm
		first_digit_lm:
			li $t1, '0'
			sge $t1, $t0, $t1 # if digit >= '0'
			li $t2, '9'
			sle $t2, $t0, $t2 # if digit <= '9'
			and $t1, $t1, $t2 # if digit >= '0' and digit <= '9'
			beqz $t1, set_invalid_lm # Invalid move
			li $t1, '0'
			sub $t4, $t0, $t1 # Get the real value and store the first digit in $t4
			j continue_loop_lm
			set_invalid_lm:
				li $t1, -1
				sb $t1, 0($s7) # Store as -1 for invalid
				addi $s7, $s7, -1 # Go to the next spot in the moves[] array
				# TODO: ADD FLAG
				li $t9, 1
				addi $t7, $t7, 2 # Go to the next column (+2 characters over)
				li $t4, 0
				addi $s3, $s3, 1 # Increment number of moves added
				j loop_lm
			set_invalid2_lm:
				li $t1, -1
				sb $t1, 0($s7) # Store as -1 for invalid
				addi $s7, $s7, -1 # Go to the next spot in the moves[] array
				addi $t7, $t7, 1 # Go to the next column (+1 characters over)
				li $t4, 0 # Reset number maker
				addi $s3, $s3, 1 # Increment number of moves added
				j loop_lm
		continue_loop_lm:
			addi $t7, $t7, 1  # Increase column counter
			j loop_lm
		next_row_loop_lm:
			addi $t6, $t6, 1 # Increase row counter by 1
			# Add 99 to moves array and incrememnt total moves by 1
			li $t1, 99
			sb $t1, 0($s7)
			addi $s7, $s7, -1
			addi $s3, $s3, 1
			li $t7, 0 # Reset column counter to 0
			j loop_lm
		get_columns_lm:
			li $t1, 10
			mul $t4, $t4, $t1 # Multiply current sum by 10
			li $t1, '0'
			sub $t0, $t0, $t1 # Subtract by '0' to get the "REAL" Value
			add $t4, $t4, $t0 # sum += digit
			j loop_lm
		get_rows_lm:
			li $t1, 10
			mul $t4, $t4, $t1 # Multiply current sum by 10
			li $t1, '0'
			sub $t0, $t0, $t1 # Subtract by '0' to get the "REAL" Value
			add $t4, $t4, $t0 # sum += digit
			# move $a0, $t0
			# li $v0, 1
			# syscall
			# j end
			j loop_lm
		next_row_inFile_lm:
			beqz $t5, set_columns_lm
			li $t0, 1
			beq $t5, $t0, set_rows_lm
			set_columns_lm:
				move $s5, $t4
				sll $s5, $s5, 1 # Multiply by 2 to iterate over characters
				j c_next_row_inFile
			set_rows_lm:
				move $s4, $t4
				j c_next_row_inFile
			c_next_row_inFile:
				addi $t5, $t5, 1
				li $t4, 0 # Reset number maker
				j loop_lm
	exit_loop_lm:
		# Exited the loop. Do stuff here?
		addi $s3, $s3, -1
		move $v0, $s3
		jr $ra
	file_not_found_lm:
		li $v0, -1
		jr $ra
play_game: # Extra: $s0-$s4 + $s5, $s6, $s7
	# int, int play_game (string moves_filename, string board_filename, GameState* state, byte[] moves, int num_moves_to_execute)
	move $s0, $a2 # *state
	move $s1, $a1 # board_filename
	move $s2, $a0 # moves_filename
	move $s3, $a3 # addr. to moves[]
	lw $s4, 0($sp) # num_moves_to_execute

	addi $sp, $sp, -28
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $ra, 24($sp)
	move $t8, $ra
	
	move $a0, $s0
	move $a1, $s1
	jal load_game # $s0-$s5

	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	move $ra, $t8

	blez $v0, file_error
	blez $v1, file_error

	addi $sp, $sp, -36
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sb $s5, 20($sp)
	sb $s6, 24($sp)
	sb $s7, 28($sp)
	sw $ra, 32($sp)
	move $t8, $ra

	move $a0, $s3 # Address to moves
	move $a1, $s2
	jal load_moves # $s0-$s7

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lb $s5, 20($sp)
	lb $s6, 24($sp)
	lb $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
	move $ra, $t8

	blez $v0, file_error
	move $s5, $v0 # number of moves in array
	
	# if num_moves_to_execute < arr_size (use arr_size iterations)
	# if arr_size >= num_moves_to_execute (use num_moves_to_execute)
	blt $s4, $s5, use_arr_size
	j ignore_arr_size # Otherwise, execute the number of moves
	use_arr_size:
		move $s4, $s5 # Use arr_size as num. of iterations
	ignore_arr_size:
		# Free $s6
		li $s7, 0 # Total Num. of moves done (inc. invalid)
		loop_play_game:
			lb $t0, 4($s0)
			bge $t0, $s4, preexit_loop_play_game # Max number of moves reached
			bge $s7, $s5, preexit_loop_play_game # Reached the end of the array, exit; num of moves done < $s5
			lb $t0, 0($s3) # Get the move from array
			bltz $t0, continue_loop_play_game # If there is an invalid move, skip it
			
			addi $sp, $sp, -24
			sw $s0, 0($sp)
			sw $s1, 4($sp)
			sw $s2, 8($sp)
			sw $s3, 12($sp)
			sw $s4, 16 ($sp)
			sw $ra, 20($sp)

			move $a0, $s0
			lb $a1, 5($s0)
			move $a2, $t0
			jal get_pocket # s0-s4

			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16 ($sp)
			lw $ra, 20($sp)
			addi $sp, $sp, 24
			move $s6, $v0

			addi $sp, $sp, -20
			sw $s0, 0($sp)
			sw $s1, 4($sp)
			sw $s2, 8($sp)
			sw $ra, 12($sp)
			move $t8, $ra

			move $a0, $s0
			lb $a1, 0($s3) # origin_pocket
			move $a2, $s6 # Stones in origin_pocket
			jal verify_move # s0-s2

			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $ra, 12($sp)
			addi $sp, $sp, 20
			move $ra, $t8
			move $s6, $v0 # store output in $s6
			
			# verify_move: if output is 1, then execute the move, if 2 then continue_loop (change turn), otherwise check_row
			li $t0, 2
			beq $t0, $s6, continue_loop_play_game # move = 99
			li $t0, 1
			beq $t0, $s6, exe_pg # execute the move
			j continue_loop_play_game
			exe_pg:
				addi $sp, $sp, -36
				sw $s0, 0($sp)
				sw $s1, 4($sp)
				sw $s2, 8($sp)
				sw $s3, 12($sp)
				sw $s4, 16($sp)
				sb $s5, 20($sp)
				sb $s6, 24($sp)
				sw $ra, 28($sp)

				move $a0, $s0
				lb $a1, 0($s3)
				jal execute_move # Uses $s0 = *state, $s1 = origin_pocket, $s3-$s6

				lw $s0, 0($sp)
				lw $s1, 4($sp)
				lw $s2, 8($sp)
				lw $s3, 12($sp)
				lw $s4, 16($sp)
				lb $s5, 20($sp)
				lb $s6, 24($sp)
				lw $ra, 28($sp)
				addi $sp, $sp, 36
				
				move $s6, $v0 # s6 has output
				li $t0, 1
				beq $s6, $t0, steal_exe # Execute Steal
				j out_exe_pg
				steal_exe:
					# lb $s6, 0($sp)
					# addi $sp, $sp, 4
					move $s6, $t8
					addi $sp, $sp, -24
					sw $s0, 0($sp)
					sw $s1, 4($sp)
					sw $s2, 8($sp)
					sw $s3, 12($sp)
					sw $ra, 16($sp)
					
					move $a0, $s0
					move $a1, $s6 # Destination pocket
					jal steal # s0-s3

					lw $s0, 0($sp)
					lw $s1, 4($sp)
					lw $s2, 8($sp)
					lw $s3, 12($sp)
					lw $ra, 16($sp)
					addi $sp, $sp, 24
					j out_exe_pg
			out_exe_pg:
				addi $sp, $sp, -36
				sw $s0, 0($sp)
				sw $s1, 4($sp)
				sw $s2, 8($sp)
				sw $s3, 12($sp)
				sw $s4, 16($sp)
				sb $s5, 20($sp)
				sb $s6, 24($sp)
				sw $ra, 28($sp)

				move $a0, $s0 # *state
				jal check_row # s0-s6

				lw $s0, 0($sp)
				lw $s1, 4($sp)
				lw $s2, 8($sp)
				lw $s3, 12($sp)
				lw $s4, 16($sp)
				lb $s5, 20($sp)
				lb $s6, 24($sp)
				lw $ra, 28($sp)
				addi $sp, $sp, 36
				move $s6, $v0
				li $t0, 1
				beq $t0, $s6, exit_loop_play_game # If $v0 == 1 (game over), game result is in $v1
			continue_loop_play_game:
				addi $s4, $s4, -1 # Go to the next move
				addi $s7, $s7, 1 # Increase total num. of moves done
			preexit_loop_play_game:
				li $v0, 0
				lb $v1, 4($s0)
				jr $ra
		exit_loop_play_game:
			move $v0, $v1
			lb $v1, 4($s0)
			jr $ra
	file_error:
		li $v0, -1
		li $v1, -1
		jr $ra
print_board: # Uses $s0 = *state
	# void print_board(GameState* state)
	move $s0, $a0

	move $t6, $s0
	addi $t6, $t6, 6

	lbu $a0, 0($t6) # First character in game_board
	li $v0, 11
	syscall

	lbu $a0, 1($t6) # Second character in game_board
	li $v0, 11
	syscall

	li $a0, '\n'
	li $v0, 11
	syscall
	
	addi $t6, $t6, 2
	lbu $t0, 2($s0) # bot_pockets
	sll $t0, $t0, 1 # Multiply by 2
	li $t1, 0 # # of players done
	li $t3, 0 # Number of characters read
	loop_print_board:
		li $t2, 2 # Only 2 players!
		beq $t1, $t2, exit_loop_pb # Leave loop
		beq $t3, $t0, new_line_pb # Reached the end of the first player's mancala
		
		lbu $a0, 0($t6)
		li $v0, 11
		syscall
		
		j cont_loop_pb
		
		new_line_pb:
			li $a0, '\n'
			li $v0, 11
			syscall

			addi $t1, $t1, 1 # next player
			li $t3, 0
			j loop_print_board

		cont_loop_pb:
			addi $t3, $t3, 1
			addi $t6, $t6, 1 # Get next character
			j loop_print_board

	exit_loop_pb:
		lbu $a0, 0($t6) # Penultimate character in game_board
		li $v0, 11
		syscall

		lbu $a0, 1($t6) # Last character in game_board
		li $v0, 11
		syscall

	jr $ra
write_board: # Uses $s0 = *state, $s1 = address of heap memory, $s2 = iteration, $s3 = max. itereations, $s6 = file descriptor
	# int write_board(GameState* state)
	move $s0, $a0

	li $a0, 11
	li $v0, 9
	syscall

	move $s1, $v0 # Address of heap memory
	li $t0, 'o'
	sb $t0, 0($s1)
	li $t0, 'u'
	sb $t0, 1($s1)
	li $t0, 't'
	sb $t0, 2($s1)
	li $t0, 'p'
	sb $t0, 3($s1)
	li $t0, 'u'
	sb $t0, 4($s1)
	li $t0, 't'
	sb $t0, 5($s1)
	li $t0, '.'
	sb $t0, 6($s1)
	li $t0, 't'
	sb $t0, 7($s1)
	li $t0, 'x'
	sb $t0, 8($s1)
	li $t0, 't'
	sb $t0, 9($s1)

	move $t0, $s1

	li $v0, 13
	move $a0, $t0 # output_file_name
	li $a1, 9 # write-only with create and append
	li $a2, 0 # Ignore mode
	syscall # Open file
	move $s6, $v0 # $s6 has file descriptor
	bltz $s6, file_err_wb

	li $v0, 15
	move $a0, $s6 # File Descriptor
	
	move $t0, $s1
	addi $t0, $t0, 11
	lb $t1, 6($s0)
	sb $t1, 0($t0)

	move $a1, $t0 # Address of buffer to write
	li $a2, 1 # Buffer Length
	syscall # Write the first digit of the top_mancala

	li $v0, 15
	move $a0, $s6
	move $t0, $s1
	addi $t0, $t0, 11
	lb $t1, 7($s0)
	sb $t1, 0($t0)

	move $a1, $t0 # Address of buffer to write
	li $a2, 1 # Buffer Length
	syscall # 2nd digit of the top_mancala
	
	li $v0, 15
	move $a0, $s6
	move $t0, $s1
	addi $t0, $t0, 11
	li $t1, '\n'
	sb $t1, 0($t0)

	move $a1, $t0 # Address of buffer to write
	li $a2, 1 # Buffer Length
	syscall # 2nd digit of the top_mancala

	move $t0, $s0
	addi $t0, $t0, 8 # Go to the top pocket
	li $s2, 0 # Index counter
	lb $s3, 2($s0) # max iterations
	sll $s3, $s3, 1 # Multiply by 2
	li $t3, 0 # Player 1
	li $t4, 2 # Max. of 2 players

	# Write to file
	write_board_loop:
		beq $t3, $t4, exit_loop_wb
		beq $s2, $s3, next_row_wb # If reached the end of the row

		li $v0, 15
		move $a0, $s6
		move $t6, $s1 # Copy heap_alloc addr
		addi $t6, $t6, 11 # Go to the last spot
		lb $t1, 0($t0) # Get the character to print to file
		sb $t1, 0($t6) # Store the character in the addr

		move $a1, $t6 # Address of buffer to write
		li $a2, 1 # Buffer Length
		syscall

		addi $s2, $s2, 1 # Increase the counter
		addi $t0, $t0, 1 # Get next character
		j write_board_loop

		next_row_wb:
			li $v0, 15
			move $a0, $s6
			move $t6, $s1 # Copy heap_alloc addr
			addi $t6, $t6, 11 # Go to the last spot
			li $t1, '\n'
			sb $t1, 0($t6) # Store the character in the addr

			move $a1, $t6 # Address of buffer to write
			li $a2, 1 # Buffer Length
			syscall
		
			addi $t3, $t3, 1 # Increase counter for row
			# move $t0, $s3 # Go to the last index of the bot_mancala
			li $s2, 0 # Reset counter
			j write_board_loop
	exit_loop_wb:
		# TODO: ADD the last 2 digits of the bot mancala
		li $v0, 15
		move $a0, $s6
		move $t6, $s1 # Copy heap_alloc addr
		addi $t6, $t6, 11 # Go to the last spot
		lb $t1, 0($t0) # Get the character to print to file
		sb $t1, 0($t6) # Store the character in the addr

		move $a1, $t6 # Address of buffer to write
		li $a2, 1 # Buffer Length
		syscall

		addi $t0, $t0, 1
		
		li $v0, 15
		move $a0, $s6
		move $t6, $s1 # Copy heap_alloc addr
		addi $t6, $t6, 11 # Go to the last spot
		lb $t1, 0($t0) # Get the character to print to file
		sb $t1, 0($t6) # Store the character in the addr

		move $a1, $t6 # Address of buffer to write
		li $a2, 1 # Buffer Length
		syscall


		li $v0, 16 # Close file
		move $a0, $s6 # File descriptor to close
		syscall # Close Completely

		addi $s1, $s1, -11 # Deallocate heap memory

		li $v0, 1
		jr $ra
		file_err_wb:
			li $v0, -1
			jr $ra
end:
	li $v0, 10
	syscall
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
