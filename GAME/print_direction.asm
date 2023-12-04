    .eqv CHAR_Z  'z'        # ascii value of "z"
    .eqv CHAR_S  's'        # ascii value of "s"
    .eqv CHAR_Q  'q'        # ascii value of "q"
    .eqv CHAR_D  'd'        # ascii value of "d"
    .eqv CHAR_X  'x'        # ascii vlaue of "x"

    .data
newline:             .asciiz "\n"
up_text:             .asciiz "up"
down_text:           .asciiz "down"
left_text:           .asciiz "left"
right_text:          .asciiz "right"
not_found_char_text: .asciiz "Unknown input! Valid inputs: z s q d x"


    .text
test_print_direction:
    la $t0, newline

print_direction:
    li $v0, 12        # read character
    syscall
    
    move $s0, $v0     # move character value so it's not overriden
    
    li $v0, 4         # print newline
    move $a0, $t0
    syscall
    
    
    beq $s0, CHAR_X, endProgram        # if char == 'x': endProgram
    beq $s0, CHAR_Z, up        # if char == 'z': up
    beq $s0, CHAR_S, down      # if char == 's': down
    beq $s0, CHAR_Q, left      # if char == 'q': left
    beq $s0, CHAR_D, right     # if char == 'd': right


# Store pointer of string we want in $a0 for print syscall
notFoundChar:
    la $a0, not_found_char_text
    b back_to_print_direction

up:
    la $a0, up_text
    b back_to_print_direction

down:
    la $a0, down_text
    b back_to_print_direction

left:
    la $a0, left_text
    b back_to_print_direction

right:
    la $a0, right_text

back_to_print_direction:
    li $v0, 4        # print string
    syscall
    
    li $v0, 4        # print newline
    move $a0, $t0
    syscall
    
    li $v0, 32       # sleep for
    li $a0, 2000     # for 2000 milliseconds
    syscall
    
    j print_direction

endProgram:
    li $v0, 10
    syscall
