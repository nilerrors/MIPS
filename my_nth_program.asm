    .data
first_part:	.asciiz "This is my "
second_part: 	.asciiz "-th MIPS-program\n"


    .text
main:	li, $v0, 5		# Read int
	syscall
	
	move, $s0, $v0		# Set value in store register
	
	la, $a0, first_part	# Load first part of message
	li, $v0, 4		# print first part
	syscall
	
	move, $a0, $s0		# Set read int into register for print
	li, $v0, 1		# print read int
	syscall
	
	la, $a0, second_part	# Load second part of message
	li, $v0, 4		# print second part
	syscall
	
	li, $v0, 10		# exit program
	syscall

