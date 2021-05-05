.data
coeff: .word 12
exp: .word 8

.text:
main:
    lw $a0, coeff
    lw $a1, exp
    jal create_term

    #write test code

    li $v0, 10
    syscall

.include "hw5.asm"
