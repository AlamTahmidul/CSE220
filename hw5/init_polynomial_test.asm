.data
pair: .word 12 8
p: .word 0

.text:
main:
    la $a0, p
    la $a1, pair
    jal init_polynomial

    #write test code

    li $v0, 10
    syscall

.include "hw5.asm"
