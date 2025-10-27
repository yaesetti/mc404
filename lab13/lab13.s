.set base, 0xffff0100
.set write_trigger, 0x0
.set write_buffer, 0x1
.set read_trigger, 0x2
.set read_buffer, 0x3

.bss
    input: .skip 200
    output: .skip 200
    temp: .skip 200
    temp_buffer: .skip 200

.text
.globl _start
_start:
    addi sp, sp, -16
    sw s0, 0(sp)

    li s0, base

    la a0, input
    jal read
    lb t0, 0(a0)

    li t1, '1'
    bne t0, t1, 1f
    la a0, input
    jal read
    jal op1
    jal write
    j 2f

    1:
    li t1, '2'
    bne t0, t1, 1f
    la a0, input
    jal read
    jal op2
    jal write
    j 2f

    1:
    li t1, '3'
    bne t0, t1, 1f
    la a0, input
    jal read
    jal op3
    jal write
    j 2f

    1:
    li t1, '4'
    bne t0, t1, 1f
    la a0, input
    jal read
    jal op4
    jal write

    2:
    lw s0, 0(sp)
    addi sp, sp, 16
    j exit

read:
    mv t1, a0
    li a1, 0

    2:
        li t0, 1
        sb t0, read_trigger(s0)
        1:
            lbu t0, read_trigger(s0)
            bnez t0, 1b
        lbu t0, read_buffer(s0)
        sb t0, 0(t1)

        li t2, '\n'
        beq t0, t2, 2f

        addi t1, t1, 1
        addi a1, a1, 1
        j 2b
    2:

    ret

write:
    mv t0, a0

    2:
        lbu t1, 0(t0)
        sb t1, write_buffer(s0)

        li t2, 1
        sb t2, write_trigger(s0)
        1:
            lbu t2, write_trigger(s0)
            bnez t2, 1b

        li t3, '\n'
        beq t1, t3, 2f

        addi t0, t0, 1
        j 2b
    2:

    ret

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

itoa:
    # a0 has the int value
    # a1 has the buffer pointer
    # a2 has the base
    mv t0, a1                   # t0 has a copy of the buffer pointer

    bnez a0, 1f
    li t0, '0'
    sb t0, 0(a1)
    li t0, '\n'
    sb t0, 1(a1)
    mv a0, a1
    ret

    1:
    li t1, 10
    beq a2, t1, dec_base

    2:
    la t1, temp_buffer          # will store the inverted number

    li t6, 0                    # counter
    1:
        beqz a0, 1f             # stops when a0 == 0
        remu t3, a0, a2         # gets the first digit

        divu a0, a0, a2         # removes the first digit
        
        li t4, 9
        ble t3, t4, 4f          # if <= 9 goto 4:
        addi t3, t3, 55         # converts to A-F ASCII
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

    li t1, '\n'
    sb t1, 0(t0)                # adds the \n

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

op1:
    ret

op2:
    # a0 has the string
    # a1 has the size of the string, excluding \n
    mv t0, a0
    la t1, temp
    mv t2, a1

    add t0, t0, t2
    addi t0, t0, -1

    1:
        lbu t3, 0(t0)
        sb t3, 0(t1)

        addi t0, t0, -1
        addi t1, t1, 1
        addi t2, t2, -1

        bnez t2, 1b
    1:

    li t3, '\n'
    sb t3, 0(t1)

    la a0, temp
    ret

op3:
    addi sp, sp, -16
    sw ra, 0(sp)

    jal atoi
    
    la a1, temp
    li a2, 16
    jal itoa

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

op4:
    # a0 has the string
    addi sp, sp, -16
    sw ra, 0(sp)

    mv t0, a0

    li t6, 0
    lbu t1, 0(t0)
    li t2, '-'
    bne t1, t2, 1f
    li t6, 1
    addi t0, t0, 1

    1:
    li a1, 0
    1:
        lbu t1, 0(t0)
        li t2, ' '
        beq t1, t2, 1f

        li t2, 10
        mul a1, a1, t2

        addi t1, t1, -'0'
        add a1, a1, t1
        
        addi t0, t0, 1
        j 1b
    1:

    beqz t6, 1f
    sub a1, zero, a1

    1:
    addi t0, t0, 1

    lbu a2, 0(t0)

    addi t0, t0, 2

    li t6, 0
    lbu t1, 0(t0)
    li t2, '-'
    bne t1, t2, 1f
    li t6, 1
    addi t0, t0, 1

    1:
    li a3, 0
    1:
        lbu t1, 0(t0)
        li t2, '\n'
        beq t1, t2, 1f

        li t2, 10
        mul a3, a3, t2

        addi t1, t1, -'0'
        add a3, a3, t1
        
        addi t0, t0, 1
        j 1b
    1:

    beqz t6, 1f
    sub a3, zero, a3

    1:
    li t0, '+'
    bne a2, t0, 1f
    add a0, a1, a3
    j 2f

    1:
    li t0, '-'
    bne a2, t0, 1f
    sub a0, a1, a3
    j 2f

    1:
    li t0, '*'
    bne a2, t0, 1f
    mul a0, a1, a3
    j 2f

    1:
    div a0, a1, a3

    2:

    la a1, temp
    li a2, 10
    jal itoa

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

exit:
    li a0, 0
    li a7, 93
    ecall
