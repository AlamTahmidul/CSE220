.data
p_pair: .word 5 2
p_terms: .word -7 1 0 -1
q_pair: .word 3 2
q_terms: .word 1 1 0 -1
p: .word 0
q: .word 0
r: .word 0
N: .word 1

.text:
main:
    la $a0, p
    la $a1, p_pair
    jal init_polynomial

    la $a0, p
    la $a1, p_terms
    lw $a2, N
    jal add_N_terms_to_polynomial

    la $a0, q
    la $a1, q_pair
    jal init_polynomial

    la $a0, q
    la $a1, q_terms
    lw $a2, N
    jal add_N_terms_to_polynomial

    la $a0, p
    la $a1, q
    la $a2, r
    jal add_poly

    #write test code
    move $a0, $v0
    li $v0, 1
    syscall
	
	li $a0, ' '
	li $v0, 11
	syscall

    la $t0, r
    lw $t0, 0($t0) # Go to head
    lw $t0, 8($t0)

    lw $a0, 0($t0) # element
    li $v0, 1
    syscall

    li $v0, 10
    syscall

.include "hw5.asm"
