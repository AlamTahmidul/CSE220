.data
.align 2
state:        
    .byte 5         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 0         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0108070601000404040404040400"
    # 0108070601000404040404040400
.text
.globl main
main:
la $a0, state
jal check_row
# You must write your own code here to check the correctness of the function implementation.
# move $s0, $v0
# move $s1, $v1

# move $a0, $s0
# li $v0, 1
# syscall

# li $a0, '\n'
# li $v0, 11
# syscall

# move $a0, $s1
# li $v0, 1
# syscall

la $a0, state
jal print_board

li $v0, 10
syscall

.include "hw3.asm"
