	.data
new_line:	.asciiz "\n"
	.text
main:
	li, $v0, 5	# Read int n
	syscall
	
	move $t0, $v0	# move int n to store register 0
	la, $t2, new_line
	
	li, $t1, 1	# for loop index
for_loop:
	blt $t0, $t1, end_loop		# if values are the same, end loop

	move $a0, $t1			# move int n to print
	li, $v0, 1			# print int n
	syscall
	
	move $a0, $t2			# move address of newline for print
	li, $v0, 4			# print newline
	syscall

	addi, $t1, $t1, 1		# increase index

	j for_loop			# go back to loop
end_loop:
	li, $v0, 10
	syscall 
	
