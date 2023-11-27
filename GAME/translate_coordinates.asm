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
    
    li $t0, WIDTH_IN_PIXELS        # $t0 = 32
    mul $t0, $a0, $t0              # $t0 = $a0 * $t0
    add $t0, $t0, $a1              # $t0 = $t0 + $a0
    mul $t0, $t0, PIXEL_SIZE_IN_BYTES        # $t0 = $t0 * PIXEL_SIZE_IN_BYTES
    add $t0, $t0, $gp              # $t0 = $t0 + $gp
    
    move $v0, $t0        # return value
    jr $ra
