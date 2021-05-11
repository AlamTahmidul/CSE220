.data
coeff: .word -4
exp: .word -3

.text:
main:
    lw $a0, coeff
    lw $a1, exp
    jal create_term

    #write test code
    move $s0, $v0
    move $a0, $s0
    li $v0, 1
    syscall

    li $v0, 10
    syscall

.include "hw5.asm"
