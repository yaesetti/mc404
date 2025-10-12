.text
.globl operation
operation:
    add a0, a1, a2
    sub a0, a0, a5
    add a0, a0, a7

    lw t0, 8(sp)
    lw t1, 16(sp)

    add a0, a0, t0
    sub a0, a0, t1

    ret
