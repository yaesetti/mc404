.data
    input: .skip 20
    output: .skip 4

.text

.globl _start

_start:
    jal read
    jal sqrt

read:
    li a0, 0                   # file descriptor = 0 (stdin)
    la a1, input               # buffer to write the data
    li a2, 20                  # size (reads only 1 byte)
    li a7, 63                  # syscall read (63)
    ecall
    ret

write:
    li a0, 1                   # file descriptor = 1 (stdout)
    la a1, output              # buffer
    li a2, 1                   # size
    li a7, 64                  # syscall write (64)
    ecall
    ret
    
sqrt:
    la a4, input
    la a3, output
    li t6, 4
    3:  
        li a1, 0                # número inputado
        li t0, 4                # contador do loop
        li t2, 1000
        li t3, 10               # const t3 = 10
        1:
            lbu t1, 0(a4)
            addi t1, t1, -'0'
            mul t1, t1, t2
            add a1, a1, t1
            addi a4, a4, 1

            divu t2, t2, t3
            addi t0, t0, -1
            bnez t0, 1b
        1:
        addi a4, a4, 1
        li t0, 10
        li t1, 2                # const t1 = 2
        divu a2, a1, t1         # initial guess k = y/2

        2:
            divu t3, a1, a2
            add t3, t3, a2
            divu a2, t3, t1

            addi t0, t0, -1
            bnez t0, 2b
        2:

        li t0, 4
        li t2, 1000
        li t3, 10
        mv t5, a2
        4:  
        debug1:
            divu t4, t5, t2
            remu t5, t5, t2
            addi t4, t4, '0'
            sb t4, 0(a3)
            jal write

            divu t2, t2, t3
            addi t0, t0, -1
            bnez t0, 4b
        4:

        li t1, ' '
        sb t1, 0(a3)
        jal write

        addi t6, t6, -1
        bnez t6, 3b
    3:

    li t1, '\n'
    sb t1, 0(a3)
    jal write

    jal exit

exit:
    li a0, 0  # return code 0
    li a7, 93 # syscall exit (93)
    ecall
