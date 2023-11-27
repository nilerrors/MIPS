	.data
pi:	.float 3.14
new_line:.asciiz "\n"

	.text
main:
	la $t0, new_line
	
	la $t1, pi		# load pi
	lwc1 $f1, 0($t1)	# float pi = 3.14;
	
	li $v0, 6		# read float radius in $f0
	syscall
	
	mul.s $f0, $f0, $f0	# float radius = radius * radius;
	
	# note; $f12 is also the register to print float
	mul.s $f12, $f0, $f1	# float area = radius^2 * pi;
	
	li $v0, 2		# print float area
	syscall
	
	move $a0, $t0		# new_line for print
	li $v0, 4		# print new_line
	syscall
	
	li $v0, 10	# end program
	syscall
	
	
