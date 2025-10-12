.text
.globl my_function
my_function:
    # a0 has value a
    # a1 has value b
    # a2 has value c

    addi sp, sp, -16
    sw ra, 12(sp)
    sw a2, 8(sp)
    sw a1, 4(sp)
    sw a0, 0(sp)

    add t0, a0, a1                  # t0 = a + b

    mv a1, a0                       # a1 = a
    mv a0, t0                       # a0 = a + b

    jal mystery_function
    mv t0, a0                       # saves the value returned

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16

    sub t0, a1, t0
    add t0, t0, a2                  # t0 = aux

    addi sp, sp, -32
    sw ra, 16(sp)
    sw t0, 12(sp)
    sw a2, 8(sp)
    sw a1, 4(sp)
    sw a0, 0(sp)

    mv a0, t0                       # first param is aux
                                    # second param is b (already in a1)
    jal mystery_function
    mv t1, a0                       # saves the value returned

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 32

    sub a0, a2, t1
    add a0, a0, t0

    ret