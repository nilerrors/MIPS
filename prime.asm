	.data

prime_text:	.asciiz "--Prime--\n"
no_prime_text:	.asciiz "--No prime--\n"	


### Pseudo-code:
# int n = input()
# for (int i = 2; i < n; i++):
# 	if (n % i == 0):
# 		print("--No prime--")
# 		break
# print("--Prime--")

	.text
main:
	li $v0, 5 	# read int n
	syscall
	
	move $s0, $v0	# move int n to store register
	
	li $t0, 2	# int i = 2
prime_loop:
	ble $s0, $t0, is_prime	# if n >= i: is_prime
	
	div $s0, $t0		# LO = s / i; HI = s % i;
	mfhi $t1		# remainder to $t1
	beqz $t1, is_not_prime	# if s%i == 0: is_not_prime
	
	addi $t0, $t0, 1	# i++
	j prime_loop

is_prime:
	la $a0, prime_text	# load address of prime_text
	li $v0, 4		# print prime text
	syscall
	j exit

is_not_prime:
	la $a0, no_prime_text	# load address of no_prime_text
	li $v0, 4		# print no_prime_text
	syscall

exit:
	li, $v0, 10	# exit
	syscall
