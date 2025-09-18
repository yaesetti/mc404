.globl _start

.text
read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data
    li a2, 20  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    li a0, 1                   # file descriptor = 1 (stdout)
    la a1, output_address       # buffer
    li a2, 20                   # size
    li a7, 64                  # syscall write (64)
    ecall
    ret

str2int:
    lbu t0, 0(s1) # 0xxx
    lbu t1, 1(s1) # x0xx
    lbu t2, 2(s1) # xx0x
    lbu t3, 3(s1) # xxx0

    addi t0, t0, -48
    addi t1, t1, -48
    addi t2, t2, -48
    addi t3, t3, -48

    li a3, 0
    li t4, 10

    mul a3, a3, t4
    add a3, a3, t0

    mul a3, a3, t4
    add a3, a3, t1

    mul a3, a3, t4
    add a3, a3, t2

    mul a3, a3, t4
    add a3, a3, t3

    ret

int2str:
    li t0, 1000
    divu t1, a3, t0
    remu a3, a3, t0

    li t0, 100
    divu t2, a3, t0
    remu a3, a3, t0

    li t0, 10
    divu t3, a3, t0
    remu a3, a3, t0

    mv t4, a3

    addi t1, t1, 48
    addi t2, t2, 48
    addi t3, t3, 48
    addi t4, t4, 48

    li t5, 32

    sb t1, 0(s2)
    sb t2, 1(s2)
    sb t3, 2(s2)
    sb t4, 3(s2)
    sb t5, 4(s2)

    ret

sqrt:
    li t4, 10             # t4 = 10
    mv a4, a3             # a4 = y
    mv a5, a3             # a5 = k = y
    srli a5, a5, 1        # a5 = y/2

    1:
        divu a3, a4, a5   # a3 = y/k
        add a3, a3, a5    # a3 = k + y/k
        srli a3, a3, 1    # a3 = (k + y/k) / 2

        addi t4, t4, -1   # decrements the identation counter [t4--]
        bnez t4, 1b       # if (t4 != 0) {goto 1b}
    1:

    ret

_start:
    jal read

    mv s0, a1
    addi s0, s0, 20
    
    la s1, input_address
    la s2, output_address

    1:
        jal str2int # a3 = int(a3)
        jal sqrt    # a3 = sqrt(a3)
        jal int2str # s2 = str(a3)
        addi a1, a1, 4 # a1 += 4
        addi s1, s1, 5
        addi s2, s2, 5
        bne s0, a1, 1b
    1:

    li t0, 10
    lb t0, (s2)

    debug1:
    jal write

    jal exit

exit:
    li a0, 0  # return code 0
    li a7, 93 # syscall exit (93)
    ecall

.data
input_address: .skip 20  # buffer
output_address: .skip 20 # output buffer
