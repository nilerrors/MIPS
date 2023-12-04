 .globl main

.data
mazeFilename:    .asciiz "input_1.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "You have won the game!"

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

wallColor:      .word 0x004286F4    # Color used for walls (blue)
passageColor:   .word 0x00000000    # Color used for passages (black)
playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
exitColor:      .word 0x0000FF00    # Color used for exit (green)


#########################
# FILE INPUT CHARS
#########################
.eqv CHAR_W    'w'      # WALL
.eqv CHAR_P    'p'      # PASSAGE
.eqv CHAR_S    's'      # PLAYER
.eqv CHAR_U    'u'      # EXIT
.eqv NEWLINE   10       # NEWLINE CHAR; END OF ROW
.eqv NULL_CHAR 0        # NULL CHAR; END OF STRING
#########################

#########################
# PLAYER MOVEMENT CHAR INPUT
#########################
.eqv CHAR_UP    'z'
.eqv CHAR_DOWN  's'
.eqv CHAR_LEFT  'q'
.eqv CHAR_RIGHT 'd'
.eqv CHAR_EXIT  'x'
#########################


.text

main:
    jal read_maze_file        # read maze into memory
    # returns
    move $s0, $v0             # player position row
    move $s1, $v1             # player position row
    

### main loop of the game
loop:    
    # `player to` row in $s2, and column in $s3
    move $s2, $s0
    move $s3, $s1


    li $v0, 12        # read character
    syscall
    
    beq $v0, CHAR_EXIT, exit
    beq $v0, CHAR_UP, go_up
    beq $v0, CHAR_DOWN, go_down
    beq $v0, CHAR_LEFT, go_left
    beq $v0, CHAR_RIGHT, go_right
    
    j sleep            # if char is not found; continue with loop
    

go_up:
    addi $s2, $s2, -1        # row = row - 1
    j move_player
    
go_down:
    addi $s2, $s2, 1         # row = row + 1
    j move_player

go_left:
    addi $s3, $s3, -1        # column = column - 1
    j move_player

go_right:
    addi $s3, $s3, 1         # column = column + 1
    
move_player:
    ###
    # Check if `player to` position is exit
    ###
    move $a0, $s2
    move $a1, $s3
    jal translate_coordinates
    # returns address in $v0
    lw $t0, 0($v0)            # get value of `player to` pixel
    lw $t1, exitColor         # get value of exit color
    
    
    seq $s5, $t0, $t1         # $s5 = $t0 == $t1; $s0 is a boolean value used to check if `player to` position is exit
    
    move $a0, $s0        # current player position row
    move $a1, $s1        # current player position column
    move $a2, $s2        # `player to` position row
    move $a3, $s3        # `player to` position column
    jal update_player_position
    # returns updated user position
    move $s0, $v0        # updated user position row
    move $s1, $v1        # updated user position column
    
    
    ###
    # Use calculated value to check if player has won; i.e. has reached the exit
    ###
    beq $s5, 1, victory

sleep:
    li $v0, 32        # sleep
    li $a0, 60        # for 60 ms
    syscall
    
    j loop            # "infinite" loop

victory:
    li $v0, 4                 # print
    la $a0, victoryMessage    # victory message
    syscall

exit:
    # syscall to end the program
    li $v0, 10    
    syscall





#########################
# FUNCTION: reads the maze file
# ARGS: None
# RETURNS:
#     $v0   player position row
#     $v1   player position column
#########################
read_maze_file:
    sw $fp, 0($sp)        # previous frame-pointer in stack
    move $fp, $sp         # current frame-pointer points to (current) top of stack
    subu $sp, $sp, 36     # create place for 32 bytes; $s0, $s1, $s2, $s3, $s4, $s5, $s6, $ra
    sw $s0, -4($fp)       # store the $s0; register for file descriptor and read file bytes
    sw $s1, -8($fp)       # store the $s1; used for current row
    sw $s2, -12($fp)      # store the $s2; used for current column
    sw $s3, -16($fp)      # store the $s3; used for current char position in buffer string
    sw $s4, -20($fp)      # store the $s4; used for current pixel color
    sw $s5, -24($fp)      # store the $s5; used for player position row
    sw $s6, -28($fp)      # store the $s6; used for player position column
    sw $ra, -32($fp)      # store the $ra; we are calling `color_by_coordinates` from `color_screen_with_borders.asm`
    
    # file descriptor; $v0 will contain the file descriptor (after syscall)
    li $v0, 13             # open file
    la $a0, mazeFilename
    li $a1, 0              # open for read
    li $a2, 0
    syscall
    
    move $s0, $v0          # move file descriptor for later use
    
    blez $s0, return_read_maze_file


    # read file into buffer
    li $v0, 14             # read file
    move $a0, $s0          # with file descriptor
    la $a1, buffer         # into buffer
    li $a2, 2048           # with max amount of letters, 2048
    syscall
    
    blez $v0, return_read_maze_file
    
    move $s0, $v0          # amount of bytes read; NOTE: using $s0, because we don't need the file descriptor anymore
    li $s1, 0              # row
    li $s2, 0              # column
    li $s3, 0              # current position in the file text
    
