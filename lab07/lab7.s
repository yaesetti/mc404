.data
    input: .skip 5
    input_decode: .skip 8

.text

.globl _start

_start:
    la a1, input
    li a2, 5
    jal read
    mv s0, a1

    li t1, 0
    1:
        li t2, 4
        lbu t0, 0(a1)
        addi t0, t0, -'0'
        sb t0, 0(a1)
        addi a1, a1, 1
        
        addi t1, t1, 1
        bne t1, t2, 1b
    1:

    lbu t1, 0(s0)               # t1 = d1
    lbu t2, 1(s0)               # t2 = d2
    lbu t3, 2(s0)               # t3 = d3
    lbu t4, 3(s0)               # t4 = d4

    xor s1, t1, t2              # s1 = p1 = d1 xor d2
    xor s1, s1, t4              # s1 = p1 = d1 xor d2 xor d4

    xor s2, t1, t3              # s2 = p2 = d1 xor d3
    xor s2, s2, t4              # s2 = p2 = d1 xor d3 xor d4

    xor s3, t2, t3              # s3 = p3 = d2 xor d3
    xor s3, s3, t4              # s3 = p3 = d2 xor d3 xor d4

    addi t0, s1, '0'
    sb t0, 0(a1)
    jal write

    addi t0, s2, '0'
    sb t0, 0(a1)
    jal write

    addi t0, t1, '0'
    sb t0, 0(a1)
    jal write

    addi t0, s3, '0'
    sb t0, 0(a1)
    jal write

    addi t0, t2, '0'
    sb t0, 0(a1)
    jal write

    addi t0, t3, '0'
    sb t0, 0(a1)
    jal write

    addi t0, t4, '0'
    sb t0, 0(a1)
    jal write

    li t0, '\n'
    sb t0, 0(a1)
    jal write

    # -----------------------------

    la a1, input_decode
    li a2, 8
    jal read
    mv a3, a1

    lb t6, 0(a3)

    lb t1, 2(a3)
    lb t2, 4(a3)
    lb t3, 5(a3)
    lb t4, 6(a3)

    sb t1, 0(a1)
    jal write
    addi t1, t1, -'0'

    sb t2, 0(a1)
    jal write
    addi t2, t2, -'0'

    sb t3, 0(a1)
    jal write
    addi t3, t3, -'0'

    sb t4, 0(a1)
    jal write
    addi t4, t4, -'0'

    li t0, '\n'
    sb t0, 0(a1)
    jal write

    xor s1, t1, t2              # s1 = p1 = d1 xor d2
    xor s1, s1, t4              # s1 = p1 = d1 xor d2 xor d4

    xor s2, t1, t3              # s2 = p2 = d1 xor d3
    xor s2, s2, t4              # s2 = p2 = d1 xor d3 xor d4

    xor s3, t2, t3              # s3 = p3 = d2 xor d3
    xor s3, s3, t4              # s3 = p3 = d2 xor d3 xor d4

    mv t1, t6
    lb t2, 1(a3)
    lb t3, 3(a3)

    addi t1, t1, -'0'
    addi t2, t2, -'0'
    addi t3, t3, -'0'

    xor s1, s1, t1
    xor s2, s2, t2
    xor s3, s3, t3

    or t0, s1, s2
    or t0, t0, s3

    addi t0, t0, '0'
    sb t0, 0(a1)
    jal write

    li t0, '\n'
    sb t0, 0(a1)
    jal write

    j exit

read:
    li a0, 0                   # file descriptor = 0 (stdin)
    li a7, 63                  # syscall read (63)
    ecall
    ret

write:
    li a0, 1                   # file descriptor = 1 (stdout)
    li a2, 1                   # size
    li a7, 64                  # syscall write (64)
    ecall
    ret

exit:
    li a0, 0
    li a7, 93
    ecall
