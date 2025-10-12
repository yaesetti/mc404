.text
.globl middle_value_int
middle_value_int:
    # a0 has the array pointer
    # a1 has the n value
    li t1, 2
    div t0, a1, t1
    slli t0, t0, 2

    add a0, a0, t0

    lw a0, 0(a0)

    ret

.globl middle_value_short
middle_value_short:
    # a0 has the array pointer
    # a1 has the n value
    li t1, 2
    div t0, a1, t1
    slli t0, t0, 1

    add a0, a0, t0

    lh a0, 0(a0)

    ret

.globl middle_value_char
middle_value_char:
    # a0 has the array pointer
    # a1 has the n value
    li t1, 2
    div t0, a1, t1

    add a0, a0, t0

    lbu a0, 0(a0)

    ret

.globl value_matrix
value_matrix:
    # a0 has the matrix 12x42 pointer
    # a1 has the i
    # a2 has the j
    li t0, 42
    mul t1, a1, t0
    add t1, t1, a2
    slli t1, t1, 2

    add a0, a0, t1
    lw a0, 0(a0)

    ret
