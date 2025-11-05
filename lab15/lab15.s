.set car_base, 0xffff0100

.set gps, 0x0
.set steering_wheel, 0x20
.set engine, 0x21
.set handbrake, 0x22

.set x_coord, 0x10
.set y_coord, 0x14
.set z_coord, 0x18

.bss
    user_stack: .skip 200
    isr_stack: .skip 200

    x_pos: .skip 4
    y_pos: .skip 4
    z_pos: .skip 4

.text
int_handler:
    # saving the context
    csrrw sp, mscratch, sp
    addi sp, sp, -64
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw t3, 16(sp)

    # a7 has the syscall code
    li t0, 10
    bne a7, t0, 1f
    jal syscall_set_engine_and_steering
    j 2f

    1:
    li t0, 11
    bne a7, t0, 1f
    jal syscall_set_hand_brake
    j 2f

    1:
    li t0, 15
    bne a7, t0, 2f
    jal syscall_get_position

    2:
    # loading the return address incremented in 4
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0

    # recovering the context
    lw t3, 16(sp)
    lw t2, 12(sp)
    lw t1, 8(sp)
    lw t0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 64
    csrrw sp, mscratch, sp
    mret

syscall_set_engine_and_steering:
    # a0 has the movement direction
    # a1 has the steering wheel angle

    # checking if the params are valid
    li t0, -1
    blt a0, t0, invalid_params

    li t0, 1
    bgt a0, t0, invalid_params

    li t0, -127
    blt a1, t0, invalid_params

    li t0, 127
    bgt a1, t0, invalid_params

    # setting the engine and the steering wheel
    li t0, car_base

    sb a0, engine(t0)
    sb a1, steering_wheel(t0)

    li a0, 0
    ret

    invalid_params:
        li a0, -1
        ret

syscall_set_hand_brake:
    # a0 has the hand brake status
    li t0, car_base

    sb a0, handbrake(t0)
    ret

syscall_get_position:
    # a0 has the address to store x
    # a1 has the address to store y
    # a2 has the address to store z
    li t0, car_base

    li t1, 1
    sb t1, gps(t0)

    lw t1, x_coord(t0)
    lw t2, y_coord(t0)
    lw t3, z_coord(t0)

    sw t1, 0(a0)
    sw t2, 0(a1)
    sw t3, 0(a2)

    ret

.globl _start
_start:
    # allocating the user_stack
    la sp, user_stack
    addi sp, sp, 200

    # allocating the isr_stack
    la t0, isr_stack
    addi t0, t0, 200
    csrw mscratch, t0

    # passing the address of the int_handler to mtvec
    la t0, int_handler
    csrw mtvec, t0

    # changing the permission to U-Mode and turning local interruptions on
    csrr t0, mstatus
    li t1, ~0x1800
    and t0, t0, t1              # U-Mode
    ori t0, t0, 0x8             # local interruptions
    csrw mstatus, t0

    # turning the external interruptions on
    li t0, 0x800
    csrw mie, t0

    # passing the address of user_main to mepc
    la t0, user_main
    csrw mepc, t0

    mret

.globl control_logic
control_logic:
    li a0, 1
    li a1, -15
    li a7, 10
    ecall

    loop:
        la a0, x_pos
        la a1, y_pos
        la a2, z_pos
        li a7, 15
        ecall

        lw t0, 0(a0)
        lw t1, 0(a2)

        li t2, 73
        li t3, -19

        sub t0, t0, t2
        mul t0, t0, t0

        sub t1, t1, t3
        mul t1, t1, t1

        add t0, t0, t1

        li t3, 225

        bgt t0, t3, loop

    li a0, 0
    li a1, 0
    li a7, 10
    ecall

    li a0, 1
    li a7, 11
    ecall

    ret
