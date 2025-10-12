.text
.globl node_op
node_op:
    # a0 has the node pointer
    lw t0, 0(a0)            # a
    lbu t1, 4(a0)           # b
    lbu t2, 5(a0)           # c
    lh t3, 6(a0)            # d

    add a0, t0, t1
    sub a0, a0, t2
    add a0, a0, t3

    ret
