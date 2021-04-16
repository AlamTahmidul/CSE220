.data
filename: .asciiz "C:\\Users\\tamin\\Documents\\GitHub\\CSE220\\hw3\\moves01.txt"
.align 0
moves: .byte 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.text
.globl main
main:
la $a0, moves
la $a1, filename
jal load_moves

# You must write your own code here to check the correctness of the function implementation.
# move $a0, $v0
# li $v0, 1
# syscall
move $s0, $v0 # Number of elements
la $s1, moves # addr of moves
li $t0, 0

loop:
    beq $t0, $s0, out
    lb $a0, 0($s1)
    li $v0, 1
    syscall

    addi $t0, $t0, 1
    addi $s1, $s1, -1

    li $a0, '\n'
    li $v0, 11
    syscall
    j loop

out:
li $v0, 10
syscall

.include "hw3.asm"
