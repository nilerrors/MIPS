	.eqv LAST_CASE_NUM 2
	
	.data
jumpTbl:.word case0, case1, case2
var_a:	.word
var_n: .word


#int a = 0;
#switch (n) {
#    case 0:
#        a = 9;
#        break;
#    case 1:
#        a = 6;
#    case 2:
#        a = 8;
#        break;
#    default:
#        a = 7;
#        break;
#}
#std::cout << a << endl;


	.text
main:
	li, $v0, 5	# read int n
	syscall
	
	la $t0, var_n	# address of var n
	lw $s0, 0($t0)	# data of var n
	move $s0, $v0	# store int n
	
	la $s1, jumpTbl	# $s1 contains address of jumpTbl
	
	la $t0, var_a		# address of var a
	lw $s2, 0($t0)		# data of var a
	
	blt $s0, $zero, default		# if int n < 0: default
	li, $t0, LAST_CASE_NUM
	bgt $s0, $t0, default		# if int n > LAST_CASE_NUM: default
	
	sll $t1, $s0, 2			# $t1 = n * 4
	add $t1, $s1, $t1		# address to jump to, found
	lw $t2, 0($t1)			# address to jump to
	jr $t2
	
case0:
	li $s2, 9	# write 9 in var a
	j endSwitch
case1:
	li $s2, 6	# write 6 in var a
case2:
	li $s2, 8	# write 8 in var a
	j endSwitch
default:
	li $s2, 7	# write 7 in var a
endSwitch:
	move $a0, $s2	# move var a for print
	li, $v0, 1	# print var a
	syscall

