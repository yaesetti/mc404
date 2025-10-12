.text
.globl fill_array_int
fill_array_int:
    addi sp, sp, -416
    sw ra, 404(sp)
    mv t6, sp

    li t0, 0
    li t1, 100

    1:
        beq t0, t1, 1f

        sw t0, 0(t6)

        addi t0, t0, 1
        addi t6, t6, 4
        j 1b
    1:

    mv a0, sp
    jal mystery_function_int

    lw ra, 404(sp)
    addi sp, sp, 416

    ret

.globl fill_array_short
fill_array_short:
    addi sp, sp, -208
    sw ra, 200(sp)
    mv t6, sp

    li t0, 0
    li t1, 100

    1:
        beq t0, t1, 1f

        sh t0, 0(t6)

        addi t0, t0, 1
        addi t6, t6, 2
        j 1b
    1:

    mv a0, sp
    jal mystery_function_short

    lw ra, 200(sp)
    addi sp, sp, 208

    ret

.globl fill_array_char
fill_array_char:
    addi sp, sp, -112
    sw ra, 100(sp)
    mv t6, sp

    li t0, 0
    li t1, 100

    1:
        beq t0, t1, 1f

        sb t0, 0(t6)

        addi t0, t0, 1
        addi t6, t6, 1
        j 1b
    1:

    mv a0, sp
    jal mystery_function_char

    lw ra, 100(sp)
    addi sp, sp, 112

    ret
