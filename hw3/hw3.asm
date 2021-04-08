# Tahmidul Alam
# tmalam
# 112784865

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text
load_game: # Uses $s0, $s1, $s2, $s3
	# int, int load_game(GameState* state, string filename) $a0, $a1

	move $s0, $a0 # $s0 has *state
	move $s1, $a1 # $s1 has filename

	# Open File
	move $a0, $a1 # $a0 = filename adress
	li $a1, 0  # $a1 = flag (Read-only)
	li $a2, 0 # Ignore mode
	li $v0, 13 # Open file
	syscall
	blez $v0, file_dne # $v0 = -1 (File does not exist)
	move $s2, $v0 # $s2 has file descriptor
	
	li $t2, 1 # $t2 holds row #: 1 = 1st row, ..., 5 = 5th row
	load_game_loop:
		addi $sp, $sp, -4 # allocate sp
		move $s3, $sp # $s3 has Address of "buffer" ($sp)
		li $v0, 14 # Read file
		move $a0, $s2 # File descriptor
		move $a1, $s3 # File Buffer
		li $a2, 1 # Read 1 character at a time
		syscall

		li $t0, '\r'
		li $t1, '\n'
		lw $t3, 0($sp) # $t3 Holds character
		add $sp, $sp, 4 # Deallocate sp before doing anything else
		beq $a0, $t0, cont_load_game_loop # If \r, then ignore
		beq $a0, $t1, branch_row # Perform appropriate computation if \n
		cont_load_game_loop:
			j load_game_loop
		
		branch_row: # rows 1-3 have a single number; $t3 holds character
			li $t0, '1'
			li $t1, '3'
			sge $t4, $t2, $t0 # currentRowNumber >= 1
			sle $t5, $t2, $t1 # currentRowNumber <= 3
			and $t4, $t4, $t5 # $t4 is 1 <= currentRowNumber <= 3
			beqz $t4, row_13_lg # If 0, then false else true
			li $t0, '4'
			li $t1, '5'
			beq $t2, $t0, row_4_lg # Go to Row 4 analysis
			beq $t2, $t0, row_5_lg # Go to row 5 analysis
		row_13_lg:
			# Do something
			addi $t2, $t2, 1 # Increase row counter by 1
			j cont_load_game_loop # Go to the last row
		row_4_lg:
			# Do something
			addi $t2, $t2, 1 # Increase row counter by 1
			j cont_load_game_loop # Go to the last row
		row_5_lg:
			# Do something
			
	end_loop_game:
		jr $ra
	file_dne:
		li $t0, -1
		move $v0, $t0
		move $v1, $t0
		jr $ra
get_pocket:
	jr $ra
set_pocket:
	jr $ra
collect_stones:
	jr $ra
verify_move:
	jr  $ra
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
print_board:
	jr $ra
write_board:
	jr $ra
	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
