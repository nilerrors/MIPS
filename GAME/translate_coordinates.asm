    .eqv PIXEL_SIZE_IN_BYTES 4        # pixel value is in 32 bits
    .eqv WIDTH_IN_PIXELS     32       # total width in pixels


    .text
test_translate_coordinates:
    li $v0, 5             # int row_number
    syscall
    move $a0, $v0         # use int row_number as first parameter for translate_coordinates
    
    li $v0, 5             # int column_number
    syscall
    move $a1, $v0         # use int column_number as second parameter for translate_coordinates
    
    jal translate_coordinates    # call function
    
    move $a0, $v0         # move address of pixel at (row_number, column_number)
    li $v0, 34            # print hex value
    syscall
    
    li $v0, 10            # exit program
    syscall
    

############# # # # #############
# PROC TO CONVERT GIVEN X AND Y COORDINATE OF PIXEL TO MEMORY ADDRESS
# ARGS:
#      $a0 -> ROW
#      $a1 -> COLUMN
# RETURNS:
#      $v0 -> MEMORY ADDRESS
    .globl translate_coordinates
translate_coordinates:
    # formula to calculate the address for the given index:
    # $gp + ($a0 * WIDTH_IN_PIXELS + $a1) * PIXEL_SIZE_IN_BYTES
    
    
    sw $fp, 0($sp)            # previous frame-pointer in stack
    move $fp, $sp             # current frame-pointer points to (current) top of the stack
    subu $sp, $sp, 8          # reserve place for 4 bytes; only $s0
    sw $s0, -4($fp)           # store $s0; address
    
    li $s0, WIDTH_IN_PIXELS        # $s0 = 32
    mul $s0, $a0, $s0              # $s0 = $a0 * $s0
    add $s0, $s0, $a1              # $s0 = $s0 + $a0
    mul $s0, $s0, PIXEL_SIZE_IN_BYTES        # $s0 = $s0 * PIXEL_SIZE_IN_BYTES
    add $s0, $s0, $gp              # $s0 = $s0 + $gp
    
    move $v0, $s0        # return value
    
    # restore previous values
    lw $s0, -4($fp)
    move $sp, $fp
    lw $fp, 0($sp)
    
    jr $ra
