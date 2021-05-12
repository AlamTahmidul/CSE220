.data
pair: .word 12 8
terms: .word 16 10 1 8 0 -1
new_terms: .word 16 8 15 8 69 10 0 -1
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
    move $a0, $v0
    li $v0, 1
    syscall

    # la $t0, p
    # lw $t0, 0($t0) # Get head_term
    # lw $t0, 8($t0)

    # lw $a0, 0($t0)
    # li $v0, 1
    # syscall

    # li $a0, ' '
    # li $v0, 11
    # syscall

    # lw $a0, 4($t0)
    # li $v0, 1
    # syscall

    li $v0, 10
    syscall

.include "hw5.asm"
