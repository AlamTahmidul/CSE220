.data
pair: .word 12 8
p: .word 0

.text:
main:
    la $a0, p
    la $a1, pair
    jal init_polynomial

    #write test code
    
    move $s0, $v0

    move $a0, $s0
    li $v0, 1
    syscall

    li $a0, '\n'
    li $v0, 11
    syscall

    la $t0, p
    lw $a0, 0($t0)
    lw $a0, 0($a0)
    li $v0, 1
    syscall

    li $a0, '\n'
    li $v0, 11
    syscall

    la $t0, p
    lw $a0, 0($t0)
    lw $a0, 4($a0)
    li $v0, 1
    syscall

    li $v0, 10
    syscall

.include "hw5.asm"
