# head -> (12,8,term0) -> (16,5,0)
.data
pair: .word -12 8
terms: .word 16 5 1 8 4 3 1 0 0 -1
p: .word 0
N: .word 4
N1: .word 1

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
    lw $a1, N1
    jal remove_Nth_term

    #write test code
    move $a0, $v0
    li $v0, 1
    syscall

    li $a0, ' '
    li $v0, 11
    syscall

    move $a0, $v1
    li $v0, 1
    syscall

    li $a0, '\n'
    li $v0, 11
    syscall

    la $t0, p
    lw $t0, 0($t0) # Go to head
    # lw $t0, 8($t0) # Go to 2nd element
    # lw $t0, 8($t0) # Go to 3rd element

    lw $a0, 0($t0)
    li $v0, 1
    syscall

    li $a0, ' '
    li $v0, 11
    syscall

    lw $a0, 4($t0)
    li $v0, 1
    syscall
    
    li $v0, 10
    syscall

.include "hw5.asm"
