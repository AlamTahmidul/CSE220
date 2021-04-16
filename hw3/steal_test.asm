.data
destination_pocket: .byte 0
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 0         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0004040404040404040404040000"
    # 0108070601000404040404040400
.text
.globl main
main:
la $a0, state
li $a1, 4 # origin_pocket
jal execute_move

li $t0, 1
beq $v1, $t0, steal_t
j error_cont
steal_t:
    la $a0, state
    lb $a1, destination_pocket
    jal steal

# You must write your own code here to check the correctness of the function implementation.
ignore_cont:
    la $s0, state

    move $a0, $v0
    li $v0, 1
    syscall

    # lb $a0, 0($s0)
    # li $v0, 1
    # syscall

error_cont:
    li $v0, 10
    syscall

.include "hw3.asm"
