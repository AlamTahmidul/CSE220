.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"

arg1_addr : .word 0
arg2_addr : .word 0
num_args : .word 0

PreText : .ascii "1."

.text:
.globl main
main:
	sw $a0, num_args

	lw $t0, 0($a1)
	sw $t0, arg1_addr
	lw $s1, arg1_addr

	lw $t1, 4($a1)
	sw $t1, arg2_addr
	lw $s2, arg2_addr

	j start_coding_here

# do not change any line of code above this section
# you can add code to the .data section
start_coding_here:
	# s0 holds arg1
	# s1 holds arg2
	lw $t0, num_args
	li $t1, 2
	bne $t0, $t1, invalid_num_args # 1. Exactly 2 Arguments
	
	lw $s0, arg1_addr # $s0 is the arg1_addr
	lw $s1, arg2_addr # $s1 is the arg2_addr
	
	lbu $t0, 0($s0) # $t0 (temporary) holds the first character
	
	
	# Check for input
	li $t1, 79 # O
	li $t2, 83 # S
	li $t3, 84 # T
	li $t4, 73 # I
	
	# I-Type (O,S,T,I)
	beq $t0, $t1, operation_O
	beq $t0, $t2, operation_S
	beq $t0, $t3, operation_T
	beq $t0, $t4, operation_I
	
	li $t1, 69 # E
	li $t2, 67 # C
	li $t3, 88 # X
	li $t4, 77 # M
	
	# Odd/Even (E)
	beq $t0, $t1, operation_E
	
	# Counting (C)
	beq $t0, $t2, operation_C
	
	# Floating-Point Exponent (X, M)
	beq $t0, $t3, operation_X
	beq $t0, $t4, operation_M
	
	# 2. Must be invalid
	beq $t0, $t4, invalid_input

	# 3. arg2 check
	arg2_check:
	lw $s3, arg2_addr
	li $t2, 0 # i = 0
	li $t3, 8 # hex-value (num of digits)
	
	li $t4, 48 # 0
	li $t5, 120 # x
	lbu $t1, 0($s3) # arg2[0]
	bne $t1, $t4, invalid_input # if 0 != arg2[0] then invalid
	lbu $t1, 1($s3) # arg2[1]
	bne $t1, $t5, invalid_input # if x != arg2[1] then invalid
	addi $s3, $s3, 2 # Move over 2 characters

		arg2_loop:
			beqz $t1, return_fail # If the end of the string is reached
			lbu $t1, 0($s3) # arg[i]
			# Process
			# Done: Check for 0-9 and A-F
			check_digit:
				li $t4, 48 # 0
				sge $t7, $t1, $t4 # arg2[i] >= 0
				li $t4, 57 # 9
				sle $t6, $t1, $t4 # arg2[i] <= 9
				and $t6, $t6, $t7 # (arg2[i] >= 0 && arg2[i] <= 9)
			check_letter:
				li $t5, 65 # A
				sge $t7, $t1, $t5 # arg2[i] >= A
				or $t7, $t7, $t6 # (arg2[i] >= 0 && arg2[i] <= 9 || arg2[i] >= A)
				li $t5, 70 # F
				sle $t6, $t1, $t5 # arg2[i] <= F
				and $t7, $t7, $t6 # (arg2[i] >= 0 && arg2[i] <= 9 || arg2[i] >= A && arg2[i] <= F)
				beqz $t7, invalid_input
			
			# 2. Check for 10 digits			
			addi $s3, $s3, 1 # Get the next character address
			addi $t2, $t2, 1 # Increase counter
			blt $t2, $t3, arg2_loop # i < 10 -> Loop
			jr $ra # Just return (success)
			return_fail:
				ble $t2,$t3, invalid_input

	j end
invalid_num_args:
	la $a0, WrongArgMsg
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall

