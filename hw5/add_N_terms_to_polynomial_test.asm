.data
pair: .word 12 8
terms: .word 16 7 14 10 3 0 0 -1
p: .word 0
N: .word 3

.text:
main:
    la $a0, p
    la $a1, pair
    jal init_polynomial

    la $a0, p
    la $a1, terms
    lw $a2, N
    jal add_N_terms_to_polynomial

    #write test code
    # move $a0, $v0
    # li $v0, 1
    # syscall

    # la $t0, p
    # lw $t0, 0($t0) # Get Head Address
    # lw $t0, 8($t0) # Get Next pointer
    # lw $t0, 8($t0)
    # lw $t0, 8($t0)

    # lw $a0, 0($t0) # Get coeff
    # li $v0, 1
    # syscall


    li $v0, 10
    syscall

.include "hw5.asm"
