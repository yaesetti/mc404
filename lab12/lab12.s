.set base, 0xffff0100
.set gps, 0x0
.set x_euler, 0x4
.set y_euler, 0x8
.set z_euler, 0xc
.set x_coord, 0x10
.set y_coord, 0x14
.set z_coord, 0x18

.set steering_whell, 0x20
.set engine, 0x21
.set handbreak, 0x22

.text
.globl _start

_start:
    jal self_driving_car
    j exit

self_driving_car:
    li a0, 0xffff0100

    li t0, -15
    sb t0, steering_whell(a0)

    li t0, 1
    sb t0, engine(a0)

    loop:
    li t0, 1
    sb t0, gps(a0)

        lw t0, x_coord(a0)
        lw t1, z_coord(a0)

        li t2, 73
        li t3, -19

        sub t0, t0, t2
        mul t0, t0, t0

        sub t1, t1, t3
        mul t1, t1, t1

        add t0, t0, t1

        li t3, 225

        bgt t0, t3, loop

    li t0, 0
    sb t0, engine(a0)

    li t0, 0
    sb t0, steering_whell(a0)

    li t0, 1
    sb t0, handbreak(a0)

    ret

exit:
    li a0, 0
    li a7, 93
    ecall
