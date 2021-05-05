.data
pair: .word 12 8
terms: .word 16 5 1 8 0 -1
new_terms: .word 16 3 1 5 0 -1
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

    la $a0, p
    la $a1, new_terms
    lw $a2, N
    jal update_N_terms_in_polynomial

    #write test code

    li $v0, 10
    syscall

.include "hw5.asm"
