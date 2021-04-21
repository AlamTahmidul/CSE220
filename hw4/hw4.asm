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
str_cpy: # Uses $s0 = *src, $s1 = *dest
	# int str_cpy(char* src, char* dest)
	move $s0, $a0
	move $s1, $a1

	move $t4, $s0 # Copy the string
	move $t5, $s1
	loop_str_copy:
		lbu $t0, 0($t4)
		beqz $t0, exit_loop_str_copy
		sb	$t0, 0($t5)	# Copy character to the destination character

		addi $t5, $t5, 1 # Go to the next empty space
		addi $t4, $t4, 1 # Go to the next character
		j loop_str_copy
	exit_loop_str_copy:
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $s0, 4($sp)

		move $a0, $s1
		jal str_len
		
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		addi $sp, $sp, 8

		# $v0 should have the length of the string
		jr $ra
create_person:
	jr $ra
is_person_exists:
	jr $ra
is_person_name_exists:
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