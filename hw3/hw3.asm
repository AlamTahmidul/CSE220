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

	li $t0, 'B'
	beq		$t0, $s1, bot_player_cs	# if $t0 == $s1 then valid_player_cs
	li $t0, 'T'
	beq		$t0, $s1, top_player_cs	# if $t0 == $s1 then valid_player_cs
	j cs_err_player
	bot_player_cs:
		blez $s2, cs_err_stoneCount
		sb $s2, 0($s0)
		lb $t1, 2($s0)  # Load number of pockets
		sll $t1, $t1, 2 # Multiply by 4
		move $t0, $s0
		addi $t0, $t0, 9
		add $t0, $t0, $t1

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
		sb $s2, 1($s0)
		move $t0, $s0
		addi $t0, $t0, 6

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
		move $v0, $s2
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
	addi $sp, $sp, -8
	sb $s1, 0($sp)
	sb $s2, -4($sp)
	sw $ra, -8($sp)
	move $a0, $s0
	lb $a1, 5($s0)
	move $a2, $s2
	jal get_pockets # *state, player, distance
	move $t0, $v0 # $t0 holds number of stones in the origin_pocket
	lb $s1, 0($sp)
	lb $s2, -4($sp)
	lw $ra, -8($sp)
	addi $sp, $sp, 8

	

	return_verify_move:
		jr  $ra
	vm_err_invalid_origin:
		li $v0, -1
		jr $ra
execute_move:
	jr $ra
steal:
	jr $ra
check_row:
	jr $ra
load_moves:
	jr $ra
play_game:
	jr  $ra
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
write_board:
	jr $ra
end:
	li $v0, 10
	syscall
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
