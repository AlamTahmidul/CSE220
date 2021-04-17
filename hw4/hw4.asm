############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

str_len: # Uses $s0 = *str
	# int str_len(char* str)
	move $s0, $a0
	li $t0, 0
	loop_strlen:
		lb $t1, 0($s0)
		beqz $t1, exit_loop_strlen
		addi $t0, $t0, 1 # increase counter
		addi $s0, $s0, 1 # Get next character
		j loop_strlen
	exit_loop_strlen:
		move $v0, $t0
	jr $ra
str_equals:
	jr $ra
str_cpy: # Uses $s0 = *src, $s1 = *dest
	# int str_cpy(char* src, char* dest)
	
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