invalid_input:
	la $a0, ErrMsg
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
operation_O:
	jal arg2_check
	li $0, 0 # $0 is a 0
	li $t3, 9 # $t3 hold 9 for char -> int
	li $t4, 48 # Hold 48
	move $s3, $s2 # s3 holds the full string
	addi $s3, $s3, 2 # Move 2 characters over (ignore 0x)
	lbu $t1, 0($s3) # arg[0] = first digit
	lbu $t2, 1($s3) # arg[1] = second digit
	subu $t1, $t1, $t4 # $t1 - 48; Subtract by 48 to see if it is a digit
	bgtu $t1, $t3, letter_O
	second_value_O:
		subu $t2, $t2, $t4 # $t2 - 48; Subtract by 48 to see if it is a digit
		bgtu $t2, $t3, letter_O2
	continue_second_O: # The bit manipulation
		sll $t1, $t1, 2
		srl $t2, $t2, 2
		addu $t3, $t1, $t2
	continue_O:
		move $a0, $t3
		li $v0, 1
		syscall
	end_O:
		j end	
	letter_O:
		li $t5, 7
		subu $t1, $t1, $t5 # Subtract by 7 to get the numerical value of hex
		j second_value_O
	letter_O2:
		li $t5, 7
		subu $t2, $t2, $t5 # Subtract by 7 to get the numerical value of hex
		j continue_second_O

operation_S:
	jal arg2_check
	
	li $0, 0 # $0 is a 0
	li $t3, 9 # $t3 hold 9 for char -> int
	li $t4, 48 # Hold 48
	move $s3, $s2 # s3 holds the full string
	addi $s3, $s3, 3 # Move 3 characters over (ignore 0x-)
	lbu $t1, 0($s3) # arg[0] = first digit
	lbu $t2, 1($s3) # arg[1] = second digit
	first_value_S:
		subu $t1, $t1, $t4 # $t1 - 48; Subtract by 48 to see if it is a digit
		bgtu $t1, $t3, letter_S
	second_value_S:
		subu $t2, $t2, $t4 # $t2 - 48; Subtract by 48 to see if it is a digit
		bgtu $t2, $t3, letter_S2 # 2nd digit may be a letter
	continue_second_S: # The bit manipulation
		andi $t1, $t1, 0x3
		sll $t1, $t1, 3
		srl $t2, $t2, 1
		addu $t3, $t1, $t2
	continue_S:
		move $a0, $t3
		li $v0, 1
		syscall
	end_S:
		j end	
	letter_S:
		li $t5, 7
		subu $t1, $t1, $t5 # Subtract by 7 to get the numerical value of hex
		j second_value_S
	letter_S2:
		li $t5, 7
		subu $t2, $t2, $t5 # Subtract by 7 to get the numerical value of hex
		j continue_second_S
	
	j end
operation_T:
	jal arg2_check
	
	li $0, 0 # $0 is a 0
	li $t3, 9 # $t3 hold 9 for char -> int
	li $t4, 48 # Hold 48
	move $s3, $s2 # s3 holds the full string
	addi $s3, $s3, 4 # Move 4 characters over (ignore 0x--)
	lbu $t1, 0($s3) # arg[0] = first digit
	lbu $t2, 1($s3) # arg[1] = second digit
	first_value_T:
		subu $t1, $t1, $t4 # $t1 - 48; Subtract by 48 to see if it is a digit
		bgtu $t1, $t3, letter_T
	second_value_T:
		subu $t2, $t2, $t4 # $t2 - 48; Subtract by 48 to see if it is a digit
		bgtu $t2, $t3, letter_T2 # 2nd digit may be a letter
	continue_second_T: # The bit manipulation
		andi $t1, $t1, 0x1
		sll $t1, $t1, 4
		addu $t3, $t1, $t2
	continue_T:
		move $a0, $t3
		li $v0, 1
		syscall
	end_T:
		j end	
	letter_T:
		li $t5, 7
		subu $t1, $t1, $t5 # Subtract by 7 to get the numerical value of hex
		j second_value_T
	letter_T2:
		li $t5, 7
		subu $t2, $t2, $t5 # Subtract by 7 to get the numerical value of hex
		j continue_second_T
	
	j end
