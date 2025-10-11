.bss
    temp_buffer: .skip 1000

.text
strlen:
    # a0 has the string pointer
    mv t0, a0                   # copy of the string pointer
    li t1, 0                    # string size
    1:
        lb t2, 0(t0)            # current char

        beqz t2, finished_len   # checks if the char is '\0', if it is, return

        addi t1, t1, 1          # if not, increment the string size
        addi t0, t0, 1          # points to the next char
        j 1b                    # loop again
    1:
    
    finished_len:
        mv a0, t1               # moves the string size to a0
        ret                     # returns

.globl puts
puts:
    # a0 has the string pointer
    addi sp, sp, -16
    sw a0, 8(sp)
    sw ra, 4(sp)
    sw fp, 0(sp)
    addi fp, sp, 16
    jal strlen                  # get string length
    mv t0, a0                   # move

    lw a0, 8(sp)                # restores a0
    add a0, a0, t0              # goes to position '\0'
    li t1, '\n'                 # load '\n'
    sb t1, 0(a0)                # changes '\0' for '\n'
    addi t0, t0, 1              # increments string size for '\n'

    mv t1, a0                   # points to the '\n'

    li a0, 1                    # file descriptor 1 (stdout)
    lw a1, 8(sp)                # load string
    mv a2, t0                   # string size
    li a7, 64                   # syscall write (64)
    ecall

    sb zero, 0(t1)              # changes '\n' back to '\0'

    lw fp, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 16
    mv a0, t0
    ret

.globl gets
gets:
    # a0 has the buffer pointer
    mv t0, a0                   # t0 has the buffer pointer
    mv t6, t0                   # creates a copy of the buffer

    1:
        li a0, 0                # file descriptor 0 (stdin)
        mv a1, t0               # load buffer
        li a2, 1                # size 1
        li a7, 63               # syscall read (63)
        ecall

        lb t1, 0(t0)            # loads the current char
        li t2, '\n'             # loads '\n'
        
        beq t1, t2, 1f          # if current character is '\n'

        addi t0, t0, 1          # else, increment pointer
        j 1b                    # go back to the loop
    1:
    sw zero, 0(t0)              # changes the '\n' to '\0'
    mv a0, t6
    ret

.globl atoi
atoi:
    # a0 has the string pointer
    mv t0, a0                   # t0 has the string pointer

    1:                          # loop that skips whitespace
        lb t1, 0(t0)
        li t2, ' '
        
        bgt t1, t2, 1f
        addi t0, t0, 1
        j 1b
    1:
    
    lb t1, 0(t0)

    li t6, 0                    # negative flag set to false
    li t2, '-'
    bne t1, t2, 2f              # if not '-' skips
    li t6, 1                    # else, negative flag set to true
    addi t0, t0, 1              # increments the string pointer
    j 1f

    2:
    li t2, '9'
    bgt t1, t2, not_number

    1:

    li a0, 0                    # int to be returned

    1:
        lb t1, 0(t0)
        li t2, '0'
        blt t1, t2, atoi_done
        li t2, '9'
        bgt t1, t2, atoi_done

        addi t1, t1, -'0'

        li t2, 10

        mul a0, a0, t2
        add a0, a0, t1

        addi t0, t0, 1
        j 1b
    1:

    not_number:
        li a0, 0
        ret
    
    atoi_done:
        beqz t6, 1f
        sub a0, zero, a0
        1:
        ret

.globl itoa
itoa:
    # a0 has the int value
    # a1 has the buffer pointer
    # a2 has the base
    mv t0, a1                   # t0 has a copy of the buffer pointer

    bnez a0, 1f
    li t0, '0'
    sb t0, 0(a1)
    sb zero, 1(a1)
    mv a0, a1
    ret

    1:
    li t1, 10
    beq a2, t1, dec_base

    la t1, temp_buffer          # will store the inverted number

    li t6, 0                    # counter
    2:
    1:
        beqz a0, 1f             # stops when a0 == 0
        remu t3, a0, a2          # gets the first digit

        divu a0, a0, a2          # removes the first digit
        
        li t4, 9
        ble t3, t4, 4f          # if <= 9 goto 4:
        addi t3, t3, 87         # converts to a-f ASCII
        j 3f

        4:
        addi t3, t3, '0'        # converts to 0-9 ASCII

        3:
        sb t3, 0(t1)            # stores in the temp_buffer
        addi t1, t1, 1          # increments the temp_buffer pointer
        addi t6, t6, 1          # increments the counter
        j 1b                    # loops
    1:

    addi t1, t1, -1
    1:
        beqz t6, 1f
        lb t2, 0(t1)
        sb t2, 0(t0)

        addi t1, t1, -1
        addi t0, t0, 1
        addi t6, t6, -1
        j 1b
    1:

    sb zero, 0(t0)              # adds the null terminator

    mv a0, a1
    ret

    dec_base:
        bgez a0, 2b             # if a0 >= 0, skips to loop
                                # else
        li t1, '-'              # load '-'
        sb t1, 0(t0)            # stores at the start of the buffer
        addi t0, t0, 1          # increments the buffer pointer
        sub a0, zero, a0        # makes the number positive
        j 2b                    # goes to the loop

.globl recursive_tree_search
recursive_tree_search:
    # a0 has the root_node pointer
    # a1 has the key value
    # a2 has the depth of the current node
    li a2, 1
    j recursive_tree_search_internal

    recursive_tree_search_internal:
        addi sp, sp, -32
        sw ra, 16(sp)
        sw a0, 12(sp)
        sw a1, 8(sp)
        sw a2, 4(sp)
        sw a3, 0(sp)

        # if current node is NULL, return 0
        bnez a0, 1f
        li a0, 0
        j ret_depth

        # if current node has the value, return the current depth
        1:
        lw a3, 0(a0)
        bne a3, a1, 1f
        mv a0, a2
        j ret_depth

        # else, checks in the left branch
        1:
        lw a0, 4(a0)
        addi a2, a2, 1
        jal recursive_tree_search_internal

        li a3, 0
        beq a0, a3, 1f
        j ret_depth

        1:
        lw a0, 12(sp)
        lw a1, 8(sp)
        lw a2, 4(sp)

        lw a0, 8(a0)
        addi a2, a2, 1
        jal recursive_tree_search_internal
        j ret_depth
        
        ret_depth:
            lw ra, 16(sp)
            lw a3, 0(sp)
            addi sp, sp, 32
            ret

.globl exit
exit:
    li a0, 0
    li a7, 93
    ecall