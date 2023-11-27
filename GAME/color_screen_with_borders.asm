    .eqv WIDTH_IN_PIXELS_MINUS1  31       # 0..WIDTH_IN_PIXELS_MINUS1
    .eqv HEIGHT_IN_PIXELS_MINUS1 15       # 0..HEIGHT_IN_PIXELS_MINUS1
    .eqv RED_COLOR    0x00FF0000          # color RED in hex
    .eqv YELLOW_COLOR 0x00FFFF00          # color YELLOW in hex


    .text
test_color_by_coordinates:
    li $s0, 0            # matrix Y index

for_Y:
    bgt $s0, HEIGHT_IN_PIXELS_MINUS1, end      # if Y > 31: end
    li $s1, 0            # matrix X index
    
    j for_X
    
end_iter_for_Y:
    addi $s0, $s0, 1    # matrix Y counter ++
    j for_Y
    
for_X:
    bgt $s1, WIDTH_IN_PIXELS_MINUS1, end_iter_for_Y    # if Y > 15: goto end_fox_Y
    
    move $a0, $s0    # move Y index for argument
    move $a1, $s1    # move X index for argument
    
    beqz $s0, color_yellow                                # if Y == 0: yellow
    beqz $s1, color_yellow                                # if X == 0: yellow
    beq $s0, HEIGHT_IN_PIXELS_MINUS1, color_yellow        # if Y == 15: yellow
    beq $s1, WIDTH_IN_PIXELS_MINUS1, color_yellow         # if X == 31: yellow
    
color_red:
    li $a2, RED_COLOR        # color for argument
    j end_color_select
    
color_yellow:
    li $a2, YELLOW_COLOR     # color for argument

end_color_select:
    jal color_by_coordinates    # call function to color the PIXEL at coordinates(X, Y)
    
    addi $s1, $s1, 1    # matrix X counter ++
    j for_X

end:
    li $v0, 10          # syscall
    syscall


############# # # # #############
# PROC TO STORE COLOR VALUE FOR GIVEN COORDINATES OF PIXEL (INTO MEMORY)
# ARGS:
#      $a0 -> ROW
#      $a1 -> COLUMN
#      $a2 -> COLOR VALUE
# NO RETURNS
    .globl color_by_coordinates
color_by_coordinates:
    sw $fp, 0($sp)        # store previous frame-poiner
    move $fp, $sp         # frame pointer points to current stack pointer value
    subu $sp, $sp, 4      # create place for 4 bytes; only the return address
    sw $ra, -4($fp)       # store value of return address
    
    jal translate_coordinates        # arguments already in $a0, $a1; PIXEL address in $v0
    
    sw $a2, 0($v0)        # store color value using the PIXEL address
    
    lw $ra, -4($fp)       # restore return address
    move $sp, $fp         # restore previous stack pointer
    lw $fp, 0($sp)        # restore previous frame pointer
    jr $ra
