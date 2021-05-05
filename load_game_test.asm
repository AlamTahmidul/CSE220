.data
board_filename: .asciiz "game011.txt"
# game01.txt -> 1, 12
# gameE1.txt -> 0, 12
# gameE3.txt -> 0, 0
# not_real_file.txt -> -1, -1
.align 2
state:
    .byte 0         # bot_mancala       	(byte #0)
    .byte 1         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0108070601000404040404040400"
.text
.globl main
main:
la $a0, state
la $a1, board_filename
jal load_game
# You must write your own code here to check the correctness of the function implementation.

move $s0, $v0
move $s1, $v1

#move $a0, $s0
#li $v0, 1
#syscall

#move $a0, $s1
#li $v0, 1
#syscall

la $a0, state
jal print_board

li $v0, 10
syscall

.include "hw3.asm"
