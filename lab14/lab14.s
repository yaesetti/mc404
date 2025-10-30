.set gpt_base, 0xffff0100
.set gpt_trigger, 0x0
.set gpt_buffer, 0x4
.set gpt_program, 0x8

.set midi_base, 0xffff0300
.set midi_ch, 0x0
.set midi_inst, 0x2
.set midi_note, 0x4
.set midi_vel, 0x5
.set midi_dur, 0x6

.bss
.globl _system_time
    _system_time: .skip 4
    isr_stack: .skip 200
    user_stack: .skip 200

.text
.globl _start
_start:
    # allocating the user stack
    la sp, user_stack
    addi sp, sp, 200

    # allocating the isr stack
    la t0, isr_stack
    addi t0, t0, 200
    csrw mscratch, t0

    # passing to mtvec the address of the gpt_isr
    la t0, gpt_isr
    csrw mtvec, t0

    # turning local interruptions on
    csrr t1, mstatus
    ori t1, t1, 0x8
    csrw mstatus, t1

    # turning external interruptions on
    li t2, 0x800
    csrw mie, t2

    # setting up the first interruption
    li t0, gpt_base
    li t1, 100
    sw t1, gpt_program(t0)

    # calling main
    jal main

    j exit

gpt_isr:
    # saving context
    csrrw sp, mscratch, sp
    addi sp, sp, -64
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw t0, 8(sp)
    sw t1, 12(sp)
    sw t2, 16(sp)

    # treating the interruption

    # loading the base address of gpt in a0
    li a0, gpt_base

    # triggering the gpt and waiting it
    li t0, 1
    sb t0, gpt_trigger(a0)
    1:
        lbu t0, gpt_trigger(a0)
        bnez t0, 1b

    # adding 100ms to _system_time
    li t0, 100
    la t1, _system_time
    lw t2, 0(t1)
    add t2, t2, t0
    sw t2, 0(t1)

    # setting up the next interruption
    li t0, 100
    sw t0, gpt_program(a0)

    # recovering context
    lw t2, 16(sp)
    lw t1, 12(sp)
    lw t0, 8(sp)
    lw a1, 4(sp)
    lw a0, 0(sp)
    addi sp, sp, 64
    csrrw sp, mscratch, sp
    mret

.globl play_note
play_note:
    # a0 has the ch
    # a1 has the inst
    # a2 has the note
    # a3 has the vel
    # a4 has the dur

    # loading the base address of the midi player in t0
    li t0, midi_base

    sb a0, midi_ch(t0)
    sh a1, midi_inst(t0)
    sb a2, midi_note(t0)
    sb a3, midi_vel(t0)
    sh a4, midi_dur(t0)
    
    ret 

exit:
    li a0, 0
    li a7, 93
    ecall
