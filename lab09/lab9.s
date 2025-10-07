.bss
    input: .skip 100
    output: .skip 100

.text
read:
    li a0, 0                   # file descriptor = 0 (stdin)
    la a1, input
    li a2, 1
    li a7, 63                  # syscall read (63)
    ecall
    ret

write:
    li a0, 1                   # file descriptor = 1 (stdout)
    la a1, output
    li a2, 1
    li a7, 64                  # syscall write (64)
    ecall
    ret

print_number:
    addi sp, sp, -16
    sw ra, 4(sp)
    sw a0, 0(sp)

    bgez a0, positive_number

    li t0, '-'
    la t1, output
    sb t0, 0(t1)

    li a0, 1                   # file descriptor = 1 (stdout)
    la a1, output
    li a2, 1
    li a7, 64                  # syscall write (64)
    ecall

    lw a0, 0(sp)
    sub a0, zero, a0
    sw a0, 0(sp)

    positive_number:
    lw a0, 0(sp)

    li t0, 10
    blt a0, t0, print_single_digit

    divu a0, a0, t0
    jal print_number

    lw a0, 0(sp)
    li t0, 10
    remu a0, a0, t0

    print_single_digit:
        addi a0, a0, '0'

        la t1, output
        sb a0, 0(t1)

        li a0, 1                   # file descriptor = 1 (stdout)
        la a1, output
        li a2, 1
        li a7, 64                  # syscall write (64)
        ecall

        lw ra, 4(sp)
        lw a0, 0(sp)
        addi sp, sp, 16
        ret

read_number:

    li s7, 0
    li t1, 10
    li t6, 0                # negative flag = false at start
    
    2:
    1:
        addi sp, sp, -16
        sw ra, 0(sp)
        jal read
        lw ra, 0(sp)
        addi sp, sp, 16
        la a1, input
        lb a2, 0(a1)

        li t0, '\n'
        li t2, '-'
        
        beq a2, t2, set_neg

        beq a2, t0, read_done

        mul s7, s7, t1

        addi a2, a2, -'0'

        add s7, s7, a2
        j 1b
    1:

    read_done:
        bnez t6, negate_number
        mv a0, s7
        ret
    
    set_neg:
        li t6, 1            # negative flag set to true
        j 2b
    
    negate_number:
        sub s7, zero, s7
        mv a0, s7
        ret

.globl _start
_start:
    la s0, head_node        # active node
    
    jal read_number
    mv s1, a0               # number we are searching

    li s2, 0                # index of the node we are at

    1:
        beqz s0, not_found

        lw t0, 0(s0)        # first number
        lw t1, 4(s0)        # second number

        add t0, t0, t1      # sum of the numbers

        beq s1, t0, found

        addi s2, s2, 1      # increments the index we are at
        lw s0, 8(s0)        # next node become the active node
        j 1b
    1:

    found:
        mv a0, s2
        jal print_number

        li a0, '\n'
        la t1, output
        sb a0, 0(t1)
        jal write

        jal exit

    not_found:
        li a0, -1
        jal print_number

        li a0, '\n'
        la t1, output
        sb a0, 0(t1)
        jal write

        jal exit

exit:
    li a0, 0
    li a7, 93
    ecall
