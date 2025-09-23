.data
    input_coord: .skip 12
    input_times: .skip 20
    output: .skip 12

.text
_start:
    la a1, input_coord
    li a2, 12
    jal read
    mv s0, a1                   # s0 saves the address of input_coord

    jal signed2int
    mv s3, a0                   # s3 = Yb

    addi s0, s0, 1              # skip char ' '

    jal signed2int
    mv s4, a0                   # s4 = Xc

    la a1, input_times
    li a2, 20
    jal read
    mv s1, a1                   # s1 saves the address of input_times

    jal unsigned2int
    mv s5, a0                   # s5 = Ta
    addi s1, s1, 1

    jal unsigned2int
    mv s6, a0                   # s6 = Tb
    addi s1, s1, 1

    jal unsigned2int
    mv s7, a0                   # s7 = Tc
    addi s1, s1, 1

    jal unsigned2int
    mv s8, a0                   # s8 = Tr

    sub s5, s8, s5             # deltaA = Tr - Ta
    sub s6, s8, s6             # deltaB = Tr - Tb
    sub s7, s8, s7             # deltaC = Tr - Tc

    li t0, 3
    li t1, 10                   # speed of light

    mul s5, s5, t0              # deltaA * 3
    div s5, s5, t1              # deltaA / 10 = Da

    mul s6, s6, t0              # deltaB * 3
    div s6, s6, t1              # deltaB / 10 = Db

    mul s7, s7, t0              # deltaC * 3
    div s7, s7, t1              # deltaC / 10 = Dc

    mul s10, s3, s3             # s10 = Yb²
    mul s11, s4, s4             # s11 = Xc²
    mul s5, s5, s5              # s5 = Da²
    mul s6, s6, s6              # s6 = Db²
    mul s7, s7, s7              # s7 = Dc²

    li s9, 0
    add s9, s9, s5              # s9 = X = Da²
    add s9, s9, s11             # s9 = X = Da² + Xc²
    sub s9, s9, s7              # s9 = X = Da² + Xc² - Dc²
    add t1, s4, s4              # t1 = 2Xc
    div s9, s9, t1              # s9 = X = (Da²+Xc²-Dc²) / 2Xc

    mv a0, s9

    la a3, output
    li t1, 1000
    li t2, 10
    li t6, 4
    mv t5, a0

    blt t5, zero, 7f

    li t0, '+'
    sb t0, 0(a3)
    jal write
    j 1f

    7:
        li t0, '-'
        sb t0, 0(a3)
        sub t5, zero, t5
        jal write

    1:
        divu t4, t5, t1
        remu t5, t5, t1
        addi t4, t4, '0'
        sb t4, 0(a3)
        jal write

        divu t1, t1, t2
        addi t6, t6, -1
        bnez t6, 1b
    1:

    li t1, ' '
    sb t1, 0(a3)
    jal write

    li s8, 0                    # s8 = Y
    add s8, s8, s5              # s8 = Y = Da²
    add s8, s8, s10             # s8 = Y = Da² + Yb²
    sub s8, s8, s6              # s8 = Y = Da² + Yb² - Db²
    add t0, s3, s3              # t0 = 2Yb
    div s8, s8, t0              # s8 = Y = (Da²+Yb²-Db²) / 2Yb

    mv a0, s8
    
    la a3, output
    li t1, 1000
    li t2, 10
    li t6, 4
    mv t5, a0

    blt t5, zero, 7f

    li t0, '+'
    sb t0, 0(a3)
    jal write
    j 1f

    7:
        li t0, '-'
        sb t0, 0(a3)
        sub t5, zero, t5
        jal write

    1:
        divu t4, t5, t1
        remu t5, t5, t1
        addi t4, t4, '0'
        sb t4, 0(a3)
        jal write

        divu t1, t1, t2
        addi t6, t6, -1
        bnez t6, 1b
    1:

    li t1, '\n'
    sb t1, 0(a3)
    jal write
    
    jal exit

read:
    li a0, 0                   # file descriptor = 0 (stdin)
    li a7, 63                  # syscall read (63)
    ecall
    ret

write:
    li a0, 1
    la a1, output
    li a2, 1
    li a7, 64
    ecall
    ret

signed2int:
    li t1, '-'                  # const '-'
    lb t6, 0(s0)               # carrega o primeiro char do input, o sinal
    addi s0, s0, 1
    li t3, 1000                 # potencia de dez
    li t4, 10                   # const 10
    li a0, 0                    # número int

    li t5, 4                    # contador do loop 2
    2:
        lb t2, 0(s0)           # carrega o char
        addi t2, t2, -'0'       # char -> int
        mul t2, t2, t3          # pega a potência de dez
        add a0, a0, t2          # soma ao número int

        addi s0, s0, 1          # incrementa o ponteiro de input

        divu t3, t3, t4         # reduz a potência de dez
        addi t5, t5, -1         # tira um do contador do loop 2
        bnez t5, 2b             # verifica se o loop acabou ou não
    2:

    bne t6, t1, 7f
    sub a0, zero, a0           # torna o número negativo se t6 != '-'

    7:
        ret

unsigned2int:
    li a0, 0                    # número int
    li t1, 1000                 # potencia de dez
    li t2, 10                   # const 10
    li t6, 4                    # contador do loop
    1:
        lbu t0, 0(s1)           # carrega o char
        addi t0, t0, -'0'       # char -> int
        mul t0, t0, t1          # pega a potência de dez
        add a0, a0, t0         # soma ao número int

        addi s1, s1, 1          # incrementa o ponteiro de input

        divu t1, t1, t2         # reduz a potência de 10

        addi t6, t6, -1         # reduz o contador do loop
        bnez t6, 1b             # verifica se o loop acabou ou não
    1:
    ret

# Problema ret ret
print_signed:
    la a1, output
    li t1, 1000
    li t2, 10
    li t6, 4
    mv t5, a0

    blt t5, zero, 7f

    li t0, '+'
    sb t0, 0(a1)
    jal write
    j 1f

    7:
        li t0, '-'
        sb t0, 0(a1)
        jal write

    1:
        divu t4, t5, t1
        remu t5, t5, t1
        addi t4, t4, '0'
        sb t4, 0(a1)
        jal write

        divu t1, t1, t2
        addi t6, t6, -1
        bnez t6, 1b
    1:

    li t1, ' '
    sb t1, 0(a1)
    jal write
    ret

exit:
    li a0, 0
    li a7, 93
    ecall
