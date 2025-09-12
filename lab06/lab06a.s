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
    la a1, input_address       # buffer
    li a2, 20                   # size
    li a7, 64                  # syscall write (64)
    ecall
    ret

str2int:
    lbu t0, 0(a1) # 0xxx
    lbu t1, 1(a1) # x0xx
    lbu t2, 2(a1) # xx0x
    lbu t3, 3(a1) # xxx0

    addi t0, t0, -48
    addi t1, t1, -48
    addi t2, t2, -48
    addi t3, t3, -48

    li t4, 0        # has the int value of the 4 digits number
    mul t4, t4, 10
    add t4, t4, t0

    mul t4, t4, 10
    add t4, t4, t1

    mul t4, t4, 10
    add t4, t4, t2

    mul t4, t4, 10
    add t4, t4, t3

    ret

_start:
    jal read
    jal write

    jal str2int # t4 has the int now

    li t6, 10

    1:
        beq t6, zero, 1f # stop condition

        






    jal exit

exit:
    li a0, 0  # return code 0
    li a7, 93 # syscall exit (93)
    ecall

.data
input_address: .skip 20  # buffer