store_in_mem:
    la $t0, buffer
    addu $t0, $t0, $s3
    lb $t0, 0($t0)
    #lb $t0, buffer($s3)    # byte at position $s3 in the buffer
    beq $t0, NULL_CHAR, return_read_maze_file        # if char[i] == '\0': return
    beq $t0, NEWLINE, next_row                       # if char[i] == '\n': goto next_row
    beq $t0, CHAR_W, wall_pixel                      # if char[i] == 'w': goto wall_pixel
    beq $t0, CHAR_S, player_pixel                    # if char[i] == 's': goto player_pixel
    beq $t0, CHAR_U, exit_pixel                      # if char[i] == 'u': goto exit_pixel

    # $s4 is used to store the color value
passage_pixel:
    lw $s4, passageColor         # current pixel is passage
    j color_pixel

wall_pixel:
    lw $s4, wallColor            # current pixel is wall
    j color_pixel

player_pixel:
    move $s5, $s1                # store player position row
    move $s6, $s2                # store player position column

    lw $s4, playerColor          # current pixel is the player
    j color_pixel

exit_pixel:
    lw $s4, exitColor            # current pixel is the exit

color_pixel:    
    move $a0, $s1                   # row as an argument
    move $a1, $s2                   # column as an argument
    move $a2, $s4                   # color value as an argument
    jal color_by_coordinates        # globl function from color_screen_with_border.asm

    # end of pixel coloring
    addi $s2, $s2, 1                # increase current column position by 1
    addi $s3, $s3, 1                # increase current char position by 1
    j store_in_mem
    
next_row:
    li $s2, 0              # reset column
    addi $s1, $s1, 1       # increase row by 1
    addi $s3, $s3, 1       # increase current char by 1
    j store_in_mem
    
return_read_maze_file:
    move $v0, $s5          # move for return user position row
    move $v1, $s6          # move for return user position column

    # restore the old values
    lw $ra, -32($fp)
    lw $s6, -28($fp)
    lw $s5, -24($fp)
    lw $s4, -20($fp)
    lw $s3, -16($fp)
    lw $s2, -12($fp)
    lw $s1, -8($fp)
    lw $s0, -4($fp)
    move $sp, $fp
    lw $fp, 0($sp)
    
    jr $ra




#########################
# FUNCTION: update the position of the user
# ARGS:
#   $a0   current_row:    player current row position
#   $a1   current_column: player current column position
#   $a2   to_row:         player move to row
#   $a3   to_column:      player move to column
# RETURNS:
#   $v0   updated_current_row
#   $v1   updated_current_column
#########################
update_player_position:
    sw $fp, 0($sp)        # previous frame-pointer in stack
    move $fp, $sp         # current frame-pointer points to (current) top of stack
    subu $sp, $sp, 24     # create place for 20 bytes; $s0, $s1, $s2, $s3, $ra
    sw $s0, -4($fp)       # store the $s0; used for current player row
    sw $s1, -8($fp)       # store the $s1; used for current player column
    sw $s2, -12($fp)      # store the $s2; used for to player row
    sw $s3, -16($fp)      # store the $s3; used for to player column
    sw $ra, -20($fp)      # store the $ra; we are calling `color_by_coordinates` from `color_screen_with_borders.asm`
    
    # store the values, of current and to player position
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    # check if to
    bltz $s2, return_update_player_position        # if (to_row < 0) return
    bltz $s3, return_update_player_position        # if (to_column < 0) return
    
    
    lw $t0, amountOfRows
    lw $t1, amountOfColumns
    bge $s2, $t0, return_update_player_position    # if (to_row >= 16) return
    bge $s3, $t1, return_update_player_position    # if (to_column >= 32) return
    
    
    # check if to_row and to_column is a wall, and if so return
    move $a0, $s2
    move $a1, $s3
    jal translate_coordinates    # returns address in $v0
    lw $t0, wallColor            # get wall color value
    lw $t1, 0($v0)               # get value of player to position address in memory
    beq $t0, $t1, return_update_player_position    # if (is_wall(translate_coordinates(to_row, to_column))) return
    
    ###
    # Now we are sure that we can replace the values.
    # NOTE: The address of player to position, is still in $v0
    ###
    
    lw $t0, playerColor         # load player color for use
    sw $t0, 0($v0)              # changes color of `player to position`, to player color
    
    # We also have to change the color of the previous position of the player
    move $a0, $s0
    move $a1, $s1
    jal translate_coordinates   # returns address in $v0
    
    lw $t0, passageColor        # load passage color for use
    sw $t0, 0($v0)              # changes color of previous player position to passage color
    
    
    move $s0, $s2        # move player to row to current player row
    move $s1, $s3        # move player to column to current player column
    
return_update_player_position:
    move $v0, $s0        # move current player row position to return
    move $v1, $s1        # move current player column position to return

    # restore the old values
    lw $ra, -20($fp)
    lw $s3, -16($fp)
    lw $s2, -12($fp)
    lw $s1, -8($fp)
    lw $s0, -4($fp)
    move $sp, $fp
    lw $fp, 0($sp)
    
    jr $ra        # return to caller
    