operation_I: # TODO: Fix it in terms of positive and negative
	jal arg2_check
	
	move $s3, $s2 # s3 holds the full string
	addi $s3, $s3, 6 # Move 6 characters over (ignore 0x----)
	lbu $t1, 0($s3) # arg[0] = first digit
	li $t2, 0 # $t2: i = 0
	li $t5, 4 # Max strings to iterate
	li $t3, 4 # Number to shift
	li $t4, 0 # The final answer
	li $t9, 0 # Check if MSB is 1 or 0
	andi $t9, $t1, 0x8 # MSB is 0 or 1
	srl $t9, $t9, 3
	loop_I:
		beq $t2, $t5, end_I # If the last string is reached, end
		lbu $t1, 0($s3) # arg[0] = first digit
		li $t6, 48 # Subtract from it
		li $t7, 9 # Subtract if a Letter
		sub $t1, $t1, $t6 # $t1 - 48 to get the number (if it's a number)
		bgt $t1, $t7, letter_I
		continue_process:
			beqz $t2, ignore_and_cont_I
		stuff_2_I:
			sll $t4, $t4, 4 # Shift bits left
			add $t4, $t4, $t1 # $t4 += $t1; add the bits
		continue_loop:
			addi $t2, $t2, 1 # i++
			addi $s3, $s3, 1 # Get next character
			j loop_I
	end_I:
		beqz $t9, end_I2 # MSB is 0
		xori $t4, $t4, 0xFFFF
		not $t4, $t4
		move $a0, $t4
		li $v0, 1
		syscall
		
		j end
	end_I2: # MSB is 0
		move $a0, $t4
		li $v0, 1
		syscall
		
		j end
	letter_I:
		li $t6, 7
		sub $t1, $t1, $t6 # $t1 - 7 to get the numerical value of the letter
		j continue_process
	ignore_and_cont_I:
		li $t9, 0 # Check if MSB is 1 or 0
		andi $t9, $t1, 0x8 # MSB is 0 or 1
		srl $t9, $t9, 3

		j stuff_2_I
operation_E:
	jal arg2_check
	
	move $s3, $s2 # s3 holds the full string
	addi $s3, $s3, 9 # Move 9 characters over (only care about that last 9th character (0-convention))
	lbu $t1, 0($s3) # arg[0] = first digit
	
	li $t4, 48 # Subtract from it to get digit
	li $t5, 9 # If the char is a letter
	subu $t1, $t1, $t4
	bgt $t1, $t5, check_letter_E
	continue_E:
		andi $t1, $t1, 0x1 # Get the last bit
		bgtz $t1, odd_E # If it's a one, it's odd
		beqz $t1, even_E # Otherwise, it's even
	
		j end
	odd_E:
		la $a0, OddMsg
		li $v0, 4,
		syscall
		j end
	even_E:
		la $a0, EvenMsg
		li $v0, 4,
		syscall
		j end
	check_letter_E:
		li $t5, 7
		subu $t1, $t1, $t5
		j continue_E
operation_C:
	jal arg2_check
	
	move $s3, $s2 # s3 holds the full string
	addi $s3, $s3, 2 # Move 2 characters over (ignore 0x)

	li $t2, 0 # i = 0
	li $t6, 0 # Num of 1's
	
	loop_C:
		li $t4, 8 # Iterate over the 8 characters
		li $t3, 0 # j = 0
		beq $t2, $t4, exit_C # Finished with the string
		lbu $t1, 0($s3) # arg[0] = first digit
		li $t4, 48 # Subtract from 48 to get digit
		sub $t1, $t1, $t4
		li $t4, 9 # Check if value is greater than 9
		bgt $t1, $t4, check_letter_C
		j loop_binary_C
		loop_binary_C:
			li $t5, 4 # Max num of bits to get
			move $t7, $t1 # Temporary copy of original string (w/ mod)
			beq $t3, $t5, continue # Finished processing all the binary
			andi $t7, $t1, 0x1 # Get the last bit
			srl $t1, $t1, 1 # Shift to right to get the new last bit
			addu $t6, $t6, $t7 # Add the bit into the result (0/1)
			addi $t3, $t3, 1 # j++
			j loop_binary_C
		continue:
			addi $t2, $t2, 1 # i++
			addi $s3, $s3, 1 # get next character
			j loop_C
		check_letter_C:
			li $t4, 7
			sub $t1, $t1, $t4 # Gets the numerical value of the letter
			j loop_binary_C
	exit_C:
		move $a0, $t6
		li $v0, 1
		syscall
		
		j end
