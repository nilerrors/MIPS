    .eqv MAX_LEN 2048
    
    .data
fin:    .asciiz "test_file_2.txt"
buffer: .space 2048


    .text
main:
#### file descriptor
    li $v0, 13        # open file
    la $a0, fin       # with file name
    li $a1, 0         # open for read
    li $a2, 0         # mode ignored
    syscall
    move $s0, $v0     # move file descriptor to $s0; if $v0 < 0: error
    
    li $v0, 14        # read file
    move $a0, $s0     # with file descriptor
    la $a1, buffer    # into buffer
    li $a2, 2048   # with max len
    syscall
    move $s1, $v0     # amount of characters read; if $v0 < 0: error
    
    li $v0, 4
    la $a0, buffer
    syscall
    
    li $v0, 16          # system call code for close
    move $a0, $s0       # file descriptor
    syscall

    li $v0, 10    # exit program
    syscall
