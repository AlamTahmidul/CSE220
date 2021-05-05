############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

create_term:
	# Term* create_term(int coeff, int exp)

	jr $ra
init_polynomial:
	# int init_polynomial(Polynomial* p, int[2] pair)

	jr $ra
add_N_terms_to_polynomial:
	# int add_N_terms_to_polynomial(Polynomial* p, int[] terms, N)

	jr $ra
update_N_terms_in_polynomial:
	# int update_N_terms_in_polynomial(Polynomial* p, int[] terms, N)
	jr $ra
get_Nth_term:
	# (int,int) get_Nth_term(Polynomial* p, N)

	jr $ra
remove_Nth_term:
	# (int,int) remove_Nth_term(Polynomial* p, N)

	jr $ra
add_poly:
	# int add_poly(Polynomial* p, Polynomial* q, Polynomial* r)

	jr $ra
mult_poly:
	# int mult_poly(Polynomial* p, Polynomial* q, Polynomial* r)
	
	jr $ra