operation_X:
	jal arg2_check
	
	move $s3, $s2 # s3 holds the full string
	addi $s3, $s3, 2 # Move 2 characters over (ignore 0x)
	
	li $t2, 0 # i = 0
	li $t7, 3 # Maximum iterations; only care about the first 9 bits (or 3 hex digits)
	li $t6, 0 # This is the result
	loop_X:
		beq $t2, $t7, end_X # Finished processing the digits
		lbu $t1, 0($s3) # arg[0] = first digit
		li $t3, 48 # Subtract from 48 to get the value
		li $t4, 9 # Check for letters
		sub $t1, $t1, $t3 # Get the digit value
		bgt $t1, $t4, letter_X # May be a letter
	process_X:
		# Using $t1, we do stuff
		li $t3, 0 # 1st digit
		li $t4, 1 # 2nd digit 
		li $t5, 2 # 3rd digit
		beq $t2, $t3, first_process_X
		beq $t2, $t4, second_process_X
		beq $t2, $t5, third_process_X
	continue_X:
		addi $s3, $s3, 1 # Move to next character
		addi $t2, $t2, 1 # i++
		j loop_X
	letter_X:
		li $t4, 7
		sub $t1, $t1, $t4 # Gets the numerical value for letter
		j process_X
	first_process_X:

		move $t3, $t1 # Temporary copy
		andi $t3, $t3, 0x7 # Get the last 3 bits of the first
		add $t6, $t6, $t3 # Add to $t6 the last 3 bits
		sll $t6, $t6, 4 # Shift left 4
		j continue_X
	second_process_X:
		move $t3, $t1 # temporary copy
		add $t6, $t6, $t1
		sll $t6, $t6, 1
		j continue_X
	third_process_X:
		move $t3, $t1 # temporary copy
		andi $t3, $t3, 0x8 # get the most significant bit
		srl $t3, $t3, 3
		add $t6, $t6, $t3
		j continue_X		
	end_X:
		# Result is in $t6
		li $t3, 127 # Subtract from 127 to get the exponent
		sub $t6, $t6, $t3
		move $a0, $t6
		li $v0, 1
		syscall
		j end
operation_M:
	jal arg2_check
	
	move $s3, $s2 # s3 holds the full string
	addi $s3, $s3, 4 # Move 4 characters over (ignore 0x--)
	li $t2, 0 # i = 0
	li $t3, 6 # Max. chars to iterate over
	li $t7, 0 # This is the result
	loop_M:
		beq $t2, $t3, end_M # Finished processing the string
		lbu $t1, 0($s3) # arg[0] = first digit
		li $t4, 48 # Subtract from to get the value
		li $t5, 9 # Check if it's a letter
		sub $t1, $t1, $t4 # t1 - 48 gets value
		bgt $t1, $t5, letter_M # Must be a letter
		process_M:
			beqz $t2, process_once_M # First digit (i == 0)
			li $t5, 0
			sll $t7, $t7, 4 # Shift 4 left
			add $t7, $t7, $t1 # Add digit to this result
			j continue_M
		continue_M:
			addi $s3, $s3, 1 # Go to the next character
			addi $t2, $t2, 1 # i++
			j loop_M
		letter_M:
			li $t5, 7
			sub $t1, $t1, $t5 # Get the numerical value of the letter

			j process_M
		process_once_M: # Should run once
			li $t5, 0
			andi $t5, $t1, 0x7 # Get the 3 lsb of the first digit
			add $t7, $t7, $t5 # Add to result
			j continue_M
	end_M:
		sll $t7, $t7, 9
		la $a0, PreText
		li $v0, 4
		syscall
		
		move $a0, $t7
		li $v0, 35
		syscall
		j end
end:
	li $v0, 10
	syscall
