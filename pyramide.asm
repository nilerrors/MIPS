	.data
new_line:	.asciiz "\n"
space:		.asciiz " "



### cpp code:
#for (int i=1; i<=n; i++) {
#	for (int j=1; i<= i; j++) {
#		if (j != 1) cout << " ";
#		cout << j;
#	}
#	cout << endl;
#}

	.text
main:
	li, $v0, 5		# read int n
	syscall
	
	move $s0, $v0		# store int n in store register
	
	la, $t0, space		# get space symbol
	la, $t1, new_line	# get newline symbol
	
	li, $t2, 1		# outer for loop index i

outer_for_loop:
	blt, $s0, $t2, exit	# if n > i: exit
	li, $t3, 1		# inner for loop index j
	
	j inner_for_loop	# goto inner_for_loop

end_outer_for_loop:	
	move, $a0, $t1		# move newline to print
	li, $v0, 4		# print newline
	syscall
	
	addi, $t2, $t2, 1	# increase int i by 1
	j outer_for_loop	# go again into for loop

inner_for_loop:
	blt, $t2, $t3, end_outer_for_loop	# end outer for loop
	
	addi $t4, $t3, -1			# j - 1
	beqz, $t4, skip_print_space		# if j-1 == 0: skip_print_space
	
	move, $a0, $t0				# move space char to print
	li, $v0, 4				# print space char
	syscall

skip_print_space:
	move $a0, $t3		# move int j to print
	li, $v0, 1		# print int j
	syscall
	
	addi $t3, $t3, 1	# increase int j by 1
	j inner_for_loop

exit:
	li, $v0, 10		# exit program
	syscall
