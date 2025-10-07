.data
input_file: .asciz "image.pgm"
buffer: .space 263000

.text
.globl _start
open:
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open
    ecall
    ret

close:
    li a7, 57            # syscall close
    ecall
    ret

read:
    la a1, buffer
    li a2, 263000           # number of chars
    li a7, 63               # syscall read (63)
    ecall

    addi s3, s3, 3          # skips P5\n
    ret

until_not_ws:
    lbu t0, 0(s3)
    li t1, '0'
    bge t0, t1, 1f
    addi s3, s3, 1
    j until_not_ws
    1:
        ret

set_canvas:
    mv a0, s1
    mv a1, s2
    li a7, 2201
    ecall
    ret

set_pixel:
    li a7, 2200
    ecall
    ret

calculate_filter:
    mv a1, s3

    li a0, 0

    sub a1, a1, a2
    addi a1, a1, -1

    lbu t4, 0(a1)
    sub t4, zero, t4
    add a0, a0, t4

    lbu t4, 1(a1)
    sub t4, zero, t4
    add a0, a0, t4

    lbu t4, 2(a1)
    sub t4, zero, t4
    add a0, a0, t4

    add a1, a1, a2

    lbu t4, 0(a1)
    sub t4, zero, t4
    add a0, a0, t4

    lbu t4, 1(a1)
    li t5, 8
    mul t4, t4, t5
    add a0, a0, t4

    lbu t4, 2(a1)
    sub t4, zero, t4
    add a0, a0, t4

    add a1, a1, a2

    lbu t4, 0(a1)
    sub t4, zero, t4
    add a0, a0, t4

    lbu t4, 1(a1)
    sub t4, zero, t4
    add a0, a0, t4

    lbu t4, 2(a1)
    sub t4, zero, t4
    add a0, a0, t4

    bge a0, zero, 1f
    li a0, 0
    ret

    1:
    li t5, 255
    ble a0, t5, 1f
    li a0, 255
    ret

    1:
        ret

_start:
    jal open
    mv s0, a0               # image file descriptor
    li s1, 0                # image width
    li s2, 0                # image height

    la s3, buffer

    mv a0, s0
    jal read

    jal until_not_ws

    1:
        lbu t0, 0(s3)
        addi t0, t0, -'0'

        li t1, 10
        mul s1, s1, t1
        add s1, s1, t0

        addi s3, s3, 1
        lbu t0, 0(s3)
        li t2, '0'
        bge t0, t2, 1b
    1:

    jal until_not_ws

    1:
        lbu t0, 0(s3)
        addi t0, t0, -'0'

        li t1, 10
        mul s2, s2, t1
        add s2, s2, t0

        addi s3, s3, 1
        lbu t0, 0(s3)
        li t2, '0'
        bge t0, t2, 1b
    1:

    jal until_not_ws
    addi s3, s3, 3          # skips 255
    jal until_not_ws

    jal set_canvas

    mv t1, s2               # t1 = max height
    mv t3, s1               # t3 = max width

    li t0, 0                # t0 = current y position
    1:
        bge t0, t1, 1f

        li t2, 0            # t2 = current x position
        2:
            bge t2, t3, 2f

            beq t0, zero, edge
            addi t4, t1, -1
            beq t0, t4, edge
            beq t2, zero, edge
            addi t4, t3, -1
            beq t2, t4, edge

            addi sp, sp, -16
            sw t0, 0(sp)
            sw t1, 4(sp)
            sw t2, 8(sp)
            sw t3, 12(sp)
            
            mv a2, t3
            jal calculate_filter
            mv t4, a0
            
            lw t0, 0(sp)
            lw t1, 4(sp)
            lw t2, 8(sp)
            lw t3, 12(sp)
            addi sp, sp, 16

            pixel:
            mv t5, t4

            slli t5, t5, 8
            add t5, t5, t4

            slli t5, t5, 8
            add t5, t5, t4

            slli t5, t5, 8
            addi t5, t5, 255

            mv a0, t2
            mv a1, t0
            mv a2, t5
            jal set_pixel

            addi s3, s3, 1
            addi t2, t2, 1
            j 2b

            edge:
                li t4, 0
                j pixel
        2:

        addi t0, t0, 1
        j 1b
    1:

    mv a0, s0
    jal close

    jal exit

exit:
    li a0, 0
    li a7, 93
    ecall
