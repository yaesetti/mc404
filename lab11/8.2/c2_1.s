.text
.globl swap_int
swap_int:
    # a0 has int a pointer
    # a1 has int b pointer

    lw t0, 0(a0)
    lw t1, 0(a1)

    sw t1, 0(a0)
    sw t0, 0(a1)

    li a0, 0
    ret

.globl swap_short
swap_short:
    # a0 has short a pointer
    # a1 has short b pointer

    lh t0, 0(a0)
    lh t1, 0(a1)

    sh t1, 0(a0)
    sh t0, 0(a1)

    li a0, 0
    ret

.globl swap_char
swap_char:
    # a0 has char a pointer
    # a1 has char b pointer

    lbu t0, 0(a0)
    lbu t1, 0(a1)

    sb t1, 0(a0)
    sb t0, 0(a1)

    li a0, 0
    ret
